//
//  Configurator.swift
//  ColorPlayhouse
//
//  Created by Victor Yves Crispim on 01/5/17.
//  Copyright © 2017 Aleixo Rosa & Crispim. All rights reserved.
//

import UIKit


struct Configurator
{
	func installRootViewControllerInto(window: UIWindow) {
		
		let menuRouter = MainMenuRouter()
		menuRouter.presentMenuSceneFrom(window: window)
	}
}

