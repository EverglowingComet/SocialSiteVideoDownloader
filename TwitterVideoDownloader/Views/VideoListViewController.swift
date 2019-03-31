//
//  ViewController.swift
//  TwitterVideoDownloader
//
//  Created by Comet on 3/30/19.
//  Copyright © 2019 SmoothAce. All rights reserved.
//

import UIKit

class VideoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var video_url: String = ""
    
    @IBOutlet weak var add_video_btn: UIBarButtonItem!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func addNewVideoClicked(_ sender: UIBarButtonItem) {
    }
    
    func showInputDialog() {
        
        let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertID") as! CustomAlertView
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.delegate = self
        
        self.present(customAlert, animated: true, completion: nil)
    }
}

extension VideoListViewController: AddVideoViewDelegate {
    
    func okButtonTapped(selectedOption: String, textFieldValue: String) {
        print("okButtonTapped with \(selectedOption) option selected")
        print("TextField has value: \(textFieldValue)")
    }
    
    func cancelButtonTapped() {
        print("cancelButtonTapped")
    }
}

