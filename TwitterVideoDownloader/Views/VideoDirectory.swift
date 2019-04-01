//
//  VideoDirectory.swift
//  TwitterVideoDownloader
//
//  Created by Comet on 3/31/19.
//  Copyright © 2019 SmoothAce. All rights reserved.
//

import Foundation

class VideoDirectory {
    var dir_name: String
    var videoItems: [VideoItem] = []
    
    init(dir: String) {
        dir_name = dir
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs:[URL] = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            for url in fileURLs {
                let ext = url.pathExtension
                if ext == "gif" || ext == "mpg" || ext == "mp4" {
                    videoItems.append(VideoItem(path: url.path))
                }
            }
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
}
