//
//  DrawingViewController.swift
//  ColorPlayhouse
//
//  Created by Victor Yves Crispim on 11/5/16.
//  Copyright © 2016 Aleixo Rosa & Crispim. All rights reserved.
//

import UIKit

class DrawingViewController: UIViewController {
    
    var paletteIsActive = false
    var toolsIsActive = false
    
    var selectedColor: UIButton?
    var selectedTool: UIButton?
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        
        if paletteIsActive {
            //return paletteColors
            return [selectedColor!]
        }
        else if toolsIsActive {
            //return drawingTools
            return [selectedTool!]
        }
        else {
            return []
        }
    }
    
    @IBOutlet weak var pointer: UIImageView!
    
    @IBOutlet weak var palette: UIImageView!
    @IBOutlet weak var canvas: UIImageView!
    
    @IBOutlet var drawingTools: [UIButton]!
    @IBOutlet var paletteColors: [UIButton]!
    
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
    
    @IBOutlet weak var toolsConstraintToTrailing: NSLayoutConstraint!
    @IBOutlet weak var paletteConstraintToBottom: NSLayoutConstraint!
    @IBOutlet weak var colorsConstraintToBottom: NSLayoutConstraint!
    
    
    private var _eraserEnabled: Bool = false
    private var _drawingStruct: DrawingStruct = DrawingStruct()
    private weak var _currentDrawingElement: DrawingElement?
    private var _elements: Array<UIView> = Array<UIView>()
    
    
    //    let DAO = DataAccessObject.sharedInstance
    
    //Code to take screenshot and save to database
    /*
     @IBAction func captureScreenShot(_ sender: AnyObject) {
     var window: UIWindow? = UIApplication.shared.keyWindow
     window = UIApplication.shared.windows[0] as UIWindow
     UIGraphicsBeginImageContextWithOptions(window!.frame.size, window!.isOpaque, 0.0)
     window!.layer.render(in: UIGraphicsGetCurrentContext()!)
     let screenShot = UIGraphicsGetImageFromCurrentImageContext()!
     UIGraphicsEndImageContext()
     
     DAO.saveImageToUser(image: screenShot)
     } */
    
    
    override func viewDidLoad() {
        
        selectedColor = paletteColors[0]
        selectedTool = drawingTools[0]

        drawingTools.forEach({$0.isHidden = true})
        paletteColors.forEach({$0.isHidden = true})
        palette.isHidden = true
        
        palette.isHidden = false
        paletteColors.forEach({$0.isHidden = false})
        paletteConstraintToBottom.constant = -205
        colorsConstraintToBottom.constant = -168
        drawingTools.forEach({$0.isHidden = false})
        toolsConstraintToTrailing.constant = -404
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(didReceiveTouch(gesture:)))
        view.addGestureRecognizer(gesture)
        
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
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                if !paletteIsActive {
                    
                    print("left swipe")
                    
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                        self.toolsConstraintToTrailing.constant = 0
                        self.view.layoutIfNeeded()
                        }, completion: nil)
                    
                    toolsIsActive = true
                    setNeedsFocusUpdate()
                }
                
                
            case UISwipeGestureRecognizerDirection.up:
                if toolsIsActive == false {
                    print("up swipe")
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                        self.paletteConstraintToBottom.constant = 0
                        self.colorsConstraintToBottom.constant = 60
                        self.view.layoutIfNeeded()
                        }, completion: nil)
                    paletteIsActive = true
                    setNeedsFocusUpdate()
                }
                print ("********")
                print (preferredFocusEnvironments.count)
                
            case UISwipeGestureRecognizerDirection.right:
                print ("right swipe")
                
                if toolsIsActive{
        
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                        self.toolsConstraintToTrailing.constant = -430
                        self.view.layoutIfNeeded()
                        }, completion: nil)
                    toolsIsActive = false
                    setNeedsFocusUpdate()
                }
                
            case UISwipeGestureRecognizerDirection.down:
        
                if paletteIsActive{
                    
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                        self.paletteConstraintToBottom.constant = -205
                        self.colorsConstraintToBottom.constant = -168
                        self.view.layoutIfNeeded()
                        }, completion: nil)
                    paletteIsActive = false
                    setNeedsFocusUpdate()
                }
                
            default:
                break
            }
        }
    }
    
    
    //MARK: - FOCUS
    
    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        if toolsIsActive || paletteIsActive{
            return true
        }
        else{
            return false
        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        super.didUpdateFocus(in: context, with: coordinator)
        
        if toolsIsActive || paletteIsActive {
            
            guard let nextFocusedView = context.nextFocusedView else { return }
            guard let previouslyFocusedView = context.previouslyFocusedView else { return }
        
            customFocus(previouslyFocused: previouslyFocusedView as! UIButton, nextFocused: nextFocusedView as! UIButton, context: context)
            print ("NEXT FOCUSED VIEW")
            print (nextFocusedView)
            
            if paletteColors.contains(nextFocusedView as! UIButton) {
                selectedColor = nextFocusedView as? UIButton
            }
            
            if drawingTools.contains(nextFocusedView as! UIButton) {
                selectedTool = nextFocusedView as? UIButton
            }
        }
    }
    
    
    func customFocus(previouslyFocused: UIButton, nextFocused: UIButton, context: UIFocusUpdateContext) {
        
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
    
    func didReceiveTouch(gesture: UIPanGestureRecognizer){
        
        //        if (_eraserEnabled) {
        //            eraseWithGesture(gesture: gesture)
        //        }
        //        else {
        
        
        let point = gesture.location(in: view)
        print("x:\(point.x) y:\(point.y)")
        
        self.pointer.frame.origin = point
        
        if canvas.point(inside: point, with: nil) {
            
            if gesture.state == .began {
                updateDrawing(drawingStruct: _drawingStruct)
            }
            drawWithGesture(gesture: gesture)
        }
        //        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {}
    
    
    
    
    func finishDrawing() {
        if let drawingElement = _currentDrawingElement {
            if(drawingElement.frame.isEmpty) {
                drawingElement.removeFromSuperview()
            }
        }
        _currentDrawingElement = nil
    }
    
    func updateDrawing(drawingStruct: DrawingStruct) {
        if let drawingElement = _currentDrawingElement {
            drawingElement.updateDrawingStruct(drawingStruct: drawingStruct)
        }
        else {
            let drawing = DrawingElement(drawingStruct: drawingStruct)
            drawing.frame = canvas.frame
            self.canvas.addSubview(drawing)
            _currentDrawingElement = drawing
        }
    }
    
    func drawWithGesture(gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            _currentDrawingElement?.beginDrawing(point: gesture.location(in: self.view))
            
        case .changed:
            _currentDrawingElement?.moveDrawingPoint(point: gesture.location(in: self.view))
            
        case .ended:
            _currentDrawingElement?.endDrawing(point: gesture.location(in: self.view))
            
        case .cancelled, .failed:
            _currentDrawingElement?.cancelDrawing(point: gesture.location(in: self.view))
            
        default:
            break
        }
    }
    
    func eraseWithGesture(gesture: UIPanGestureRecognizer) {
        
        var hasEnded: Bool = false
        
        for case let drawingElement as DrawingElement in _elements {
            
            switch gesture.state {
            case .began:
                drawingElement.beginErasing(point: gesture.location(in: self.view))
                
            case .changed:
                drawingElement.moveErasingPoint(point: gesture.location(in: self.view))
                
            case .ended:
                drawingElement.endErasing(point: gesture.location(in: self.view))
                hasEnded = true
                
            case .cancelled , .failed:
                drawingElement.cancelErasing(point: gesture.location(in: self.view))
                hasEnded = true
                
            default:
                break
            }
        }
        
        // Hide elemntBar if all selected elements have been erased.
        if hasEnded {
            _elements = _elements.filter {
                if $0.frame.isEmpty {
                    if $0 == _currentDrawingElement {
                        _currentDrawingElement = nil
                    }
                    //$0.remove()
                    return false
                }
                return true
            }
            
            
        }
        //
    }
}


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
