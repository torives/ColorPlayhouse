//
//  LastTutorialPageViewController.swift
//  ColorPlayhouse
//
//  Created by Bruna Aleixo on 12/7/16.
//  Copyright © 2016 Aleixo Rosa & Crispim. All rights reserved.
//

import UIKit

class LastTutorialPageViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var goButton: CPFocusableButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        let playButtonTap = UITapGestureRecognizer(target: self, action: #selector(playButtonWasPressed))
        playButtonTap.allowedPressTypes = [NSNumber(value: UIPressType.playPause.rawValue)]
        let parentVC = self.parent
        parentVC?.view.addGestureRecognizer(playButtonTap)
        
    }
    
    func playButtonWasPressed() {
        self.performSegue(withIdentifier: "showMainMenuVC", sender: self)
    }

}
