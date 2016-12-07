//
//  VMExtensions.swift
//  AppleTVPointerTest
//
//  Created by Ricardo Venieris on 23/10/16.
//  Copyright © 2016 LES. All rights reserved.
//

import Foundation
import GameController
import UIKit
import SceneKit

extension GCAcceleration {
    var vector3D:Vector3D {
        return Vector3D(x: self.x, y: self.y, z: self.z)        }
}

extension CGRect {
    var bounds3D:Bounds3D {
        return Bounds3D(min: Vector3D(x: Double(self.minX), y: Double(self.minY), z: 0.0),
                        max: Vector3D(x: Double(self.maxX), y: Double(self.maxY), z: 0.0))        }
}

extension Vector3D {
    var CGPointXY:CGPoint {
        return CGPoint(x: CGFloat(self.x), y: CGFloat(self.y))
    }
}

