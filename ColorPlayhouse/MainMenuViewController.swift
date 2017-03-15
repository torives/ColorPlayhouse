//
//  MainMenuViewController.swift
//  ColorPlayhouse
//
//  Created by Priscila Rosa on 11/8/16.
//  Copyright © 2016 Priscila Rosa. All rights reserved.
//

import UIKit
import CloudKit

class MainMenuViewController: UIViewController {
	
	var eventHandler: MainMenuEventHandler?

    @IBOutlet weak var newDrawingOutlet: UIButton!
    @IBOutlet weak var myPortfolioOutlet: UIButton!
    
    
	//let DAO = DataAccessObject.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
		//authenticateUser()
    }

	@IBAction func newDrawingButtonPressed(_ sender: Any) {
		eventHandler?.newDrawingButtonPressed()
	}
	
	@IBAction func myPortfolioButtonPressed(_ sender: Any) {
		eventHandler?.myPortfolioButtonPressed()
	}
	
//	func authenticateUser() {
//        CKContainer.default().accountStatus { (accountStatus, error) in
//            if accountStatus == .noAccount {
//                self.presentCloudKitAlertController()
//            }
//            // user logged in
//            else {
//                let defaults = UserDefaults.standard
//                
//                // user does not exist
//                if defaults.object(forKey: "userID") == nil {
//                    self.DAO.createUser()
//                }
//            }
//        }
//
//    }
}

//	TODO: Remove this forever
//MARK:- Segue Handling
//extension MainMenuViewController {
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        router?.passDataToNextScene(segue)
//    }
//}


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
