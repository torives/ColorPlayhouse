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

    func showErrorDeletingAlert() {
        let alertController = UIAlertController(title: "Error", message: "Oops! An error ocurred when deleting your artwork.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

}
