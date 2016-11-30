//
//  PortfolioDetailViewController.swift
//  ColorPlayhouse
//
//  Created by Priscila Rosa on 11/28/16.
//  Copyright © 2016 Aleixo Rosa & Crispim. All rights reserved.
//

import UIKit

class PortfolioDetailViewController: UIViewController {
    
    var selectedImage: UIImage!

    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var play: UIButton!
    @IBOutlet weak var share: UIButton!
    
    @IBAction func playClick(_ sender: AnyObject) {
    }
    @IBAction func shareClick(_ sender: AnyObject) {
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


}
