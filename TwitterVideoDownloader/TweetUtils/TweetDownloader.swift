//
//  TweetDownloader.swift
//  TweetTest
//
//  Created by Comet on 3/28/19.
//  Copyright © 2019 Comet. All rights reserved.
//

import Foundation
import Photos
import NicooM3u8Downloader

class TweetDownloader: YagorDelegate {
    var delegate: TweetDownloaderDelegate?
    var download_url: String!
    
    fileprivate var isDownloading = false
    fileprivate var duringDownloadingProcess = false
    var file_name: String!
    
    init(url: String, delegate: TweetDownloaderDelegate, filename: String?) {
        download_url = url
        self.delegate = delegate
        file_name = filename
        let url_patch = download_url.split(separator: "?")[0]
        var url_patch_parts : [Substring] = url_patch.split(separator: "/")
        
        let file_name_url = String(url_patch_parts[url_patch_parts.count - 1])
        if file_name != nil {
            if let ext = try? file_name_url.split(separator: ".")[1] {
                file_name = file_name + "." + String(ext)
            }
        } else {
            file_name = file_name_url
        }
    }
    
    func startTweetDownload(videoImageUrl: String) {
        if TweetUtils.ismp4URL(url: download_url) || TweetUtils.isgifURL(url: download_url) {
            downloadFileFromLink(videoImageUrl: videoImageUrl, is_tweet: true)
        } else if TweetUtils.ism3u8URL(url: download_url) {
            downloadm3u8FromURL(video_url: download_url, is_tweet: true)
        }
    }
    
    func downloadFileFromLink(videoImageUrl: String, is_tweet: Bool) {
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: videoImageUrl),
                let urlData = NSData(contentsOf: url) {
                let tweeter_download_dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath = tweeter_download_dir + "/" + self.file_name
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
                            self.delegate?.tweetDownloadFailed(by: self, error: "Photo Library Update Failed")
                        }
                    }
                }
            }
        }
    }
    
    func downloadm3u8FromURL(video_url: String, is_tweet: Bool) {
        downloadM3U8(url: video_url)
    }
    
    private func downloadM3U8(url: String) {
        let yagor = NicooYagor()
        yagor.directoryName = file_name
        yagor.m3u8URL = url
        yagor.delegate = self
        yagor.parse()
        
//        let filePath = NicooDownLoadHelper.getDocumentsDirectory().appendingPathComponent(NicooDownLoadHelper.downloadFile)
//        print("download path: ", filePath)
    }
    
    private func mergeTSClip(tmpURL: URL, yagor: NicooYagor) {
        let directoryURL = tmpURL.path + "/" + file_name + "/"
        //let mergedTS = tmpURL.path + "/" + String(file_name.split(separator: ".")[0]) + ".mpg"
        let mergedTS = NicooDownLoadHelper.getDocumentsDirectory().path + "/" + String(file_name.split(separator: ".")[0]) + ".mpg"
        //let mergedTS = directoryURL + tweet_id + ".mpg"
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: directoryURL).sorted()
            
            FileManager.default.createFile(atPath: mergedTS, contents: nil, attributes: nil)
            let writter = FileHandle(forWritingAtPath: mergedTS)
            
            // merge ts clip file
            for file in files {
                if file.lowercased().range(of: ".ts") == nil {
                    continue
                }
                
                let reader = FileHandle(forReadingAtPath: directoryURL + file)
                var data = reader?.readData(ofLength: 0x400)
                while (data?.count)! > 0 {
                    writter?.write(data!)
                    data = reader?.readData(ofLength: 0x400)
                }
                reader?.closeFile()
            }
            writter?.closeFile()
            
            // remove temp ts files
            yagor.deleteDownloadedContents(with: file_name)
            
            if self.delegate != nil {
                PHPhotoLibrary.requestAuthorization { (status) in
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: mergedTS))
                    }) { completed, error in
                        if completed {
                            print("M3u8 is saved!")
                            self.delegate?.tweetDownloadSucceded(by: self)
                        } else {
                            self.delegate?.tweetDownloadFailed(by: self, error: "Photo Library Update Failed")
                        }
                    }
                }
            }
            
        } catch let error {
            self.delegate?.tweetDownloadFailed(by: self, error: error.localizedDescription)
        }
    }
    
    
    // MARK: YagorDelegate
    func videoDownloadSucceeded(by yagor: NicooYagor) {
        let filePath = NicooDownLoadHelper.getDocumentsDirectory().appendingPathComponent(NicooDownLoadHelper.downloadFile)
        //print("downLoadFilePath = \(filePath). videoFileName = \(yagor.directoryName)")
        mergeTSClip(tmpURL: filePath, yagor: yagor)
    }
    
    
    func videoDownloadFailed(by yagor: NicooYagor) {
        //print("Video download failed. \(yagor.directoryName)")
        delegate?.tweetDownloadFailed(by: self, error: "Video download failed. \(yagor.directoryName)")
    }
    
    
    func update(progress: Float, yagor: NicooYagor) {
        //print("downloading video \(progress * 100) %...")
        /*if self.delegate != nil {
         self.delegate?.downloadingProgress(progress: progress, status: "downloading")
         }*/
    }
}

/*
extension TweetDownloader: YagorDelegate {
    func videoDownloadSucceeded(by yagor: NicooYagor) {
        let filePath = NicooDownLoadHelper.getDocumentsDirectory().appendingPathComponent(NicooDownLoadHelper.downloadFile)
        //print("downLoadFilePath = \(filePath). videoFileName = \(yagor.directoryName)")
        mergeTSClip(tmpURL: filePath, yagor: yagor)
    }
    
    
    func videoDownloadFailed(by yagor: NicooYagor) {
        //print("Video download failed. \(yagor.directoryName)")
        delegate?.tweetDownloadFailed(by: self, error: "Video download failed. \(yagor.directoryName)")
    }
    
    
    func update(progress: Float, yagor: NicooYagor) {
        //print("downloading video \(progress * 100) %...")
        /*if self.delegate != nil {
            self.delegate?.downloadingProgress(progress: progress, status: "downloading")
        }*/
    }
}*/


protocol TweetDownloaderDelegate {
    func tweetDownloadSucceded(by downloader: TweetDownloader)
    func tweetDownloadFailed(by downloader: TweetDownloader, error: String)
}
