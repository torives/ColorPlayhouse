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
    @IBOutlet weak var canvas: UIImageView!
    
    @IBOutlet var drawingTools: [UIButton]!
    @IBOutlet var paletteColors: [UIButton]!
    
    @IBOutlet weak var toolsConstraintToTrailing: NSLayoutConstraint!
    @IBOutlet weak var paletteConstraintToBottom: NSLayoutConstraint!
    @IBOutlet weak var colorsConstraintToBottom: NSLayoutConstraint!
    
    //MARK: - Public Properties
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        
        if paletteIsActive { return [selectedColor!] }
        else if toolsIsActive { return [selectedTool!] }
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
    }
    
    
    //MARK: - IBAction Methods
    
    @IBAction func colorClick(_ sender: AnyObject) {
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.paletteConstraintToBottom.constant = -205
            self.colorsConstraintToBottom.constant = -168
            self.view.layoutIfNeeded()
        }, completion: nil)
        
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
    
    
    //MARK: Controller Button Actions
  
    @objc private func menuButtonWasPressed(){
		
		if popupIsOpen {
		
			dismissPopUp()
			
			view.gestureRecognizers?.forEach({$0.isEnabled = true})
			menuButtonTap?.isEnabled = false
			popupIsOpen = false
		}
    }
    
    @objc private func playButtonWasPressed(){
        
        timer.invalidate()
		
		view.gestureRecognizers?.forEach({$0.isEnabled = false})
		menuButtonTap?.isEnabled = true
        popupIsOpen = true
		
		presentPopUp()
    }
    
    @objc private func selectButtonWasPressed(){ drawingGesture?.isEnabled = !drawingGesture!.isEnabled }

    
    //MARK: Focus Handling
    
    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        if toolsIsActive || paletteIsActive || popupIsOpen {
            return true
        }
        else{
            return false
        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        super.didUpdateFocus(in: context, with: coordinator)
		
		guard let nextFocusedView = context.nextFocusedView else { return }
		guard let previouslyFocusedView = context.previouslyFocusedView else { return }
		
		customFocus(previouslyFocused: previouslyFocusedView as! UIButton,
		            nextFocused: nextFocusedView as! UIButton,
		            context: context)
		
        if toolsIsActive || paletteIsActive {
            
            if paletteColors.contains(nextFocusedView as! UIButton) {
                selectedColor = nextFocusedView as? UIButton
            }
            
            if drawingTools.contains(nextFocusedView as! UIButton) {
                selectedTool = nextFocusedView as? UIButton
                
                switch selectedTool?.backgroundImage(for: .normal) {
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
        }
    }
    
    func customFocus(previouslyFocused: UIView, nextFocused: UIView, context: UIFocusUpdateContext) {
        
        nextFocused.layer.shouldRasterize = true
        nextFocused.layer.shadowColor = UIColor.black.cgColor
        nextFocused.layer.shadowOpacity = 0.5
        nextFocused.layer.shadowRadius = 25
        nextFocused.layer.shadowOffset = CGSize(width: 0, height: 16)
		
		UIView.animate(withDuration: 0.1, animations: { () -> Void in
            nextFocused.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        })
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            previouslyFocused.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
        
        context.previouslyFocusedView?.layer.shadowOffset = CGSize.zero
        context.previouslyFocusedView?.layer.shadowColor = UIColor.clear.cgColor
    }
    

    //MARK: Interface Gesture Handling
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            defer { setNeedsFocusUpdate() }
            
            switch swipeGesture.direction {
            
            case UISwipeGestureRecognizerDirection.left:
            
                if !paletteIsActive {
                    
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                        self.toolsConstraintToTrailing.constant = 0
                        self.view.layoutIfNeeded()
                        }, completion: nil)
                    
                    toolsIsActive = true
                }
                
            case UISwipeGestureRecognizerDirection.up:
                
                if toolsIsActive == false {
                    
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                        self.paletteConstraintToBottom.constant = 0
                        self.colorsConstraintToBottom.constant = 60
                        self.view.layoutIfNeeded()
                        }, completion: nil)
                   
                    paletteIsActive = true
                }
                
            case UISwipeGestureRecognizerDirection.right:
                
                if toolsIsActive{
        
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                        self.toolsConstraintToTrailing.constant = -430
                        self.view.layoutIfNeeded()
                        }, completion: nil)
                    
                    toolsIsActive = false
                }
                
            case UISwipeGestureRecognizerDirection.down:
        
                if paletteIsActive{
                    
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                        self.paletteConstraintToBottom.constant = -205
                        self.colorsConstraintToBottom.constant = -168
                        self.view.layoutIfNeeded()
                        }, completion: nil)
                    
                    paletteIsActive = false
                }
                
            default:
                break
            }
        }
    }
    
    
    //MARK: - Drawing Gesture Handling
    
//    func didReceiveTouch(gesture: UIPanGestureRecognizer){
//        
//        let point = gesture.location(in: view)
//        self.pointer.frame.origin = point
//
//        if canvas.point(inside: point, with: nil) {
//            
//            if gesture.state == .began {
//                updateDrawing(drawingStruct: _drawingStruct)
//            }
//            drawWithGesture(gesture: gesture)
//        }
//    }
	
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
            drawing.frame = canvas.frame
            self.canvas.addSubview(drawing)
            currentDrawingElement = drawing
        }
    }
    
    func drawWithGesture(gesture: UIPanGestureRecognizer) {
		
		let point = gesture.location(in: self.view)
		
		guard self.canvas.point(inside: point, with: nil) else {
			return
		}
		
		self.pointer.frame.origin = point

        switch gesture.state {

		case .began:
			
			if let drawingElement = currentDrawingElement {
				drawingElement.beginDrawing(point: point)
			}
			else{
				let drawing = DrawingElement(drawingStruct: DrawingStruct())
				drawing.frame = canvas.frame
				self.canvas.addSubview(drawing)
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
        
        for case let drawingElement as DrawingElement in _elements {
            
            switch gesture.state {
            case .began:
                drawingElement.beginErasing(point: gesture.location(in: self.view))
                
            case .changed:
                drawingElement.moveErasingPoint(point: gesture.location(in: self.view))
                
            case .ended:
                drawingElement.endErasing(point: gesture.location(in: self.view))
                
            case .cancelled , .failed:
                drawingElement.cancelErasing(point: gesture.location(in: self.view))
                
            default:
                break
            }
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
        setupControllerButtons()
        addDrawingGesture()
        addCanvasControlGestures()
    }
    
    private func setupControllerButtons(){
        
        menuButtonTap = UITapGestureRecognizer(target: self, action: #selector(menuButtonWasPressed))
        menuButtonTap?.allowedPressTypes = [NSNumber(value: UIPressType.menu.rawValue)]
        menuButtonTap?.isEnabled = false
        self.view.addGestureRecognizer(menuButtonTap!)
        
        let playButtonTap = UITapGestureRecognizer(target: self, action: #selector(playButtonWasPressed))
        playButtonTap.allowedPressTypes = [NSNumber(value: UIPressType.playPause.rawValue)]
        self.view.addGestureRecognizer(playButtonTap)
        
        let selectButtonTap = UITapGestureRecognizer(target: self, action: #selector(selectButtonWasPressed))
        selectButtonTap.allowedPressTypes = [NSNumber(value: UIPressType.select.rawValue)]
        self.view.addGestureRecognizer(selectButtonTap)
    }
    
    private func addDrawingGesture() {
        drawingGesture = UIPanGestureRecognizer(target: self, action: #selector(drawWithGesture(gesture:)))
        drawingGesture?.isEnabled = false
        view.addGestureRecognizer(drawingGesture!)
    }
    
    private func addCanvasControlGestures(){
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(gesture:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(gesture:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(gesture:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    //MARK: PopUp Methods
    
    private func presentPopUp() {
        
        let popUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popUpVC") as! PopUpViewController
        popUpVC.screenshotsPaths = self.screenshotsPaths
        
        self.addChildViewController(popUpVC)
        
        popUpVC.view.frame = self.view.frame
        self.view.addSubview(popUpVC.view)
        
        popUpVC.didMove(toParentViewController: self)
    }
    
    private func dismissPopUp() {
        
        let popUp = self.childViewControllers.first
        
        UIView.animate(withDuration: 0.25,
                       
            animations: {
                popUp?.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                popUp?.view.alpha = 0
            },
            
            completion: { (isFinished) in
            
                if isFinished{
                    popUp?.willMove(toParentViewController: self)
                    popUp?.view.removeFromSuperview()
                    popUp?.removeFromParentViewController()
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
		lineWidth = 1.0
		lower = 0.01
		upper = PenThickness.Thin.value()
		ff = 0.2
		
		color = PenColor.Black.value()
		
		shouldThin = true
		
		fadeOpacity = 0.3
	}
}

enum PenThickness: Float
{
	case Thin = 5.0
	case Thick = 1.0
	
	func value() -> CGFloat {
		return CGFloat(self.rawValue)
	}
	
	static let allValues = [Thin, Thick]
}

enum PenColor: String
{
	case Black
	case Red
	case Blue
	case Yellow
	case Green
	
	func value() -> UIColor {
		return PenColor.color[self]!
	}
	
	static let color = [Black : UIColor.black, Red : UIColor.red, Blue : UIColor.blue, Yellow : UIColor.yellow, Green : UIColor.green]
	
	static let allValues = [Black, Red, Blue, Yellow, Green]
}
