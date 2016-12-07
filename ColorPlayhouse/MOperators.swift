//
//  Operators.swift
//  AppleTVPointerTest
//
//  Created by Ricardo Venieris on 23/10/16.
//  Copyright © 2016 LES. All rights reserved.
//

import Foundation

func + (a:Vector3D, b:Vector3D)->Vector3D {
    return Vector3D(x: a.x + b.x, y: a.y + b.y, z: a.z + b.z)
}

func - (a:Vector3D, b:Vector3D)->Vector3D {
    return Vector3D(x: a.x - b.x, y: a.y - b.y, z: a.z - b.z)
}

func * (a:Vector3D, b:Double)->Vector3D {
    return Vector3D(x: a.x * b,
                    y: a.y * b,
                    z: a.z * b)
}

func * (a:Vector3D, b:NSNumber)->Vector3D {
    return a * Double(b)
}

func * (a:Vector3D, b:Vector3D)->Vector3D {
    return Vector3D(x: a.x * b.x,
                    y: a.y * b.y,
                    z: a.z * b.z)
}

func / (a:Vector3D, b:NSNumber)->Vector3D {
    let floatB = Float(b)
    return Vector3D(x: Double(Float(a.x) / floatB),
                    y: Double(Float(a.y) / floatB),
                    z: Double(Float(a.z) / floatB))
}
