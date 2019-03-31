//
//  AddVideoViewDelegate.swift
//  TwitterVideoDownloader
//
//  Created by Comet on 3/31/19.
//  Copyright © 2019 SmoothAce. All rights reserved.
//

protocol AddVideoViewDelegate: class {
    func okButtonTapped(selectedOption: String, textFieldValue: String)
    func cancelButtonTapped()
}
