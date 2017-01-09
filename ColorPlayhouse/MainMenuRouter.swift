//
//  MainMenuRouter.swift
//  ColorPlayhouse
//
//  Created by Victor Yves Crispim on 11/5/16.
//  Copyright © 2016 Priscila Rosa. All rights reserved.
//

import UIKit


final class MainMenuRouter
{
	//	This reference must be kept in order to present the child view controllers
	private weak var mainMenuViewController: MainMenuViewController?
	
	func presentMenuInterfaceFrom(window: UIWindow) {
		
		let menuViewController = mainMenuViewControllerFromStoryboard()
		let menuPresenter = MainMenuPresenter(router: self)
		
		menuViewController.eventHandler = menuPresenter
		mainMenuViewController = menuViewController
		window.rootViewController = menuViewController
	}
	
	func presentDrawingScene() {
		
		let drawingRouter = DrawingCanvasRouter()
		
		guard let menuVC = mainMenuViewController else { return }
		drawingRouter.presentDrawingScene(from: menuVC)
	}
	
	func presentPortfolioScene() {
		
		let portfolioRouter = PortfolioRouter()
		
		guard let menuVC = mainMenuViewController else { return }
		portfolioRouter.presentPortfolioSceneFrom(viewController: menuVC)
	}
	
	
	private func mainMenuViewControllerFromStoryboard() -> MainMenuViewController {
		
		let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
		let viewController = storyboard.instantiateViewController(withIdentifier: "MainMenuViewController") as! MainMenuViewController
		
		return viewController
	}
}
