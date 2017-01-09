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

class PopUpViewController: UIViewController, FBSDKDeviceLoginViewControllerDelegate, FBSDKDeviceShareViewControllerDelegate  {
    
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
    var videoOutputURL: URL!
    
    private var focusGuide = UIFocusGuide()
	private var indicator: UIActivityIndicatorView?
	private var cover: UIView?
	
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImage()
        showAnimation()
        
        self.view.addLayoutGuide(self.focusGuide)
        
        self.focusGuide.leftAnchor.constraint(equalTo: self.playButton.leftAnchor).isActive = true
        self.focusGuide.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.focusGuide.widthAnchor.constraint(equalTo: self.playButton.widthAnchor).isActive = true
        self.focusGuide.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
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
                self.videoOutputURL = url as URL!
                self.playVideo(videoOutputURL: url as URL)
        },
            failure: { error in
                NSLog("failure: \(error)")
                
        }
        )
    }
    
    @IBAction func didPressClearButton(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "DrawingVC") as! DrawingCanvasViewController
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func didPressSaveButton(_ sender: AnyObject) {
		
		startActivityIndicator()
		
        if videoOutputURL != nil {
            saveAssets()
        } else {
            self.timeLapseBuilder = TimeLapseBuilder(photoURLs: screenshotsPaths)
            self.timeLapseBuilder!.build(
                progress: { (progress: Progress) in
                    NSLog("Progress: \(progress.completedUnitCount) / \(progress.totalUnitCount)")
                    
                },
                success: { url in
                    NSLog("Output written to \(url)")
                    self.videoOutputURL = url as URL!
                    self.saveAssets()
                },
                failure: { error in
                    NSLog("failure: \(error)")
                    stopActivityIndicator()
                }
            )
        }
    }
    
    func saveAssets() {
        let defaults = UserDefaults.standard
        var numberOfArtwork = defaults.object(forKey: "numberOfArtwork") as! Int

        DAO.saveAssetsToUser(image: screenshotImageView.image!, videoURL: self.videoOutputURL) { (success) in
            if success {
				print(numberOfArtwork)
                numberOfArtwork += 1
				print(numberOfArtwork)
                defaults.set(numberOfArtwork, forKey: "numberOfArtwork")
				
				DispatchQueue.main.async {
					self.stopActivityIndicator()
					self.removeAnimation()
				}
            } else {
				DispatchQueue.main.async {
					self.stopActivityIndicator()
					self.showErrorSavingAlert()
				}
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
        showErrorLoggingIn()
        print(error.localizedDescription)
    }
    
    func deviceLoginViewControllerDidFinish(_ viewController: FBSDKDeviceLoginViewController) {
        shareOnFacebook()
    }
    
    func shareOnFacebook() {
        let link = FBSDKShareLinkContent()
        link.contentURL = NSURL(fileURLWithPath: screenshotsPaths.last!) as URL!
        let viewController = FBSDKDeviceShareViewController(share: link)
        viewController.delegate = self
        self.present(viewController, animated: true, completion: nil)
    }
    
    func deviceShareViewControllerDidComplete(_ viewController: FBSDKDeviceShareViewController, error: Error?) {
        if let unwrappedError = error {
            print(unwrappedError.localizedDescription)
        }
    }
    
    @IBAction func didPressMenuButton(_ sender: AnyObject) {
       // removeAnimation()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MainMenuScene") as! MainMenuViewController
        self.present(controller, animated: true, completion: nil)
        
        print("Menu Button Pressed")
    }

    
    // MARK: Auxiliary Methods
	
	private func startActivityIndicator() {
		
		let width = 300
		let height = 300
		
		indicator = UIActivityIndicatorView()
		indicator?.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: height))
		indicator?.center = CGPoint(x:UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
		indicator?.activityIndicatorViewStyle = .whiteLarge
		indicator?.color = UIColor.darkGray
		indicator?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
		indicator?.hidesWhenStopped = true
		
		cover = UIView(frame: UIScreen.main.bounds)
		cover?.alpha = 0
		
		view.addSubview(cover!)
		view.addSubview(indicator!)
		
		indicator?.startAnimating()
	}
	
	private func stopActivityIndicator() {
		
		indicator?.stopAnimating()
		indicator?.removeFromSuperview()
		cover?.removeFromSuperview()
		indicator = nil
		cover = nil
	}
    
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
    func showErrorLoggingIn() {
        let alertController = UIAlertController(title: "Error", message: "Oops! An error ocurred when attempting to log into Facebook.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
     func showErrorSavingAlert() {
        let alertController = UIAlertController(title: "Error", message: "Oops! An error ocurred when saving a screenshot of your artwork.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
