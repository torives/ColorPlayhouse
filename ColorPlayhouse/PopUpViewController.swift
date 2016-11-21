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

class PopUpViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImage()
        setupView()
        showAnimation()
        addMenuButtonRecognizer()
    }
    

    func setImage() {
        let nsDirectory = FileManager.SearchPathDirectory.cachesDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDirectory, nsUserDomainMask, true)
        if let dirPath = paths.first {
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent("image\(screenshotsPaths.count).png")
            print(imageURL)
            let image = UIImage(contentsOfFile: imageURL.path)
            screenshotImageView.image = image
            // Do whatever you want with the image
        }
    }
    
    func setupView() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.popupView.layer.cornerRadius = 5
        self.popupView.layer.shadowOpacity = 0.8
        self.popupView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }
    
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
    
    func playVideo(videoOutputURL: URL) {
        let player = AVPlayer(url: videoOutputURL)
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
        }
    }
    
    @IBAction func didPressClearButton(_ sender: AnyObject) {
        removeAnimation()
    }
    
    @IBAction func didPressSaveButton(_ sender: AnyObject) {
        DAO.saveImageToUser(path: screenshotsPaths.last!)
    }
    
    @IBAction func didPressShareButton(_ sender: AnyObject) {
    }
    
    @IBAction func didPressMenuButton(_ sender: AnyObject) {
        removeAnimation()
    }
    
    
}

extension PopUpViewController {
    func addMenuButtonRecognizer() {
        let menuTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handlePressMenuButton))
        menuTapGestureRecognizer.allowedPressTypes = [NSNumber(integerLiteral: UIPressType.menu.rawValue)]
        self.view.addGestureRecognizer(menuTapGestureRecognizer)
    }
    
    
    func handlePressMenuButton() {
        removeAnimation()
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [playButton, menuButton, clearAllButton, saveButton, shareButton]
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        super.didUpdateFocus(in: context, with: coordinator)
        
        guard let nextFocusedView = context.nextFocusedView else { return }
        
        switch nextFocusedView {
            
        case playButton:
            coordinator.addCoordinatedAnimations({ () -> Void in
                
                self.customFocus(previouslyFocused: self.shareButton, nextFocused: self.playButton, context: context)
                
                }, completion: nil)
            
        case menuButton:
            coordinator.addCoordinatedAnimations({ () -> Void in
                
                self.customFocus(previouslyFocused: self.playButton, nextFocused: self.menuButton, context: context)
                
                }, completion: nil)
            
        case clearAllButton:
            coordinator.addCoordinatedAnimations({ () -> Void in
                
                self.customFocus(previouslyFocused: self.menuButton, nextFocused: self.clearAllButton, context: context)
                
                }, completion: nil)
            
        case saveButton:
            coordinator.addCoordinatedAnimations({ () -> Void in
                
                self.customFocus(previouslyFocused: self.clearAllButton, nextFocused: self.saveButton, context: context)
                
                }, completion: nil)
            
        case shareButton:
            coordinator.addCoordinatedAnimations({ () -> Void in
                
                self.customFocus(previouslyFocused: self.saveButton, nextFocused: self.shareButton, context: context)
                
                }, completion: nil)
        default:
            return
        }
    }
    
    func customFocus(previouslyFocused: UIButton, nextFocused: UIButton, context: UIFocusUpdateContext) {
        
        nextFocused.layer.shouldRasterize = true
        nextFocused.layer.shadowColor = UIColor.black.cgColor
        nextFocused.layer.shadowOpacity = 0.5
        nextFocused.layer.shadowRadius = 25
        nextFocused.layer.shadowOffset = CGSize(width: 0, height: 16)
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            nextFocused.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        })
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            previouslyFocused.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
        
        context.previouslyFocusedView?.layer.shadowOffset = CGSize.zero
        context.previouslyFocusedView?.layer.shadowColor = UIColor.clear.cgColor
    }
}

extension PopUpViewController {
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
