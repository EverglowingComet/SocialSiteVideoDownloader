//
//  Utils.swift
//  TweetTest
//
//  Created by Comet on 3/28/19.
//  Copyright © 2019 Comet. All rights reserved.
//

import Foundation
import Photos

class Utils {
    
    class func parseJSONstr(str: String, field: String, subfield: String) -> String? {
        if let data = str.data(using: String.Encoding.utf8) {
            if let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject] {
                if dictionary[field] != nil && dictionary[field]?[subfield] != nil {
                    let dict: [String: AnyObject]? = try? dictionary[field] as! [String : AnyObject]
                    let result: String? = try? dict?[subfield] as! String
                    return result
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
    
    class func downloadVideoFromLink(videoImageUrl: String, filename: String) {
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: videoImageUrl),
                let urlData = NSData(contentsOf: url) {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/" + filename
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                    }) { completed, error in
                        if completed {
                            print("Video is saved!")
                        }
                    }
                }
            }
        }
    }
    
}
