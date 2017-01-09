//
//  DrawingCanvasRouter.swift
//  ColorPlayhouse
//
//  Created by Victor Yves Crispim on 01/5/17.
//  Copyright © 2017 Aleixo Rosa & Crispim. All rights reserved.
//

import UIKit


final class DrawingCanvasRouter
{
	weak var drawingCanvasViewController: DrawingCanvasViewController?
	
	func presentDrawingScene(from viewController: UIViewController) {
		
		let drawingCanvasViewController = drawingCanvasViewControllerFromStoryboard()
		let drawingPresenter = DrawingCanvasPresenter(router: self)
		
		self.drawingCanvasViewController = drawingCanvasViewController
		drawingCanvasViewController.eventHandler = drawingPresenter
		
		viewController.present(drawingCanvasViewController, animated: true, completion: nil)
	}
	
	func presentDrawingCanvasPopUpMenu() {}
	
	
	private func drawingCanvasViewControllerFromStoryboard() -> DrawingCanvasViewController {
		
		let storyboard = UIStoryboard(name: "Drawing", bundle: Bundle.main)
		let viewController = storyboard.instantiateViewController(withIdentifier: "DrawingCanvasViewController") as! DrawingCanvasViewController
		
		return viewController
	}
}
