//
//  MainMenuViewController.swift
//  ColorPlayhouse
//
//  Created by Priscila Rosa on 11/8/16.
//  Copyright © 2016 Priscila Rosa. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController
{
    var router: MainMenuRouter?

    var delegate: MainMenuDelegate?

    @IBOutlet weak var newDrawingOutlet: UIButton!
    
    @IBOutlet weak var myPortfolioOutlet: UIButton!
    
    @IBAction func myPortfolio(_ sender: AnyObject) {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router?.passDataToNextScene(segue)
    }
    
    @IBAction func newDrawing(_ sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        super.didUpdateFocus(in: context, with: coordinator)
        
        guard let nextFocusedView = context.nextFocusedView else { return }
        
        switch nextFocusedView {
        
        case newDrawingOutlet:
            coordinator.addCoordinatedAnimations({ () -> Void in
                //self.tintColor = .white
                self.newDrawingOutlet.layer.shadowColor = UIColor.blue.cgColor
                self.newDrawingOutlet.layer.shadowOpacity = 1
                self.newDrawingOutlet.layer.shadowRadius = 10
                self.newDrawingOutlet.layer.shadowOffset = CGSize(width: 0, height: 3)
                
                 context.previouslyFocusedView?.layer.shadowOffset = CGSize.zero
                 context.previouslyFocusedView?.layer.shadowColor = UIColor.clear.cgColor
                
                }, completion: nil)
            
        case myPortfolioOutlet:
            coordinator.addCoordinatedAnimations({ () -> Void in
                //self.tintColor = .white
                self.myPortfolioOutlet.layer.shadowColor = UIColor.blue.cgColor
                self.myPortfolioOutlet.layer.shadowOpacity = 1
                self.myPortfolioOutlet.layer.shadowRadius = 10
                self.myPortfolioOutlet.layer.shadowOffset = CGSize(width: 0, height: 3)
                
                context.previouslyFocusedView?.layer.shadowOffset = CGSize.zero
                context.previouslyFocusedView?.layer.shadowColor = UIColor.clear.cgColor
                
                }, completion: nil)
        default:
            return
        }
    }
}
