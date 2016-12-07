//
//  Controller.swift
//  AppleTVPointerTest
//
//  Created by Ricardo Venieris on 18/11/16.
//  Copyright © 2016 LES. All rights reserved.
//

import GameController



class Controller {
    var device: GCController?
    var scale = Vector3D(x: 17, y: 17, z: 1)
    
    var gravity:Vector3D {
        get {
            if device?.motion == nil { return Vector3D.zero}
            return device!.motion!.gravity.vector3D  * scale
        }
    }
    
    var acceleration:Vector3D {
        get {
            if device?.motion == nil { return Vector3D.zero}
            return device!.motion!.userAcceleration.vector3D  * scale
        }
    }
    
    var buttonAisPressed:Bool {
        get{
            if device?.microGamepad == nil { return false }
            return device!.microGamepad!.buttonA.isPressed
        }
    }
    
    var buttonXisPressed:Bool {
        get{
            if device?.microGamepad == nil { return false }
            return device!.microGamepad!.buttonX.isPressed
        }
    }
    
    init(scale:Vector3D) {
        self.scale = scale
    }
    
    init() {
    }
    
}
