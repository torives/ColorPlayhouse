//
//  UIRemoteImageView.swift
//  Tavola
//
//  Created by Daniel Molina on 6/23/16.
//  Copyright © 2016 Tavola. All rights reserved.
//

import UIKit

class UIRemoteImageView: UIView {

    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var contentView: UIView!
    
    private func commonInit() {
        Bundle.main.loadNibNamed("UIRemoteImageView", owner: self, options: nil)
        guard let content = contentView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    /**
     Sets the image in the view and hides the activityIndicator.
     
     - parameter image The image that will be set.
     */
    func setImage(image: UIImage) {
        self.imageView.image = image
        self.imageView.contentMode = UIViewContentMode.scaleAspectFill
        
        self.activityIndicator.stopAnimating()
        self.imageView.isHidden = false
    }
    
    ///Sets the image to nil and animates activity indicator.
    func refresh() {
        self.imageView.image = nil
        
        self.activityIndicator.startAnimating()
        self.imageView.isHidden = true
    }
    
    func setImageAlpha(alpha: CGFloat) {
        self.imageView.alpha = alpha
    }
    
}
