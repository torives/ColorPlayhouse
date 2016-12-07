//
//  Vector3D.swift
//  AppleTVPointerTest
//
//  Created by Ricardo Venieris on 23/10/16.
//  Copyright © 2016 LES. All rights reserved.
//

//import Foundation

class Vector3D {
    var x: Double
    var y: Double
    var z: Double
    var isZero:Bool { get { return (self.x.isZero) && (self.y.isZero) && (self.z.isZero) } }
    static var zero : Vector3D { return Vector3D(x:0,y:0,z:0) }

    init(x: Double?, y: Double?, z: Double?) {
        
        self.x = x == nil ? 0.0 : x!
        self.y = y == nil ? 0.0 : y!
        self.z = z == nil ? 0.0 : z!
    }
    
    convenience init(xyzCubix value: Double) {
        self.init(x: value, y: value, z: value)
    }
    
    var roundTo3f:Vector3D {
        get {
            self.x = self.x.roundTo3f
            self.y = self.y.roundTo3f
            self.z = self.z.roundTo3f
            return self
        }
    }
    
    func limit(on bounds: Bounds3D)->Vector3D {
        if (self.x > bounds.max.x) { self.x = bounds.max.x }
        if (self.x < bounds.min.x) { self.x = bounds.min.x }
        if (self.y > bounds.max.y) { self.y = bounds.max.y }
        if (self.y < bounds.min.y) { self.y = bounds.min.y }
        if (self.z > bounds.max.z) { self.z = bounds.max.z }
        if (self.z < bounds.min.z) { self.z = bounds.min.z }
        return self
    }

}
