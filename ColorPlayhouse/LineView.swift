//
//  LineView.swift
//  drawTest
//
//  Created by Victor Yves Crispim on 05/5/16.
//  Copyright © 2016 Victor Yves. All rights reserved.
//

import UIKit

class LineView: UIView {
    
    // MARK: - Public & ReadOnly Properties
    var fadeOpacity: Float = 0.3
    
    
    // MARK: - Private Properties
    
    private var _drawingShapeLayers = Array<DrawingShapeLayer>()
    
    
    // MARK: - Public Methods
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        for aLayer in _drawingShapeLayers {
            if (aLayer.isPointWithin(point: point)) {
                return self
            }
        }
        
        return nil
    }
    
    func addNewLine(line: DrawingShapeLayer) {
        
        _drawingShapeLayers.append(line)
        updateFrame()
    }
    
    func rotate(rotation: CGFloat, centeredIn center: CGPoint) {
        
        let offset = CGPoint(x: center.x, y: center.y)
        
        var offsetTransform1 = CGAffineTransform(translationX: -offset.x, y: -offset.y)
        var offsetTransform2 = CGAffineTransform(translationX: offset.x, y: offset.y)
        var rotationTransform = CGAffineTransform(rotationAngle: rotation)
        
        for aShapeLayer in _drawingShapeLayers {
            aShapeLayer.applyTransform(transform: &offsetTransform1, isRotation: true)
            aShapeLayer.applyTransform(transform: &rotationTransform, isRotation: true)
            aShapeLayer.applyTransform(transform: &offsetTransform2, isRotation: true)
        }
        self.updateFrame()
    }
    
    func scale(scale: CGFloat, centeredIn center: CGPoint)  {
        
        let offset = CGPoint(x: center.x, y: center.y)
        
        var offsetTransform1 = CGAffineTransform(translationX: -offset.x, y: -offset.y)
        var offsetTransform2 = CGAffineTransform(translationX: offset.x, y: offset.y)
        var scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        
        for aShapeLayer in _drawingShapeLayers {
            aShapeLayer.applyTransform(transform: &offsetTransform1, isRotation: false)
            aShapeLayer.applyTransform(transform: &scaleTransform, isRotation: false)
            aShapeLayer.applyTransform(transform: &offsetTransform2, isRotation: false)
        }
        self.updateFrame()
    }
    
    func erasePoint(point: CGPoint) {
        
        for aLayer in _drawingShapeLayers {
            
            if (aLayer.isPointWithin(point: point)) {
                
                if (!aLayer.toBeDeleted) {
                    aLayer.toBeDeleted = true
                    aLayer.opacity = self.fadeOpacity
                    aLayer.setNeedsDisplay()
                }
            }
        }
    }
    
    func removeErasedLayers() {
        
        self.updateFrame()
        
        _drawingShapeLayers = _drawingShapeLayers.filter {
            
            if ($0.toBeDeleted) {
                
                $0.fadeOut()
                return false
            }
            return true
        }
    }
    
    
    // MARK: - Private Methods
    
    private func updateFrame() {
        
        var newFrame: CGRect = self.createNewBoundingRect()
        
        if(newFrame.isNull) {
            newFrame = CGRect.zero
        }
        
        newFrame.offsetBy(dx: self.frame.origin.x, dy: self.frame.origin.y)
        self.resizeFrame(newFrame: newFrame)
    }
    
    private func createNewBoundingRect() -> CGRect {
        
        var newFrame: CGRect = CGRect.null
        
        for shapeLayer in _drawingShapeLayers {
            
            if (!shapeLayer.toBeDeleted) {
                newFrame = newFrame.union(shapeLayer._boundingBox)
            }
        }
        
        return newFrame
    }
    
    private func resizeFrame(newFrame: CGRect) {
        
        if(newFrame.isNull) {
            
            self.frame = CGRect.zero
            return
        }
        
        let translatePath = CGPoint(x: self.frame.origin.x - newFrame.origin.x, y: self.frame.origin.y - newFrame.origin.y)
        var translation: CGAffineTransform = CGAffineTransform(translationX: translatePath.x, y: translatePath.y)
        
        self.frame = newFrame
        
        for aShapeLayer in _drawingShapeLayers {
            
            aShapeLayer.applyTransform(transform: &translation, isRotation: false)
        }
    }
}
