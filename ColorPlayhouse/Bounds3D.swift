//
//  Bounds3D.swift
//  AppleTVPointerTest
//
//  Created by Ricardo Venieris on 23/10/16.
//  Copyright © 2016 LES. All rights reserved.
//

class Bounds3D {
    var centerPoint:Vector3D
    var min:Vector3D
    var max:Vector3D
    
    init(min:Vector3D = Vector3D(x: 0, y: 0, z: 0),
         max:Vector3D = Vector3D(x: 0, y: 0, z: 0)) {
        self.min = min
        self.max = max
        self.centerPoint = (self.max - self.min) / 2
    }

    func set(margin:Double) {
        self.min.x += margin
        self.min.y += margin
        self.min.z += margin
        self.max.x -= margin
        self.max.y -= margin
        self.max.z -= margin
    }
}
