//
//  DrawingCanvasPresenter.swift
//  ColorPlayhouse
//
//  Created by Victor Yves Crispim on 01/5/17.
//  Copyright © 2017 Aleixo Rosa & Crispim. All rights reserved.
//

import Foundation


protocol DrawingCanvasEventHandler {}


final class DrawingCanvasPresenter
{
	let router: DrawingCanvasRouter
	
	init(router: DrawingCanvasRouter) {
		self.router = router
	}
}

extension DrawingCanvasPresenter: DrawingCanvasEventHandler{}
