//
//  DrawingShapeLayer.swift
//  Insight
//
//  Created by Gabriel Coutinho de Paula on 10/28/15.
//  Copyright © 2015 Insight. All rights reserved.
//

import UIKit


class DrawingShapeLayer: CAShapeLayer
{
    // MARK: - Public & ReadOnly Properties
    
    var toBeDeleted: Bool = false
    var shouldThinStrokesEnd: Bool = true
    
    // MARK: - Private Properties
    
    private (set) var _boundingBox: CGRect = CGRect.null
    private var _ff: CGFloat
    private var _lower: CGFloat
    private var _upper: CGFloat
    
    private var _isFirstPoint: Bool = true
    private var _isLastPoint: Bool = false
    private var _isDot: Bool = false
    
    private var _bezierPath: UIBezierPath = UIBezierPath()
    private var _hitPath: CGPath?
    
    private var _ctr: Int = 0
    private var _pts: Array<CGPoint> = Array<CGPoint>(repeating: CGPoint.zero, count: 5)
    
    private var _lastSegment: LineSegment = LineSegment()
    
    
    // MARK: - Public Initializers
    
    init(color: CGColor, lineWidth: CGFloat, lower: CGFloat, upper: CGFloat, ff: CGFloat) {
        
        _ff = ff
        _lower = lower
        _upper = upper
        
        super.init()
        
        self.path = _bezierPath.cgPath
        
        self.shouldRasterize = false
        self.contentsScale = UIScreen.main.scale
        self.isOpaque = true
        self.drawsAsynchronously = true
        
        self.strokeColor = color
        self.fillColor = color
        self.lineWidth = lineWidth
    }
    
    override init(layer: Any) {
        
        let this = layer as! DrawingShapeLayer
        
        _pts = this._pts
        _bezierPath = this._bezierPath
        
        _ff = this._ff
        _lower = this._lower
        _upper = this._upper
        
        _boundingBox = this._boundingBox
        _hitPath = this._hitPath
        
        _isFirstPoint = this._isFirstPoint
        _isLastPoint = this._isLastPoint
        _isDot = this._isDot
        
        self.toBeDeleted = this.toBeDeleted
        self.shouldThinStrokesEnd = this.shouldThinStrokesEnd
        
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Public Methods
    
    override func hitTest(_ p: CGPoint) -> CALayer? {
        
        if(_boundingBox.contains(p)) {
            if(_isDot) {
                return self
            }
            if(_hitPath != nil) {
                return _hitPath!.contains(p) ? self : nil
            }
        }
        return nil
    }
    
    func isPointWithin(point: CGPoint) -> Bool {
        return (self.hitTest(point) != nil)
    }
    
    func applyTransform( transform: inout CGAffineTransform, isRotation: Bool) {
        
        if let _ = self.path {
            self.path = self.path!.copy(using: &transform)
            _bezierPath.cgPath = self.path!
        }
        
        if let unwrpdHitPath = _hitPath {
            self._hitPath = unwrpdHitPath.copy(using: &transform)
        }
        
        if(!isRotation) {
            _boundingBox = _boundingBox.applying(transform)
        }
        else {
            let box = (path == nil) ? CGRect.zero : path!.boundingBoxOfPath
            
            if(_isDot) {
                _boundingBox.origin = CGPoint(x: box.origin.x - _boundingBox.size.width/2, y: box.origin.y - _boundingBox.size.height/2)
            }
            else {
                _boundingBox = box
            }
        }
    }
    
    func fadeOut() {
        
        CATransaction.begin()
        
        CATransaction.setCompletionBlock { () -> Void in
            self.removeFromSuperlayer()
        }
        
        self.opacity = 0.0
        
        CATransaction.commit()
    }
    
    
    // MARK: Stroke Methods
    
    //startLine
    func strokeBegan(point: CGPoint) {
        _ctr = 0
        _pts[0] = point
        _isFirstPoint = true
    }
    
    //addNewPointToLine
    func strokeMoved(point: CGPoint) {
     
        if (Geometry.modulusSquared(_pts[_ctr], point) < 25.0) {
            return
        }
        
        _ctr += 1
        _pts[_ctr] = point
        self.drawLine()
    }
    
    //finishLineWithPoint
    func strokeEnded(point: CGPoint) {
        
        if(!_isFirstPoint) {
            _ctr += 1
            
            if(self.shouldThinStrokesEnd) {
                
                for i in _ctr ..< 4 {
                    _pts[i] = CGPoint(x: _pts[i-1].x + (point.x - _pts[i-1].x)/2.0, y: _pts[i-1].y + (point.y - _pts[i-1].y)/2.0)
                }
                _ctr = 4
            }
            
            _pts[_ctr] = point
            _isLastPoint = true
            self.drawLine()
            
            if let path = self.path {
                _boundingBox = path.boundingBoxOfPath
            
                let distance: CGFloat = 20.0
                _hitPath = CGPath(__byStroking: self.path!,
                                  transform: nil,
                                  lineWidth: distance*2.0,
                                  lineCap: .round,
                                  lineJoin: .round,
                                  miterLimit: 0)
            }
        }
        else {
            self.makeDot(point: point)
        }
    }
    
    
    // MARK: - Private Methods
    
    private func drawLine() {
        if (_ctr == 4) {
            
            self.addPoints(pointsArray: _pts, toPath: _bezierPath)
            
            _pts[0] = _pts[3]
            _pts[1] = _pts[4]
            
            
            self.path = _bezierPath.cgPath
            self.setNeedsDisplay()
            
            _ctr = 1
        }
    }
    
    private func addPoints(pointsArray: Array<CGPoint>, toPath path: UIBezierPath) {
        
        var ls: Array<LineSegment> = Array<LineSegment>(repeating: LineSegment(), count: 4)
        
        //points[4] = points[3]
        var points = pointsArray
        points[3] = CGPoint(x:(points[2].x + points[4].x)/2.0, y: (points[2].y + points[4].y)/2.0) // Smoothing
        
        
        // Calculate Width
        let w1 = self.strokeWidth(p1: points[0], p2: points[1])
        let w2 = self.strokeWidth(p1: points[1], p2: points[2])
        let w3 = self.strokeWidth(p1: points[2], p2: points[3])
        //
        
        // Set points
        if (_isFirstPoint) {
            ls[0] = LineSegment(points[0], points[0])
            _isFirstPoint = false
        }
        else {
            ls[0] = _lastSegment;
        }
        
        ls[1] = LineSegment(points[0], points[1]).perpendicularVec(withModulus: w1)
        ls[2] = LineSegment(points[1], points[2]).perpendicularVec(withModulus: w2)
        
        if (_isLastPoint) {
            ls[3] = LineSegment(points[3], points[3])
            _isLastPoint = false
            
        }
        else {
            ls[3] = LineSegment(points[2], points[3]).perpendicularVec(withModulus: w3)
        }
        //
        
        // Add to path
        path.move(to: ls[0].firstPoint)
        path.addCurve(to: ls[3].firstPoint, controlPoint1: ls[1].firstPoint, controlPoint2: ls[2].firstPoint)
        path.addLine(to: ls[3].secondPoint)
        path.addCurve(to: ls[0].secondPoint, controlPoint1: ls[2].secondPoint, controlPoint2: ls[1].secondPoint)
        path.close()
        //
        
        // Update points
        //        points[0] = points[3]
        //        points[1] = points[4]
        _lastSegment = ls[3]
        //
    }
    
    private func strokeWidth(p1: CGPoint, p2: CGPoint) -> CGFloat {
        let mod  = Geometry.modulusSquared(p1, p2)
        let width = _ff/Geometry.clamp(val: mod, min: _lower, max: _upper)
        return width
    }
    
    private func makeDot(point: CGPoint) {
        
        let size: CGFloat = 5*sqrt(self.lineWidth)/sqrt(_upper)
        let size_2: CGFloat = size/2.0
        let rect = CGRect(x: point.x - size_2, y: point.y - size_2, width: size, height: size)
        
        if(self.shouldThinStrokesEnd) {
            _bezierPath = UIBezierPath(ovalIn: rect)
        }
        else {
            _bezierPath = UIBezierPath(rect: rect)
        }
        
        
        self.path = _bezierPath.cgPath
        self.setNeedsDisplay()
        
        _isFirstPoint = false
        _isLastPoint = true
        _isDot = true
        
        let sizeFactor: CGFloat = 7.5
        _boundingBox = CGRect(x: point.x - size_2*sizeFactor, y: point.y - size_2*sizeFactor, width: size*sizeFactor, height: size*sizeFactor)
    }
}
