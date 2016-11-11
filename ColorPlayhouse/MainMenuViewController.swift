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

    @IBOutlet weak var newDrawingOutlet: UIButton!
    @IBOutlet weak var myPortfolioOutlet: UIButton!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router?.passDataToNextScene(segue)
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        super.didUpdateFocus(in: context, with: coordinator)
        
        guard let nextFocusedView = context.nextFocusedView else { return }
        
        switch nextFocusedView {
        
        case newDrawingOutlet:
            coordinator.addCoordinatedAnimations({ () -> Void in
                //self.tintColor = .white
                self.newDrawingOutlet.layer.shouldRasterize = true
                self.newDrawingOutlet.layer.shadowColor = UIColor.black.cgColor
                self.newDrawingOutlet.layer.shadowOpacity = 0.5
                self.newDrawingOutlet.layer.shadowRadius = 25
                self.newDrawingOutlet.layer.shadowOffset = CGSize(width: 0, height: 16)
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.newDrawingOutlet.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                })
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.myPortfolioOutlet.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
                
                 context.previouslyFocusedView?.layer.shadowOffset = CGSize.zero
                 context.previouslyFocusedView?.layer.shadowColor = UIColor.clear.cgColor
                
                
                }, completion: nil)
            
        case myPortfolioOutlet:
            coordinator.addCoordinatedAnimations({ () -> Void in
                //self.tintColor = .white
                self.myPortfolioOutlet.layer.shouldRasterize = true
                self.myPortfolioOutlet.layer.shadowColor = UIColor.black.cgColor
                self.myPortfolioOutlet.layer.shadowOpacity = 0.5
                self.myPortfolioOutlet.layer.shadowRadius = 25
                self.myPortfolioOutlet.layer.shadowOffset = CGSize(width: 0, height: 16)
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.newDrawingOutlet.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.myPortfolioOutlet.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                })
                
                context.previouslyFocusedView?.layer.shadowOffset = CGSize.zero
                context.previouslyFocusedView?.layer.shadowColor = UIColor.clear.cgColor
                
                }, completion: nil)
        default:
            return
        }
    }
}
