//
//  MainMenuViewController.swift
//  ColorPlayhouse
//
//  Created by Priscila Rosa on 11/8/16.
//  Copyright © 2016 Priscila Rosa. All rights reserved.
//

import UIKit
import CloudKit

class MainMenuViewController: UIViewController
{
    var router: MainMenuRouter?

    @IBOutlet weak var newDrawingOutlet: UIButton!
    @IBOutlet weak var myPortfolioOutlet: UIButton!
    
    
    let DAO = DataAccessObject.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authenticateUser()
        // Do any additional setup after loading the view.
    }

    func authenticateUser() {
        CKContainer.default().accountStatus { (accountStatus, error) in
            if accountStatus == .noAccount {
                self.presentCloudKitAlertController()
            }
            // user logged in
            else {
                let defaults = UserDefaults.standard
                
                // user does not exist
                if defaults.object(forKey: "userID") == nil {
                    self.DAO.createUser()
                }
            }
        }

    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        super.didUpdateFocus(in: context, with: coordinator)
        
        guard let nextFocusedView = context.nextFocusedView else { return }
        
        switch nextFocusedView {
        
        case newDrawingOutlet:
            coordinator.addCoordinatedAnimations({ () -> Void in

                self.customFocus(previouslyFocused: self.myPortfolioOutlet, nextFocused: self.newDrawingOutlet, context: context)
     
                }, completion: nil)
            
        case myPortfolioOutlet:
            coordinator.addCoordinatedAnimations({ () -> Void in

                self.customFocus(previouslyFocused: self.newDrawingOutlet, nextFocused: self.myPortfolioOutlet, context: context)
                
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

//MARK:- Segue Handling
extension MainMenuViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router?.passDataToNextScene(segue)
    }
}


//MARK:- Alert Controller
extension MainMenuViewController {
    
    func presentCloudKitAlertController() {
        let alertController = UIAlertController(title: NSLocalizedString("LOGIN_ICLOUD_TITLE", comment: ""), message: NSLocalizedString("LOGIN_ICLOUD_MESSAGE", comment: ""), preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
            let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsURL {
                UIApplication.shared.openURL(url as URL)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
