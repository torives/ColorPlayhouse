//
//  DrawingElement.swift
//  Insight
//
//  Created by Gabriel Coutinho de Paula on 10/20/15.
//  Copyright © 2015 Insight. All rights reserved.
//

import UIKit

class DrawingElement: UIView
{
    
    // MARK: - ******************
    // MARK: Properties
    // MARK: ****************** -
    
    var isSelected = false
    
    private var _drawingStruct: DrawingStruct
    private var _currentScale: CGFloat = 1.0
    
    private var _currentShapeLayer: DrawingShapeLayer!
    private var _shapeLayerArray: Array<DrawingShapeLayer>
    
    private var _last: Bool = false
    
    
    // MARK: - ******************
    // MARK: Public Methods
    // MARK: ****************** -
    
    // MARK: - Public Initializers
    init(drawingStruct: DrawingStruct) {
        
        _shapeLayerArray = Array<DrawingShapeLayer>()
        _drawingStruct = drawingStruct
        
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //
    
    func delete() {
        for aLayer in _shapeLayerArray {
            aLayer.fadeOut()
        }
    }
    
    func updateDrawingStruct(drawingStruct: DrawingStruct) {
        _drawingStruct = drawingStruct
    }
    
    
    // MARK: Drawing methods
    func beginDrawing(point: CGPoint) {
        _currentShapeLayer = DrawingShapeLayer(color: _drawingStruct.color.cgColor, lineWidth: _drawingStruct.lineWidth, lower: CGFloat(_drawingStruct.lower), upper: CGFloat(_drawingStruct.upper), ff: CGFloat(_drawingStruct.ff))
        _currentShapeLayer.shouldThinStrokesEnd = _drawingStruct.shouldThin
        self.layer.addSublayer(_currentShapeLayer)
        
        let convertedPoint = self.convert(point, from: superview)
        _currentShapeLayer.strokeBegan(point: convertedPoint)
    }
    
    func moveDrawingPoint(point: CGPoint) {
        let convertedPoint = self.convert(point, from: superview)
        _currentShapeLayer.strokeMoved(point: convertedPoint)
    }
    
    func endDrawing(point: CGPoint) {
        let convertedPoint = self.convert(point, from: superview)
        _currentShapeLayer.strokeEnded(point: convertedPoint)
        
        _shapeLayerArray.append(_currentShapeLayer)
        _currentShapeLayer = nil
    }
    
    func cancelDrawing(point: CGPoint?) {
        _currentShapeLayer.removeFromSuperlayer()
        _currentShapeLayer = nil
    }
    //
    
    
    // MARK: Eraser Methods
    func beginErasing(point: CGPoint) {
        if(self.frame.contains(point)) {
            let convertedPoint = self.convert(point, from: superview)
            self.erasePoint(point: convertedPoint)
        }
    }
    
    func moveErasingPoint(point: CGPoint) {
        if(self.frame.contains(point)) {
            let convertedPoint = self.convert(point, from: superview)
            self.erasePoint(point: convertedPoint)
        }
    }
    
    func endErasing(point: CGPoint) {
        if(self.frame.contains(point)) {
            let convertedPoint = self.convert(point, from: superview)
            self.erasePoint(point: convertedPoint)
        }
        removeLayers()
    }
    
    func cancelErasing(point: CGPoint?) {
        for aLayer in _shapeLayerArray {
            if (aLayer.toBeDeleted) {
                aLayer.toBeDeleted = false
                aLayer.opacity = 1.0
            }
        }
    }
    //
	
    
    // MARK: - ******************
    // MARK: Private Methods
    // MARK: ****************** -
    
    // MARK: Eraser methods
    private func erasePoint(point: CGPoint) {
        
        for aLayer in _shapeLayerArray {
            if (aLayer.isPointWithin(point: point)) {
                
                if (!aLayer.toBeDeleted) {
                    aLayer.toBeDeleted = true
                    aLayer.opacity = _drawingStruct.fadeOpacity
                    aLayer.setNeedsDisplay()
                }
            }
        }
    }
    
    private func removeLayers() {
		
        _shapeLayerArray = _shapeLayerArray.filter {
            if ($0.toBeDeleted) {
                $0.fadeOut()
                return false
            }
            return true
        }
    }
    //
}
