//
//  VideoTableViewCell.swift
//  TwitterVideoDownloader
//
//  Created by Comet on 3/30/19.
//  Copyright © 2019 SmoothAce. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

    @IBOutlet weak var video_thumb: UIImageView!
    @IBOutlet weak var video_title: UILabel!
    @IBOutlet weak var video_link: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
