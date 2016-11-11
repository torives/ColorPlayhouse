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
    
    @IBOutlet var drawingTools: [UIButton]!
    @IBOutlet var paletteColors: [UIButton]!
    
    private var _eraserEnabled: Bool = false
    private var _drawingStruct: DrawingStruct = DrawingStruct()
    private weak var _currentDrawingElement: DrawingElement?
    private var _elements: Array<UIView> = Array<UIView>()
    
    override func viewDidLoad() {
        
        drawingTools.forEach({$0.isHidden = true})
        paletteColors.forEach({$0.isHidden = true})
        palette.isHidden = true
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(didReceiveTouch(gesture:)))
        view.addGestureRecognizer(gesture)
    }

    func didReceiveTouch(gesture: UIPanGestureRecognizer){
        
//        if (_eraserEnabled) {
//            eraseWithGesture(gesture: gesture)
//        }
//        else {
        
        let point = gesture.location(in: view)
        print("x:\(point.x) y:\(point.y)")
        
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
