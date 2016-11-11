//
//  Geometry.swift
//  Insight
//
//  Created by Gabriel Coutinho de Paula on 11/7/15.
//  Copyright © 2015 Insight. All rights reserved.
//

import UIKit


class Geometry
{
    static func modulusSquared(_ p1: CGPoint, _ p2:CGPoint) -> CGFloat {
        let dx: CGFloat = p2.x - p1.x;
        let dy: CGFloat = p2.y - p1.y;
        
        return dx * dx + dy * dy
    }
    
    static func clamp(val: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        
        if (val < min) { return min }
        if (val > max) { return max }
        return val
    }
    
    static func clamp(val: Float, min: Float, max: Float) -> Float {
        
        if (val < min) { return min }
        if (val > max) { return max }
        return val
    }
}


// MARK: - LineSegment

struct LineSegment
{
    var firstPoint: CGPoint
    var secondPoint: CGPoint
    
    init() {
        self.firstPoint = CGPoint.zero
        self.secondPoint = CGPoint.zero
    }
    
    init(_ p1: CGPoint, _ p2: CGPoint) {
        self.firstPoint = p1
        self.secondPoint = p2
    }
    
    
    func perpendicularVec(withModulus mod: CGFloat) -> LineSegment {
       
        let dx: CGFloat = self.secondPoint.x - self.firstPoint.x
        let dy: CGFloat = self.secondPoint.y - self.firstPoint.y
        
        let xa: CGFloat = self.secondPoint.x + mod/2 * dy
        let ya: CGFloat = self.secondPoint.y - mod/2 * dx
        let xb: CGFloat = self.secondPoint.x - mod/2 * dy
        let yb: CGFloat = self.secondPoint.y + mod/2 * dx
        
        return LineSegment(CGPoint(x: xa, y: ya), CGPoint(x: xb, y: yb))
    }
    
    func modulusSquared() -> CGFloat {
        let dx: CGFloat = self.secondPoint.x - self.firstPoint.x
        let dy: CGFloat = self.secondPoint.y - self.firstPoint.y
        
        return dx*dx + dy*dy
    }
}

extension LineSegment: Equatable {}

    // MARK: Equatable

    func ==(lhs: LineSegment, rhs: LineSegment) -> Bool {
        return (lhs.firstPoint == rhs.firstPoint) && (lhs.secondPoint == rhs.secondPoint)
    }
    
    func !=(lhs: LineSegment, rhs: LineSegment) -> Bool {
        return !(lhs == rhs)
    }


    // MARK: Other Operations

    func *(lhs: LineSegment, rhs: LineSegment) -> CGFloat {
        let x: CGFloat = (lhs.secondPoint.x - lhs.firstPoint.x) * (rhs.secondPoint.x - rhs.firstPoint.x)
        let y: CGFloat = (lhs.secondPoint.y - lhs.firstPoint.y) * (rhs.secondPoint.y - rhs.firstPoint.y)
        
        return x+y
    }
