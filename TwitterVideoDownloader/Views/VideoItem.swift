//
//  VideoItem.swift
//  TwitterVideoDownloader
//
//  Created by Comet on 3/31/19.
//  Copyright © 2019 SmoothAce. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class VideoItem {
    var thumbnail: UIImage?
    var file_path: String
    var file_name: String
    var down_date: String?
    
    init(path: String) {
        file_path = path
        var url = URL(fileURLWithPath: path)
        thumbnail = VideoItem.getThumbnailImage(forUrl: url)
        var url_patch_parts : [Substring] = file_path.split(separator: "/")
        
        file_name = String(url_patch_parts[url_patch_parts.count - 1])
        if let date = VideoItem.fileModificationDate(url: url) {
            down_date = VideoItem.getDateString(date: date)
        }
    }
    
    class func fileModificationDate(url: URL) -> Date? {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: url.path)
            return attr[FileAttributeKey.modificationDate] as? Date
        } catch {
            return nil
        }
    }
    
    class func getDateString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return formatter.string(from: date)
    }
    
    class func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
}
