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
    
    
    private var _lineView: LineView?
    private var _currentDrawingShapeLayer: DrawingShapeLayer?
    private var options = PenOptions()
    
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
        
        //let convertedPoint = convertGesturePointToLocalCoordinate(gesture)
        let point: CGPoint?
        print("x:\(gesture.location(in: view).x) y:\(gesture.location(in: view).y)")
        
        switch gesture.state {
            
        case .began:
            drawingBeganWith(gesture: gesture)
            
        case .changed:
            point = gesture.location(in: view)
            drawingMovedTo(point: point!)
            
        case .ended:
            point = gesture.location(in: view)
            drawingEndedWith(point: point!)
            
        case .cancelled, .failed:
            drawingCancelled()
            
        default:
            break
        }
    
    }
    
    private func drawingBeganWith(gesture: UIGestureRecognizer) {
        
        let point = gesture.location(in: view)
        
        if let lineView = _lineView{
            
            if _currentDrawingShapeLayer != nil{
                
                startDrawingLineWith(point: point)
            }
            else{
                createNewLayer()
                lineView.layer.addSublayer(_currentDrawingShapeLayer!)
                
                startDrawingLineWith(point: point)
            }
        }
        else{
            _lineView = LineView()
            view.addSubview(_lineView!)
            
            createNewLayer()
            _lineView!.layer.addSublayer(_currentDrawingShapeLayer!)
            
            startDrawingLineWith(point: point)
        }
    }
    
    private func drawingMovedTo(point: CGPoint) {
        
        if _currentDrawingShapeLayer != nil{
            
            continueDrawingLineWith(point: point)
        }
    }
    
    private func drawingEndedWith(point: CGPoint) {
        
        if _currentDrawingShapeLayer != nil{
            
            finishDrawingLineWith(point: point)
            
            _lineView!.addNewLine(line: _currentDrawingShapeLayer!)
            _currentDrawingShapeLayer = nil
        }
    }
    
    private func drawingCancelled() {
        
        if let currentDrawingShapeLayer = _currentDrawingShapeLayer {
            currentDrawingShapeLayer.removeFromSuperlayer()
        }
        _currentDrawingShapeLayer = nil
    }
    
    //Aux
    
    private func startDrawingLineWith(point: CGPoint){
        
        _currentDrawingShapeLayer!.startLine(point: point)
    }
    
    private func continueDrawingLineWith(point: CGPoint){
        
        _currentDrawingShapeLayer!.addNewPointToLine(point: point)
    }
    
    private func finishDrawingLineWith(point: CGPoint){
        
        _currentDrawingShapeLayer?.finishLineWithPoint(point: point)
    }
    
    private func createNewLayer(){
        _currentDrawingShapeLayer = DrawingShapeLayer(lineOptions: self.options)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {}
}

class PenOptions {
    
    // MARK: - Public & ReadOnly Properties
    
    var allOptions = Dictionary<String,AnyObject>()
    
    
    // MARK: - Initializers
    
    init(){
        
        allOptions["ff"] = CGFloat(2.0) as AnyObject?
        allOptions["LOWER"] = CGFloat(0.01) as AnyObject?
        allOptions["UPPER"] = CGFloat(5.0) as AnyObject?
        allOptions["color"] = UIColor.black.cgColor
        allOptions["lineWidth"] = CGFloat(2.0) as AnyObject?
        allOptions["shouldThinEndStroke"] = true as AnyObject?
        allOptions["fadeOpacity"] = Float(0.3) as AnyObject?
    }
    
    
    // MARK: - Public Methods
    
    func updateOption(option: String, withValue value: AnyObject){
        
        allOptions.updateValue(value, forKey: option)
    }
    
    func updateAllOptions(options: Dictionary<String,AnyObject>){
        
        for key in options.keys{
            allOptions.updateValue(options[key]!, forKey: key)
        }
    }
}
