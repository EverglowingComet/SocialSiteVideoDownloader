//
//  TweetDownloader.swift
//  TweetTest
//
//  Created by Comet on 3/28/19.
//  Copyright © 2019 Comet. All rights reserved.
//

import Foundation
import Photos

class TweetDownloader {
    var delegate: TweetDownloaderDelegate?
    var download_url: String!
    
    fileprivate var isDownloading = false
    fileprivate var duringDownloadingProcess = false
    
    init(url: String) {
        download_url = url
    }
    
    func startTweetDownload(videoImageUrl: String) {
        if TweetUtils.ismp4URL(url: download_url) || TweetUtils.isgifURL(url: download_url) {
            downloadFileFromLink(videoImageUrl: videoImageUrl, is_tweet: true)
        } else if TweetUtils.ism3u8URL(url: download_url) {
            downloadm3u8FromURL(video_url: download_url, is_tweet: true)
        }
    }
    
    func downloadFileFromLink(videoImageUrl: String, is_tweet: Bool) {
        let url_patch = videoImageUrl.split(separator: "?")[0]
        var url_patch_parts : [Substring] = url_patch.split(separator: "/")
        let file_name = String(url_patch_parts[url_patch_parts.count - 1])
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: videoImageUrl),
                let urlData = NSData(contentsOf: url) {
                let tweeter_download_dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath = "\(tweeter_download_dir)/\(file_name)"
                /*let filePath = is_tweet ? TweetUtils.getTweetFileName(file_name: file_name) : TweetUtils.getInstagramFileName(file_name: file_name)*/
                
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                    }) { completed, error in
                        if completed {
                            print("Video is saved!")
                            self.delegate?.tweetDownloadSucceded(by: self)
                        } else {
                            self.delegate?.tweetDownloadFailed(by: self, error: "Downloading File Failed")
                        }
                    }
                }
            }
        }
    }
    
    func downloadm3u8FromURL(video_url: String, is_tweet: Bool) {
        /*if duringDownloadingProcess {
         lemonDeer.downloader.resumeDownloadSegment()
         } else {
         duringDownloadingProcess = true
         lemonDeer.directoryName = is_tweet ? TweetUtils.TWEET_DIR : TweetUtils.INSTAGRAM_DIR
         lemonDeer.m3u8URL = video_url
         lemonDeer.delegate = viewController
         lemonDeer.parse()
         }*/
    }
}

protocol TweetDownloaderDelegate {
    func tweetDownloadSucceded(by downloader: TweetDownloader)
    func tweetDownloadFailed(by downloader: TweetDownloader, error: String)
}
