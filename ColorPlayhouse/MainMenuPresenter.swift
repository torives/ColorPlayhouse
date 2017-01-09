//
//  MainMenuPresenter.swift
//  ColorPlayhouse
//
//  Created by Victor Yves Crispim on 01/5/17.
//  Copyright © 2017 Aleixo Rosa & Crispim. All rights reserved.
//

import Foundation

protocol MainMenuEventHandler
{
	func newDrawingButtonPressed()
	func myPortfolioButtonPressed()
}

final class MainMenuPresenter
{
	fileprivate let router: MainMenuRouter
	
	init(router: MainMenuRouter) {
		self.router = router
	}
}

extension MainMenuPresenter: MainMenuEventHandler{
	
	func newDrawingButtonPressed() {
		router.presentDrawingCanvasScene()
	}
	
	func myPortfolioButtonPressed() {
		router.presentPortfolioScene()
	}
}
