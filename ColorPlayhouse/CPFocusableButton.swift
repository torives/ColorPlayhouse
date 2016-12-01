//
//  CPFocusableButton.swift
//  ColorPlayhouse
//
//  Created by Victor Yves Crispim on 12/5/16.
//  Copyright © 2016 Aleixo Rosa & Crispim. All rights reserved.
//

import UIKit

class CPFocusableButton: UIButton {
	
	override func didUpdateFocus(in context: UIFocusUpdateContext,
	                             with coordinator: UIFocusAnimationCoordinator) {
		
		guard let nextFocusedView = context.nextFocusedView else { return }
		let previouslyFocusedView = context.previouslyFocusedView
		
		nextFocusedView.layer.shouldRasterize = true
		
		nextFocusedView.layer.shadowOpacity = 0.5
		nextFocusedView.layer.shadowRadius = 25
		nextFocusedView.layer.shadowColor = UIColor.black.cgColor
		nextFocusedView.layer.shadowOffset = CGSize(width: 0, height: 16)
		
		coordinator.addCoordinatedAnimations({
			
			nextFocusedView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
			
			previouslyFocusedView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
			previouslyFocusedView?.layer.shadowOffset = CGSize.zero
			previouslyFocusedView?.layer.shadowColor = UIColor.clear.cgColor
		},
		completion: nil)
	}
}
