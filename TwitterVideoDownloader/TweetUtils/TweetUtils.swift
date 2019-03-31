//
//  TweetUtils.swift
//  TweetTest
//
//  Created by Comet on 3/28/19.
//  Copyright © 2019 Comet. All rights reserved.
//

import Foundation

class TweetUtils {
    
    static let APP_DIR = "tweet_downloader"
    static let TWEET_DIR = "tweet_contents"
    static let INSTAGRAM_DIR = "instagram_contents"
    
    class func getTweetContentDir() -> String? {
        let tweeter_download_dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        return "\(tweeter_download_dir)/tweet_downloader/tweet_contents"
    }
    
    class func getInstagramContentDir() -> String? {
        let tweeter_download_dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        return "\(tweeter_download_dir)/tweet_downloader/instagram_contents"
    }
    
    class func getTweetFileName(file_name: String) -> String? {
        let tweeter_download_dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        return "\(tweeter_download_dir)/tweet_downloader/tweet_contents/\(file_name)"
    }
    
    class func getTweetFileName(tweet_id: String, file_extension: String) -> String? {
        let tweeter_download_dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        return "\(tweeter_download_dir)/tweet_downloader/tweet_contents/\(tweet_id).\(file_extension)"
    }
    
    class func getInstagramFileName(file_name: String) -> String? {
        let tweeter_download_dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        return "\(tweeter_download_dir)/tweet_downloader/instagram_contents/\(file_name)"
    }
    
    class func getInstagramFileName(tweet_id: String, file_extension: String) -> String? {
        let tweeter_download_dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        return "\(tweeter_download_dir)/tweet_downloader/instagram_contents/\(tweet_id).\(file_extension)"
    }
    
    class func parseJSONstr(str: String, field: String, subfield: String) -> String? {
        if let data = str.data(using: String.Encoding.utf8) {
            if let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject] {
                let dict = (dictionary as! [String: Any])[field] as! [String: Any]
                if let sub_info = (dict[subfield] as? String) {
                    return sub_info
                } else {
                    return nil
                }
            }
        }
        print("JSON not correct")
        return nil
    }
    
    class func ism3u8URL(url: String) -> Bool {
        
        return url.contains(".m3u8")
    }
    
    class func ismp4URL(url: String) -> Bool {
        
        return url.contains(".mp4")
    }
    
    class func isgifURL(url: String) -> Bool {
        
        return url.contains(".gif")
    }
    
    
}
