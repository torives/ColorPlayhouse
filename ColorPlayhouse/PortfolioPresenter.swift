//
//  PortfolioPresenter.swift
//  ColorPlayhouse
//
//  Created by Victor Yves Crispim on 01/5/17.
//  Copyright © 2017 Aleixo Rosa & Crispim. All rights reserved.
//

import Foundation


protocol PortfolioInterface {}
protocol PortfolioEventHandler {}


final class PortfolioPresenter {
	
	//	This reference could cause a problem
	var interface: PortfolioInterface
	fileprivate let router: PortfolioRouter
	
	init(viewController: PortfolioInterface, router: PortfolioRouter) {
	
		self.interface = viewController
		self.router = router
	}
}

extension PortfolioViewController: PortfolioInterface {}
extension PortfolioPresenter: PortfolioEventHandler{}
