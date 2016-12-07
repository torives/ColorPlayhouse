//
//  PointerMotion.swift
//  AppleTVPointerTest
//
//  Created by Ricardo Venieris on 22/10/16.
//  Copyright © 2016 LES. All rights reserved.
//

import UIKit

class PointerMotion {
    
    // Constants
    let gavityFactor = 0.0998 //9.98g * 1/50frames/seg  /2
    
    // Public proprieties
    var controller:Controller
    var screenMargin:Vector3D
    var bounds:Bounds3D
    var gravity:Vector3D
    var previousPosition = Vector3D.zero


    // Private proprieties
    private var pAcceleration = Vector3D.zero
    private var previousAcceleration = Vector3D.zero
    private var pGravity = Vector3D.zero
    private var pVelocity = Vector3D.zero
    private var pPosition = Vector3D.zero

    // Calculated proprieties
    var acceleration:Vector3D {
        get { return pAcceleration }
        set {
            previousAcceleration = pAcceleration
            pAcceleration = newValue
            
        }
    }
    var velocity:Vector3D {
        get { return pVelocity }
        set {
            pVelocity = newValue + ((acceleration + previousAcceleration) * gavityFactor)
        }
    }

    var position:Vector3D {
        get { return pPosition }
        set {
            previousPosition = pPosition
            pPosition = newValue
        }
    }


    
    init(controller:Controller, screenBounds:Bounds3D, screenMargin:Vector3D = Vector3D(x:60, y:60, z:0)) {
        self.controller = controller
        self.screenMargin = screenMargin
        self.bounds = screenBounds

        self.bounds.max = self.bounds.max - screenMargin
        self.bounds.min = self.bounds.min + screenMargin

        self.gravity = Vector3D.zero
        self.acceleration = Vector3D.zero
        self.velocity = Vector3D.zero
        self.position = self.bounds.centerPoint
        self.previousPosition = self.position
    }

    func actualize() {
        gravity = controller.gravity
        acceleration = controller.acceleration
        velocity = controller.gravity
        previousPosition = position
        position = (position + velocity).limit(on: bounds)
    }
    
}

