//
//  PortfolioCell.swift
//  ColorPlayhouse
//
//  Created by Priscila Rosa on 11/18/16.
//  Copyright © 2016 Aleixo Rosa & Crispim. All rights reserved.
//

import Foundation
import UIKit

class PortfolioCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIRemoteImageView!

    var item:Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //imageView.adjustsImageWhenAncestorFocused = true
        
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        if context.nextFocusedView == self {
            coordinator.addCoordinatedAnimations({ () -> Void in
                //self.tintColor = .white
                self.layer.shadowColor = UIColor.black.cgColor
                self.layer.shadowOpacity = 0.5
                self.layer.shadowRadius = 25
                self.layer.shadowOffset = CGSize(width: 0, height: 16)
                }, completion: nil)
            
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            })

        }
            
        else if context.previouslyFocusedView == self {
            coordinator.addCoordinatedAnimations ({ () -> Void in
                self.layer.shadowOffset = CGSize.zero
                self.layer.shadowOpacity = 0.2
                self.layer.shadowColor = UIColor.black.cgColor
                self.layer.shadowRadius = 20
                }, completion: nil)
            
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
            
        }
    }
}
