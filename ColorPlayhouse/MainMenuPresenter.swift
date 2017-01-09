//
//  MainMenuPresenter.swift
//  ColorPlayhouse
//
//  Created by Victor Yves Crispim on 01/5/17.
//  Copyright © 2017 Aleixo Rosa & Crispim. All rights reserved.
//

import Foundation

protocol MainMenuSceneEventHandler
{
	func presentDrawingScene()
	func presentPortfolioScene()
}

final class MainMenuPresenter
{
	let router: MainMenuRouter
	
	init(router: MainMenuRouter) {
		self.router = router
	}
}

extension MainMenuPresenter: MainMenuSceneEventHandler{
	
	func presentDrawingScene() {
		router.presentDrawingScene()
	}
	
	func presentPortfolioScene() {
		router.presentPortfolioScene()
	}
}
