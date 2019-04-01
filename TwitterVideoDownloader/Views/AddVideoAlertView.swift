//
//  AddVideoAlertView.swift
//  TwitterVideoDownloader
//
//  Created by Comet on 3/31/19.
//  Copyright © 2019 SmoothAce. All rights reserved.
//

import UIKit

class AddVideoAlertView: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var alertTextField: UITextField!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertViewCenterY: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var delegate: AddVideoViewDelegate?
    var selectedOption = "Twitter"
    let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    
    var title_str: String = "Add Video"
    var message: String = "Select the site of url and input to the input view below."
    var option1: String = "Twitter"
    var option2: String = "Instagram"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertTextField.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(AddVideoAlertView.keyBoardUp(Notification :)), name: UIViewController.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddVideoAlertView.keyBoardDown(Notification :)), name: UIViewController.keyboardDidHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
        cancelButton.layer.borderColor = alertViewGrayColor.cgColor
        cancelButton.layer.borderWidth = 1
        okButton.layer.borderColor = alertViewGrayColor.cgColor
        okButton.layer.borderWidth = 1
    }
    
    @objc func keyBoardUp( Notification: NSNotification){
        alertViewCenterY.constant = -120
    }
    
    @objc func keyBoardDown( Notification: NSNotification){
        alertViewCenterY.constant = 0
    }
    
    func updateMessages(title: String, message: String, option1: String, option2: String) {
        self.title = title
        self.message = message
        self.option1 = option1
        self.option2 = option2
        setupView()
    }
    
    func setupView() {
        alertView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        titleLabel.text = title_str
        messageLabel.text = message
        segmentedControl.setTitle(option1, forSegmentAt: 0)
        segmentedControl.setTitle(option2, forSegmentAt: 1)
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    @IBAction func onTapCancelButton(_ sender: Any) {
        alertTextField.resignFirstResponder()
        delegate?.cancelButtonTapped()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapOkButton(_ sender: Any) {
        alertTextField.resignFirstResponder()
        delegate?.okButtonTapped(selectedOption: selectedOption, textFieldValue: alertTextField.text!)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("First option")
            selectedOption = segmentedControl.titleForSegment(at: 0)!
            break
        case 1:
            print("Second option")
            selectedOption = segmentedControl.titleForSegment(at: 1)!
            break
        default:
            break
        }
    }
}
