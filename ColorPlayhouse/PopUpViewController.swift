//
//  PopUpViewController.swift
//  ColorPlayhouse
//
//  Created by Bruna Aleixo on 11/17/16.
//  Copyright © 2016 Aleixo Rosa & Crispim. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import FBSDKShareKit
import FBSDKTVOSKit

class PopUpViewController: UIViewController, FBSDKDeviceLoginViewControllerDelegate {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var screenshotImageView: UIImageView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var clearAllButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    let DAO = DataAccessObject.sharedInstance
    
    var timeLapseBuilder: TimeLapseBuilder?
    
    var screenshotsPaths = [String]()
    
    private var focusGuide = UIFocusGuide()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImage()
        setupView()
        showAnimation()
        
        self.view.addLayoutGuide(self.focusGuide)
        
        self.focusGuide.leftAnchor.constraint(equalTo: self.playButton.leftAnchor).isActive = true
        self.focusGuide.topAnchor.constraint(equalTo: self.menuButton.topAnchor).isActive = true
        self.focusGuide.widthAnchor.constraint(equalTo: self.playButton.widthAnchor).isActive = true
        self.focusGuide.heightAnchor.constraint(equalTo: self.menuButton.heightAnchor).isActive = true
    }
    
    //MARK: IBAction Methods
    
    @IBAction func didPressPlayVideoButton(_ sender: AnyObject) {
        self.timeLapseBuilder = TimeLapseBuilder(photoURLs: screenshotsPaths)
        self.timeLapseBuilder!.build(
            progress: { (progress: Progress) in
                NSLog("Progress: \(progress.completedUnitCount) / \(progress.totalUnitCount)")
                
        },
            success: { url in
                NSLog("Output written to \(url)")
                self.playVideo(videoOutputURL: url as URL)
        },
            failure: { error in
                NSLog("failure: \(error)")
                
        }
        )
    }
    
    @IBAction func didPressClearButton(_ sender: AnyObject) {
        print("Clear Button Pressed")
    }
    
    @IBAction func didPressSaveButton(_ sender: AnyObject) {
        let defaults = UserDefaults.standard
        var numberOfArtwork = defaults.object(forKey: "numberOfArtwork") as! Int
        
        DAO.saveImageToUser(image: screenshotImageView.image!) { (success) in
            if success {
                numberOfArtwork += 1
                defaults.set(numberOfArtwork, forKey: "numberOfArtwork")
            } else {
                self.showErrorSavingAlert()
            }
            
        }
    }
    
    @IBAction func didPressShareButton(_ sender: AnyObject) {
        loginToFacebook()
        print("Share Button Pressed")
    }
    
    func loginToFacebook() {
        if (FBSDKAccessToken.current() != nil) {
            // User is already logged in, do work such as go to next view controller.
        }
        else {
            
            let viewController = FBSDKDeviceLoginViewController()
            viewController.publishPermissions = ["publish_actions"]
            viewController.delegate = self
            self.present(viewController, animated: true, completion: nil)

        }
    }
    func deviceLoginViewControllerDidCancel(_ viewController: FBSDKDeviceLoginViewController) {
        print("canceled")
    }
    
    func deviceLoginViewControllerDidFail(_ viewController: FBSDKDeviceLoginViewController, error: Error) {
        print(error.localizedDescription)
    }
    
    func deviceLoginViewControllerDidFinish(_ viewController: FBSDKDeviceLoginViewController) {
        shareOnFacebook()
    }
    

    func shareOnFacebook() {
        
    }
    
    
    @IBAction func didPressMenuButton(_ sender: AnyObject) {
       // removeAnimation()
        print("Menu Button Pressed")
    }

    
    // MARK: Auxiliary Methods
    
    private func setImage() {
        let nsDirectory = FileManager.SearchPathDirectory.cachesDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDirectory, nsUserDomainMask, true)
        if let dirPath = paths.first {
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent("image\(screenshotsPaths.count-1).png")
            print(imageURL)
            let image = UIImage(contentsOfFile: imageURL.path)
            screenshotImageView.image = image
            // Do whatever you want with the image
        }
    }
    
    private func setupView() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.popupView.layer.cornerRadius = 5
        self.popupView.layer.shadowOpacity = 0.8
        self.popupView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }
    
    private func playVideo(videoOutputURL: URL) {
        let player = AVPlayer(url: videoOutputURL)
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
        }
    }
    
    func showAnimation() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0
        
        UIView.animate(withDuration: 0.25) {
            self.view.alpha = 1
            self.view.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
    }
    
    func removeAnimation() {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0
        }) { (finished) in
            if finished {
                self.view.removeFromSuperview()
            }
        }
    }
}

//MARK: Alert
extension PopUpViewController {
     func showErrorSavingAlert() {
        let alertController = UIAlertController(title: "Error", message: "Oops! An error ocurred when saving a screenshot of your artwork.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
