//
//  ViewController.swift
//  TwitterVideoDownloader
//
//  Created by Comet on 3/30/19.
//  Copyright © 2019 SmoothAce. All rights reserved.
//

import UIKit
import HUD

class VideoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var video_url: String = ""
    private var tweetDownloader: TweetDownloader?
    private var video_list: VideoDirectory?
    private var video_icon_placeholder: UIImage = UIImage(named: "video_icon")!
    
    @IBOutlet weak var table_view: UITableView!
    @IBOutlet weak var add_video_btn: UIBarButtonItem!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = video_list?.videoItems.count {
            return count
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "videoitem") as! VideoTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoitem", for: indexPath) as! VideoTableViewCell
        if let item = video_list?.videoItems[indexPath.row] {
            cell.video_title.text = item.file_name
            cell.video_thumb.contentMode = .scaleAspectFit
            cell.video_thumb.image = item.thumbnail ?? video_icon_placeholder
            cell.video_link.text = item.down_date ?? "unknown"
        }
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let item = video_list?.videoItems[indexPath.row] {
                do {
                    try FileManager.default.removeItem(atPath: item.file_path)
                    video_list?.videoItems.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                } catch let error as NSError {
                    showAlert(viewController: self, title: "Error", msg: "Video Item Not Removed", buttonTitle: "Ok", handler: nil)
                }
            }
        }
    }
    func updateVideoList() {
        video_list = VideoDirectory(dir: "tweet")
        table_view.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateVideoList()
        table_view.dataSource = self
        table_view.delegate = self
    }

    @IBAction func addNewVideoClicked(_ sender: UIBarButtonItem) {
        showInputDialog()
    }
    
    func showInputDialog() {
        
        let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertID") as! AddVideoAlertView
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.delegate = self
        
        self.present(customAlert, animated: true, completion: nil)
        
    }
    
    func showAlert(viewController: UIViewController?,title: String, msg: String, buttonTitle: String, handler: ((UIAlertAction) -> Swift.Void)?){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: buttonTitle, style: .default, handler: handler)
        alertController.addAction(defaultAction)
        
        viewController?.present(alertController, animated: true, completion: nil)
    }
    
    func showPromptFilenameDialog(link: String, viewController: UIViewController?){
        
        let alertController : UIAlertController = UIAlertController(title: "Video Link Fetched", message: "Please Input your video file name", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: {(textfield) in
            textfield.placeholder = "Enter File Name"
        })
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(alertAction: UIAlertAction!) in
            let file_name = alertController.textFields![0].text
            
            self.tweetDownloader = TweetDownloader(url: link, delegate: self, filename: file_name)
            self.tweetDownloader!.delegate = self
            self.tweetDownloader!.startTweetDownload(videoImageUrl: link)
            DispatchQueue.main.async {
                HUD.show(.loading, text: "Downloading Video File")
            }
        }))
        
        viewController?.present(alertController, animated: true, completion: nil)
    }
}

extension VideoListViewController: AddVideoViewDelegate {
    
    func okButtonTapped(selectedOption: String, textFieldValue: String) {
        let videoImageUrl = textFieldValue
        //"https://twitter.com/MW2Remastered4K/status/1108809745891295234"//m3u8
        //"https://twitter.com/assassinscreed/status/1111659280002764800"//mp4
        
        let fetcher: TweetVideoFetcher = TweetVideoFetcher(url: videoImageUrl, delegate: self)
        fetcher.delegate = self
        fetcher.startVideoDownlaod()
        DispatchQueue.main.async {
            HUD.show(.loading, text: "Fetching Video Link")
        }
    }
    
    func cancelButtonTapped() {
        print("cancelButtonTapped")
    }
}


extension VideoListViewController: TweetVideoFetcherDelegate {
    func videoLinkFetched(by fetcher: TweetVideoFetcher, link: String) {
        DispatchQueue.main.async {
            HUD.dismiss()
            self.showPromptFilenameDialog(link: link, viewController: self)
        }
    }
    
    func videoLinkFetchingFailed(by fetcher: TweetVideoFetcher, error: String) {
        DispatchQueue.main.async {
            HUD.dismiss()
            self.showAlert(viewController: self, title: "Fetching Media Link Error", msg: error, buttonTitle: "Ok", handler: nil)
        }
    }
    
}

extension VideoListViewController: TweetDownloaderDelegate {
    func tweetDownloadSucceded(by downloader: TweetDownloader) {
        DispatchQueue.main.async {
            self.updateVideoList()
            HUD.dismiss()
            self.showAlert(viewController: self, title: "Succeded", msg: "Downloaindg succeeded.", buttonTitle: "Ok", handler: nil)
        }
    }
    
    func tweetDownloadFailed(by downloader: TweetDownloader, error: String) {
        DispatchQueue.main.async {
            HUD.dismiss()
            self.showAlert(viewController: self, title: "Download Error", msg: error, buttonTitle: "Ok", handler: nil)
        }
    }
    
    
}
