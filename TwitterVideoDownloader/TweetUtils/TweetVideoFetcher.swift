//
//  TweetVideoDownloader.swift
//  TweetTest
//
//  Created by Comet on 3/28/19.
//  Copyright © 2019 Comet. All rights reserved.
//

import Foundation
import SwiftSoup

class TweetVideoFetcher {
    var video_url: String
    var delegate: TweetVideoFetcherDelegate?
    
    init(url: String) {
        video_url = url
    }
    
    func startVideoDownlaod() -> String {
        let embedded_url = ""
        let video_player_url_prefix = "https://twitter.com/i/videos/tweet/"
        
        let video_url = String(self.video_url.split(separator: "?")[0])
        let tweet_user = String(video_url.split(separator: "/")[2])
        let tweet_id = String(video_url.split(separator: "/")[4])
        
        let video_player_url = video_player_url_prefix + tweet_id
        
        var request = URLRequest(url: URL(string: video_player_url)!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let httpResponse = response as? HTTPURLResponse
            
            if (error == nil) {
                let str = String(data: data!, encoding: String.Encoding.utf8)
                self.parseJsURL(html: str!, tweet_id: tweet_id)
            } else {
                print("Retriviing html from twitter video link failed", error)
                self.delegate?.videoLinkFetchingFailed(by: self, error: "Fetching URL failed. Check your Internet connection")
            }
            
        }
        
        task.resume()
        return embedded_url
    }
    
    func parseJsURL(html: String, tweet_id: String) {
        do {
            let doc : Document = try SwiftSoup.parse(html)
            let js_script_tag: Element? = try doc.select("script[src]").first()
            
            if let js_script_url = try js_script_tag?.attr("src") {
                var request = URLRequest(url: URL(string: js_script_url)!)
                request.httpMethod = "GET"
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if (error == nil) {
                        let result : NSString = String(data: data!, encoding: String.Encoding.utf8) as! NSString
                        let regex = try? NSRegularExpression(pattern: "Bearer ([a-zA-Z0-9%-])+", options: .caseInsensitive)
                        
                        if let auth_range = regex?.matches(in: result as String, options: [], range: NSRange(location: 0, length: result.length)).first?.range {
                            let auth_token = String(result.substring(with: auth_range))
                            let config_url = "https://api.twitter.com/1.1/videos/tweet/config/" + tweet_id //+ ".json"
                            
                            self.parsePlayerConfig(url: config_url, auth_token: auth_token)
                        } else {
                            self.delegate?.videoLinkFetchingFailed(by: self, error: "Retriviing auth token from javascript failed")
                        }
                        
                    } else {
                        print("Retriviing javascript for twitter video link failed", error)
                        self.delegate?.videoLinkFetchingFailed(by: self, error: "Retriviing javascript for twitter video link failed")
                    }
                }
                task.resume()
            }
            
        } catch Exception.Error(let type, let message) {
            print(message)
            self.delegate?.videoLinkFetchingFailed(by: self, error: "Parse javascript failed, message: " + message)
        } catch let error as NSError {
            print(error)
            self.delegate?.videoLinkFetchingFailed(by: self, error: "Parse javascript failed with error")
        }
    }
    
    func parsePlayerConfig(url: String, auth_token: String) {
        var request = URLRequest(url: URL(string: url)!,
                                 cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad,
                                 timeoutInterval: 10)
        
        request.httpMethod = "GET"
        request.addValue(auth_token, forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if (error == nil) {
                if let result = String(data: data!, encoding: String.Encoding.utf8) {
                    if let json_result = TweetUtils.parseJSONstr(str: result, field: "track", subfield: "playbackUrl") {
                        print(json_result, TweetUtils.ism3u8URL(url: json_result))
                        //self.delegate?.videoLinkFetched(by: self, link: json_result)
                        self.parseM3U8info(url: json_result)
                    } else if let json_result = TweetUtils.parseJSONstr(str: result, field: "track", subfield: "vmapUrl") {
                        self.parseMP4info(url: json_result)
                        
                    }
                    else {
                        self.delegate?.videoLinkFetchingFailed(by: self, error: "Twitter says retry times exceeded. Try again later.")
                    }
                } else {
                    self.delegate?.videoLinkFetchingFailed(by: self, error: "Player config data invalid")
                }
                
            } else {
                print("Retriviing player config info for twitter video link failed", error)
                self.delegate?.videoLinkFetchingFailed(by: self, error: "Player config authentication failed with error")
            }
        }
        task.resume()
    }
    
    func parseM3U8info(url: String) {
        var request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if (error == nil) {
                if let result = String(data: data!, encoding: String.Encoding.utf8) {
                    print(result)
                } else {
                    self.delegate?.videoLinkFetchingFailed(by: self, error: "Player config data invalid")
                }
                
            } else {
                print("Retriviing player config info for twitter video link failed", error)
                self.delegate?.videoLinkFetchingFailed(by: self, error: "Player config authentication failed with error")
            }
        }
        task.resume()
    }
    
    func parseMP4info(url: String) {
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if (error == nil) {
                if let result = String(data: data!, encoding: String.Encoding.utf8) {
                    print(result)
                    do {
                        let doc : Document = try SwiftSoup.parse(result)
                        if let js_script_tag: Element = try doc.select("MediaFile").first() {
                            if let js_script_tag_1: Element = try js_script_tag.select("MediaFile").first() {
                                if let mp4_link: String = try js_script_tag_1.text() {
                                    self.delegate?.videoLinkFetched(by: self, link: mp4_link)
                                    return
                                }
                            }
                        }
                        self.delegate?.videoLinkFetchingFailed(by: self, error: "VmapUrl response has not Mp4 file url")
                    } catch _ as NSError {
                        self.delegate?.videoLinkFetchingFailed(by: self, error: "VmapUrl response has not MediaFile tag")
                    }
                } else {
                    self.delegate?.videoLinkFetchingFailed(by: self, error: "Failed to parse vmapUrl response")
                }
                
            } else {
                print("Retriviing player config info to parse vmapUrl failed")
                self.delegate?.videoLinkFetchingFailed(by: self, error: "Retriviing player config info to parse vmapUrl failed")
            }
        }
        task.resume()
    }
}

protocol TweetVideoFetcherDelegate {
    func videoLinkFetched(by fetcher: TweetVideoFetcher, link: String)
    func videoLinkFetchingFailed(by fetcher: TweetVideoFetcher, error: String)
}
