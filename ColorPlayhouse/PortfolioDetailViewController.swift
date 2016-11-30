//
//  PortfolioDetailViewController.swift
//  ColorPlayhouse
//
//  Created by Priscila Rosa on 11/28/16.
//  Copyright © 2016 Aleixo Rosa & Crispim. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class PortfolioDetailViewController: UIViewController {
    
    var recordID: String!
    var selectedImage: UIImage!
    var videoData: NSData!

    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var play: UIButton!
    @IBOutlet weak var share: UIButton!
    
    let DAO = DataAccessObject.sharedInstance
    
    @IBAction func playClick(_ sender: AnyObject) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let destinationPath = NSURL(fileURLWithPath: documentsPath).appendingPathComponent("filename.mov", isDirectory: false) //This is where I messed up.
        
        FileManager.default.createFile(atPath: destinationPath!.path, contents: videoData as Data?, attributes:nil)
        
        let videoURL = destinationPath
        
        self.playVideo(videoOutputURL: videoURL!)
    }
    
    private func playVideo(videoOutputURL: URL) {
        let player = AVPlayer(url: videoOutputURL)
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
        }
    }
    
    @IBAction func shareClick(_ sender: AnyObject) {
    }
    

    @IBAction func deleteClick(_ sender: AnyObject) {
        DAO.deleteRecord(WithID: recordID) { success in
            if success {
                let defaults = UserDefaults.standard
                var numberOfArtwork = defaults.object(forKey: "numberOfArtwork") as! Int
                numberOfArtwork -= 1
                defaults.set(numberOfArtwork, forKey: "numberOfArtwork")
                
                self.dismiss(animated: true, completion: nil)
            } else {
                self.showErrorDeletingAlert()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

       detailImageView.image = selectedImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        super.didUpdateFocus(in: context, with: coordinator)
        
        guard let nextFocusedView = context.nextFocusedView else { return }
        guard let previouslyFocusedView = context.previouslyFocusedView else { return }
        
        customFocus(previouslyFocused: previouslyFocusedView,
                    nextFocused: nextFocusedView,
                    context: context)
    }
    
    func customFocus(previouslyFocused: UIView, nextFocused: UIView, context: UIFocusUpdateContext) {
        
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

    func showErrorDeletingAlert() {
        let alertController = UIAlertController(title: "Error", message: "Oops! An error ocurred when deleting your artwork.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

}
