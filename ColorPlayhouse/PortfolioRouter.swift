//
//  PortfolioRouter.swift
//  ColorPlayhouse
//
//  Created by Victor Yves Crispim on 01/5/17.
//  Copyright © 2017 Aleixo Rosa & Crispim. All rights reserved.
//

import UIKit


final class PortfolioRouter
{
	weak var portfolioViewController: PortfolioViewController?
	
	func presentPortfolioSceneFrom(viewController: UIViewController) {
		
		let portfolioViewController = portfolioViewControllerFromStoryboard()
		let portfolioPresenter = PortfolioPresenter(viewController: portfolioViewController, router: self)
		
		self.portfolioViewController = portfolioViewController
		portfolioViewController.eventHandler = portfolioPresenter
		
		viewController.present(portfolioViewController, animated: true, completion: nil)
	}
	
	func presentPortfolioDetailScene(){
		
	}
	
	private func portfolioViewControllerFromStoryboard() -> PortfolioViewController {
		
		let storyboard = UIStoryboard(name: "Portfolio", bundle: Bundle.main)
		let viewController = storyboard.instantiateViewController(withIdentifier: "PortfolioViewController") as! PortfolioViewController
		
		return viewController
	}
}
