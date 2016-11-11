//
//  DrawingViewController.swift
//  ColorPlayhouse
//
//  Created by Victor Yves Crispim on 11/5/16.
//  Copyright © 2016 Aleixo Rosa & Crispim. All rights reserved.
//

import UIKit

class DrawingViewController: UIViewController {
    
    @IBOutlet weak var palette: UIImageView!
    @IBOutlet weak var canvas: UIImageView!
    
    @IBOutlet weak var eraserOutlet: UIButton!
    @IBOutlet weak var crayonOutlet: UIButton!
    @IBOutlet weak var brushOutlet: UIButton!
    @IBOutlet weak var pencilOutlet: UIButton!
    
    @IBOutlet weak var purpleOutlet: UIButton!
    @IBOutlet weak var magentaOutlet: UIButton!
    @IBOutlet weak var redOutlet: UIButton!
    @IBOutlet weak var darOrangeOutlet: UIButton!
    @IBOutlet weak var orangeOutlet: UIButton!
    @IBOutlet weak var yellowOutlet: UIButton!
    @IBOutlet weak var lightGreenOutlet: UIButton!
    @IBOutlet weak var greenOutlet: UIButton!
    @IBOutlet weak var lightBlueOutlet: UIButton!
    @IBOutlet weak var blueOutlet: UIButton!
    
    @IBAction func eraser(_ sender: AnyObject) {}
    @IBAction func crayon(_ sender: AnyObject) {}
    @IBAction func brush(_ sender: AnyObject) {}
    @IBAction func pencil(_ sender: AnyObject) {}
    
    @IBAction func purple(_ sender: AnyObject) {}
    @IBAction func magenta(_ sender: AnyObject) {}
    @IBAction func red(_ sender: AnyObject) {}
    @IBAction func darkOrange(_ sender: AnyObject) {}
    @IBAction func orange(_ sender: AnyObject) {}
    @IBAction func yellow(_ sender: AnyObject) {}
    @IBAction func lightGreen(_ sender: AnyObject) {}
    @IBAction func green(_ sender: AnyObject) {}
    @IBAction func lightBlue(_ sender: AnyObject) {}
    @IBAction func blue(_ sender: AnyObject) {}
    
    private var _eraserEnabled: Bool = false
    private var _drawingStruct: DrawingStruct = DrawingStruct()
    private weak var _currentDrawingElement: DrawingElement?
    private var _elements: Array<UIView> = Array<UIView>()
    
    override func viewDidLoad() {
        
        self.palette.isHidden = true
        self.eraserOutlet.isHidden = true
        self.pencilOutlet.isHidden = true
        self.brushOutlet.isHidden = true
        self.crayonOutlet.isHidden = true
        
        self.purpleOutlet.isHidden = true
        self.purpleOutlet.isHidden = true
        self.magentaOutlet.isHidden = true
        self.redOutlet.isHidden = true
        self.darOrangeOutlet.isHidden = true
        self.orangeOutlet.isHidden = true
        self.yellowOutlet.isHidden = true
        self.lightGreenOutlet.isHidden = true
        self.greenOutlet.isHidden = true
        self.lightBlueOutlet.isHidden = true
        self.blueOutlet.isHidden = true
        
        
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(didReceiveTouch(gesture:)))
        view.addGestureRecognizer(gesture)
    }

    func didReceiveTouch(gesture: UIPanGestureRecognizer){
        
        if (_eraserEnabled) {
            eraseWithGesture(gesture: gesture)
        }
        else {
            if gesture.state == .began {
                updateDrawing(drawingStruct: _drawingStruct)
            }
            drawWithGesture(gesture: gesture)
        }
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
            self.view.addSubview(drawing)
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
