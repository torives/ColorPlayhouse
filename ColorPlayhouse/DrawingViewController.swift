//
//  DrawingViewController.swift
//  ColorPlayhouse
//
//  Created by Victor Yves Crispim on 11/5/16.
//  Copyright © 2016 Aleixo Rosa & Crispim. All rights reserved.
//

import UIKit

class DrawingViewController: UIViewController {
	
	//MARK: - Properties
	//MARK: Outlets
	
	@IBOutlet weak var pointer: UIImageView!
	@IBOutlet weak var palette: UIImageView!
    @IBOutlet weak var canvasView: UIView!
	
	@IBOutlet var drawingTools: [UIButton]!
	@IBOutlet var paletteColors: [UIButton]!
	
	@IBOutlet weak var toolsConstraintToTrailing: NSLayoutConstraint!
	@IBOutlet weak var paletteConstraintToBottom: NSLayoutConstraint!
	@IBOutlet weak var colorsConstraintToBottom: NSLayoutConstraint!
	
	//MARK: - Public Properties
	
	override var preferredFocusEnvironments: [UIFocusEnvironment] {

		if paletteIsActive {
			guard let _ = selectedColor else { return [] }
			return [selectedColor!]
		}
		else if toolsIsActive {
			guard let _ = selectedTool else { return [] }
			return [selectedTool!]
		}
		else if popupIsOpen {
			guard let _ = childViewControllers.first else { return [] }
			return childViewControllers.first!.view.subviews
		}
		else { return [] }
	}
	
	//MARK: - Private Properties
	
	private let DAO = DataAccessObject.sharedInstance
	private var timer: Timer!
	private var screenshotsPaths = [String]()
	
	private var paletteIsActive = false
	private var toolsIsActive = false
	private var popupIsOpen = false
	
	private var selectedColor: UIButton?
	private var selectedTool: UIButton?
	
	private var drawingGesture: UIPanGestureRecognizer?
	private var menuButtonTap: UITapGestureRecognizer?
	
	private var _eraserEnabled: Bool = false
	private var _drawingStruct: DrawingStruct = DrawingStruct()
	private weak var currentDrawingElement: DrawingElement?
	private var _elements: Array<UIView> = Array<UIView>()
	
	
	//MARK: - Methods
	
	override func viewDidLoad() {
		
		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(printScreen), userInfo: nil, repeats: true)
		
		selectedColor = paletteColors[0]
		selectedTool = drawingTools[0]
		
		paletteConstraintToBottom.constant = -205
		colorsConstraintToBottom.constant = -168
		toolsConstraintToTrailing.constant = -404
		
		configureUserInteraction()
        
        setupCanvas()
	}
	
	
	//MARK: - IBAction Methods
	
	@IBAction func colorClick(_ sender: UIButton) {
		
		UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
			self.paletteConstraintToBottom.constant = -205
			self.colorsConstraintToBottom.constant = -168
			self.view.layoutIfNeeded()
		}, completion: nil)
		
		if let buttonColor = sender.accessibilityLabel { updateToolColor(withColor: buttonColor) }
		else { print("Palette button's color not configured properly") }
		
		paletteIsActive = false
		setNeedsFocusUpdate()
	}
	
	@IBAction func toolClick(_ sender: AnyObject) {
		
		UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
			self.toolsConstraintToTrailing.constant = -430
			self.view.layoutIfNeeded()
		}, completion: nil)
		
		toolsIsActive = false
		setNeedsFocusUpdate()
	}
    
    //MARK: Interface 
    
    func setupCanvas() {
        
        canvasView.layer.cornerRadius = 20
        canvasView.layer.shadowOpacity = 0.1
        canvasView.layer.shadowColor = UIColor.black.cgColor
        canvasView.layer.shadowOffset = CGSize(width: 10, height: 10)
        canvasView.layer.shadowRadius = 0
        canvasView.layer.shouldRasterize = true
    }
	
	
	//MARK: Controller Button Actions
	
	@objc private func menuButtonWasPressed() {
		
		if popupIsOpen {
			dismissPopUp()
			
			view.gestureRecognizers?.forEach({$0.isEnabled = true})
			popupIsOpen = false
    
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(printScreen), userInfo: nil, repeats: true)
        } else {
            timer.invalidate()
            self.dismiss(animated: true, completion: nil)
        }
	}
	
	@objc private func playButtonWasPressed() {
		
		timer.invalidate()

		view.gestureRecognizers?.forEach({$0.isEnabled = false})
		menuButtonTap?.isEnabled = true
		popupIsOpen = true
		
		presentPopUp()
	}
	
	@objc private func selectButtonWasPressed() { drawingGesture?.isEnabled = !drawingGesture!.isEnabled }
	
	
	//MARK: Focus Handling
		
	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		
		guard let nextFocusedView = context.nextFocusedView else { return }
		
		if toolsIsActive {
			selectedTool = drawingTools.first(where: {$0 == nextFocusedView})
			updatePointerImage(for: selectedTool)
		}
		else if paletteIsActive {
			selectedColor = paletteColors.first(where: {$0 == nextFocusedView})
		}
	}
	
	//MARK: Interface Gesture Handling
	
	func controlCanvas(with gesture: UISwipeGestureRecognizer) {
		
		defer { setNeedsFocusUpdate() }
		
		switch gesture.direction {
			
			case UISwipeGestureRecognizerDirection.left:
				
				if paletteIsActive { return }
					
				UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
					self.toolsConstraintToTrailing.constant = 0
					self.view.layoutIfNeeded()
				},
				completion: nil)
				
				self.toolsIsActive = true
				self.shouldEnableInteraction(on: self.drawingTools, option: true)
			
			case UISwipeGestureRecognizerDirection.up:
				
				if toolsIsActive { return }
					
				UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
					self.paletteConstraintToBottom.constant = 0
					self.colorsConstraintToBottom.constant = 60
					self.view.layoutIfNeeded()
				},
			   completion: nil)
			
				self.paletteIsActive = true
				self.shouldEnableInteraction(on: self.paletteColors, option: true)
			
			case UISwipeGestureRecognizerDirection.right:
				
				guard toolsIsActive else { return }
					
				UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
					self.toolsConstraintToTrailing.constant = -430
					self.view.layoutIfNeeded()
				},
				completion: nil)
			
				self.toolsIsActive = false
				self.shouldEnableInteraction(on: self.drawingTools, option: false)
			
			case UISwipeGestureRecognizerDirection.down:
				
				guard paletteIsActive else { return }
					
				UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
					
					self.paletteConstraintToBottom.constant = -205
					self.colorsConstraintToBottom.constant = -168
					self.view.layoutIfNeeded()
				},
				completion: nil)
			
				self.paletteIsActive = false
				self.shouldEnableInteraction(on: self.paletteColors, option: false)

			
			default: break
		}
	}
	
	
	//MARK: - Drawing Gesture Handling
	
	func finishDrawing() {
		if let drawingElement = currentDrawingElement {
			if(drawingElement.frame.isEmpty) {
				drawingElement.removeFromSuperview()
			}
		}
		currentDrawingElement = nil
	}
	
	func updateDrawing(drawingStruct: DrawingStruct) {
		
		if let drawingElement = currentDrawingElement {
			drawingElement.updateDrawingStruct(drawingStruct: drawingStruct)
		}
		else {
			let drawing = DrawingElement(drawingStruct: drawingStruct)
			drawing.frame = canvasView.frame
			self.canvasView.addSubview(drawing)
			currentDrawingElement = drawing
		}
	}
	
	func processDrawingAttempt(with gesture: UIPanGestureRecognizer) {
		
		let point = gesture.location(in: self.view)
		
		guard self.canvasView.point(inside: point, with: nil) else { return }
		
		let newPoint = CGPoint(x: point.x + pointer.frame.width/2 + 25, y: point.y + pointer.frame.height/2)
		pointer.frame.origin = newPoint
		
		
		if selectedTool?.accessibilityLabel == "eraser" {
			updateDrawing(drawingStruct: eraserConfig())
		}
		drawWithGesture(gesture: gesture)
	}
	
	func drawWithGesture(gesture: UIPanGestureRecognizer) {
		
		let point = gesture.location(in: self.view)
		
		
		
		//self.pointer.frame.origin = point
		
		switch gesture.state {
			
		case .began:
			
			if let drawingElement = currentDrawingElement {
				drawingElement.beginDrawing(point: point)
			}
			else{
				let drawing = DrawingElement(drawingStruct: DrawingStruct())
				drawing.frame = canvasView.frame
				self.canvasView.addSubview(drawing)
				currentDrawingElement = drawing
				currentDrawingElement?.beginDrawing(point: point)
			}
		case .changed:
			currentDrawingElement?.moveDrawingPoint(point: point)
			
		case .ended:
			currentDrawingElement?.endDrawing(point: point)
			
		case .cancelled, .failed:
			currentDrawingElement?.cancelDrawing(point: point)
			
		default:
			break
		}
	}
	
	func eraseWithGesture(gesture: UIPanGestureRecognizer) {
		
		let point = gesture.location(in: self.view)
		//self.pointer.frame.origin = point
		
		switch gesture.state {
		case .began:
			currentDrawingElement?.beginErasing(point: point)
			
		case .changed:
			currentDrawingElement?.moveErasingPoint(point: point)
			
		case .ended:
			currentDrawingElement?.endErasing(point: point)
			
		case .cancelled , .failed:
			currentDrawingElement?.cancelErasing(point: point)
			
		default:
			break
		}
	}
	
	
	//MARK: Timelapse Functions
	
	private func showTimelapsePopUp() {
		
		timer.invalidate()
		
		let popUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popUpVC") as! PopUpViewController
		popUpVC.screenshotsPaths = self.screenshotsPaths
		self.addChildViewController(popUpVC)
		
		popUpVC.view.frame = self.view.frame
		self.view.addSubview(popUpVC.view)
		popUpVC.didMove(toParentViewController: self)
	}
	
	@objc private func printScreen() {
		
		var window: UIWindow? = UIApplication.shared.keyWindow
		window = UIApplication.shared.windows[0] as UIWindow
		
		let backgroundQueue = DispatchQueue(label: "SnapshotQueue",
		                                    qos: .background,
		                                    target: nil)
		backgroundQueue.async {
			
			UIGraphicsBeginImageContextWithOptions(window!.frame.size, window!.isOpaque, 0.0)
			window!.layer.render(in: UIGraphicsGetCurrentContext()!)
			let screenShot = UIGraphicsGetImageFromCurrentImageContext()!
			UIGraphicsEndImageContext()
			
			self.saveImageToDocumentsDirectory(image: screenShot)
		}
	}
	
	private func saveImageToDocumentsDirectory(image: UIImage) {
		
		let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
		let documentsDirectory = paths[0]
		let path = NSURL(fileURLWithPath: documentsDirectory).appendingPathComponent("image\(screenshotsPaths.count)")
		print(path?.absoluteString)
		
		screenshotsPaths.append((path?.absoluteString)!)
		let data = UIImagePNGRepresentation(image)
		try! data?.write(to: path!, options: .atomic)
	}
	
	//MARK: Auxiliary Functions
	
	private func configureUserInteraction() {
		
		//Add controller buttons
		menuButtonTap = UITapGestureRecognizer(target: self, action: #selector(menuButtonWasPressed))
		menuButtonTap?.allowedPressTypes = [NSNumber(value: UIPressType.menu.rawValue)]
		self.view.addGestureRecognizer(menuButtonTap!)
		
		let playButtonTap = UITapGestureRecognizer(target: self, action: #selector(playButtonWasPressed))
		playButtonTap.allowedPressTypes = [NSNumber(value: UIPressType.playPause.rawValue)]
		self.view.addGestureRecognizer(playButtonTap)
		
		let selectButtonTap = UITapGestureRecognizer(target: self, action: #selector(selectButtonWasPressed))
		selectButtonTap.allowedPressTypes = [NSNumber(value: UIPressType.select.rawValue)]
		self.view.addGestureRecognizer(selectButtonTap)
		
		
		//Add drawing gesture
		drawingGesture = UIPanGestureRecognizer(target: self, action: #selector(processDrawingAttempt(with:)))
		drawingGesture?.isEnabled = false
		view.addGestureRecognizer(drawingGesture!)
		
		
		//Add canvas control gestures
		let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(controlCanvas(with:)))
		swipeLeft.direction = .left
		self.view.addGestureRecognizer(swipeLeft)
		
		let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(controlCanvas(with:)))
		swipeRight.direction = .right
		self.view.addGestureRecognizer(swipeRight)
		
		let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(controlCanvas(with:)))
		swipeUp.direction = .up
		self.view.addGestureRecognizer(swipeUp)
		
		let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(controlCanvas(with:)))
		swipeDown.direction = .down
		self.view.addGestureRecognizer(swipeDown)
		
		
		//Set defaults
		selectedTool = drawingTools.first(where: {$0.accessibilityLabel == "pencil"})
		updatePointerImage(for: selectedTool)
		
		selectedColor = paletteColors.first(where: {$0.accessibilityLabel == "blue"})
		
		
		//Disable focus
		shouldEnableInteraction(on: paletteColors, option: false)
		shouldEnableInteraction(on: drawingTools, option: false)
	}
	
	private func shouldEnableInteraction(on views: [UIView], option: Bool) {
		views.forEach({$0.isUserInteractionEnabled = option})
	}
	
	private func updatePointerImage(for tool: UIButton?) {
		
		switch tool?.backgroundImage(for: .normal) {
		case #imageLiteral(resourceName: "pencil")?:
			pointer.image = UIImage(named: "pencil_pointer")
		case #imageLiteral(resourceName: "brush")?:
			pointer.image = UIImage(named: "brush_pointer")
		case #imageLiteral(resourceName: "eraser")?:
			pointer.image = UIImage(named: "eraser_pointer")
		case #imageLiteral(resourceName: "crayon")?:
			pointer.image = UIImage(named: "crayon_pointer")
		default:
			return
		}
	}
	
	private func updateToolColor(withColor color: String) {
		
		defer { updateDrawing(drawingStruct: _drawingStruct) }
		
		switch color {
		case PenColor.blue.rawValue:
			_drawingStruct.color = PenColor.blue.value()
			
		case PenColor.darkOrange.rawValue:
			_drawingStruct.color = PenColor.darkOrange.value()
			
		case PenColor.green.rawValue:
			_drawingStruct.color = PenColor.green.value()
			
		case PenColor.lightBlue.rawValue:
			_drawingStruct.color = PenColor.lightBlue.value()
			
		case PenColor.lightGreen.rawValue:
			_drawingStruct.color = PenColor.lightGreen.value()
			
		case PenColor.magenta.rawValue:
			_drawingStruct.color = PenColor.magenta.value()
			
		case PenColor.orange.rawValue:
			_drawingStruct.color = PenColor.orange.value()
			
		case PenColor.purple.rawValue:
			_drawingStruct.color = PenColor.purple.value()
			
		case PenColor.red.rawValue:
			_drawingStruct.color = PenColor.red.value()
			
		case PenColor.yellow.rawValue:
			_drawingStruct.color = PenColor.yellow.value()
			
		default:
			print("Unknown color on palette's button")
		}
	}
	
	private func eraserConfig() -> DrawingStruct {
		
		var config = DrawingStruct()
		config.color = UIColor.white
		config.lineWidth = 25
		
		return config
	}
	
	//MARK: PopUp Methods
	
	private func presentPopUp() {
		
		let popUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popUpVC") as! PopUpViewController
		popUpVC.screenshotsPaths = self.screenshotsPaths
		
		self.addChildViewController(popUpVC)
		
		popUpVC.view.frame = self.view.frame
		self.view.addSubview(popUpVC.view)
		
		popUpVC.didMove(toParentViewController: self)
		
		shouldEnableInteraction(on: paletteColors, option: false)
		shouldEnableInteraction(on: drawingTools, option: false)
	}
	
	private func dismissPopUp() {
		
		let popUp = self.childViewControllers.first
		
		UIView.animate(withDuration: 0.25, animations: {
			popUp?.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
			popUp?.view.alpha = 0
		},
			completion: { (isFinished) in
						
				if isFinished{
					popUp?.willMove(toParentViewController: self)
					popUp?.view.removeFromSuperview()
					popUp?.removeFromParentViewController()
					
					self.shouldEnableInteraction(on: self.paletteColors, option: true)
					self.shouldEnableInteraction(on: self.drawingTools, option: true)
				}
		})
	}
}


//MARK: - Gesture Handling Legacy Types

//  FIX-ME:
//  These types are here for compatibility reasons with the drawing algorithm currently being used.
//  They are not necessarily useful and certaily should be removed from this file.

protocol DrawingCanvasTool
{
	func updateDrawing(drawingStruct : DrawingStruct)
	func finishDrawing()
	func drawWithGesture(gesture : UIPanGestureRecognizer)
	func eraseWithGesture(gesture : UIPanGestureRecognizer)
}

// Stroke appearance definition.
// FF is the default width, LOWER is the minimum and UPPER is the maximum.
// Increase the UPPER's value to get a thinner stroke.
struct DrawingStruct
{
	var lineWidth: CGFloat
	var lower: CGFloat
	var upper: CGFloat
	var ff: CGFloat
	
	var color: UIColor
	
	var shouldThin: Bool
	var fadeOpacity: Float
	
	init() {
		// Dummy values
		lineWidth = 5.0
		lower = 0.01
		upper = LineThickness.Thin.rawValue
		ff = 0.2
		
		color = PenColor.blue.value()
		
		shouldThin = true
		
		fadeOpacity = 0.3
	}
}

enum LineThickness: CGFloat
{
	case Thin = 5.0
	case Thick = 1.0
}

enum PenColor: String
{
	case purple = "purple"
	case magenta = "magenta"
	case red = "red"
	case darkOrange = "darkOrange"
	case orange = "orange"
	case yellow = "yellow"
	case lightGreen = "lightGreen"
	case green = "green"
	case lightBlue = "lightBlue"
	case blue = "blue"
	
	func value() -> UIColor {
		
		switch self {
			
		case .purple:
			return UIColor(colorLiteralRed: 147/255, green: 39/255, blue: 143/255, alpha: 1)
		case .magenta:
			return UIColor(colorLiteralRed: 212/255, green: 21/255, blue: 91/255, alpha: 1)
		case .red:
			return UIColor(colorLiteralRed: 237/255, green: 28/255, blue: 35/255, alpha: 1)
		case .darkOrange:
			return UIColor(colorLiteralRed: 241/255, green: 90/255, blue: 36/255, alpha: 1)
		case .orange:
			return UIColor(colorLiteralRed: 251/255, green: 176/255, blue: 59/255, alpha: 1)
		case .yellow:
			return UIColor(colorLiteralRed: 252/255, green: 238/255, blue: 34/255, alpha: 1)
		case .lightGreen:
			return UIColor(colorLiteralRed: 139/255, green: 198/255, blue: 63/255, alpha: 1)
		case .green:
			return UIColor(colorLiteralRed: 58/255, green: 181/255, blue: 73/255, alpha: 1)
		case .lightBlue:
			return UIColor(colorLiteralRed: 41/255, green: 171/255, blue: 226/255, alpha: 1)
		case .blue:
			return UIColor(colorLiteralRed: 0/255, green: 113/255, blue: 189/255, alpha: 1)
		}
	}
}
