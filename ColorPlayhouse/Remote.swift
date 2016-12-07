//
//  Remote.swift
//  AppleTVPointerTest
//
//  Created by Ricardo Venieris on 19/11/16.
//  Copyright © 2016 LES. All rights reserved.
//

import Foundation
import GameController

class Remote {
    var controller: Controller!
    var pointerMotionController: PointerMotion!
    var handler: RemoteHandler
    
    init(handler: RemoteHandler) {
        self.handler = handler
        controller = Controller()
        pointerMotionController = PointerMotion(controller: controller,
                                                screenBounds: UIScreen.main.bounds.bounds3D)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.controllerDidConnect(notification:)), name: NSNotification.Name.GCControllerDidConnect, object: nil)
    }
    
    
    @objc func controllerDidConnect(notification : NSNotification) {
        controller.device = GCController.controllers().first!
        Timer.scheduledTimer(withTimeInterval: 1/50, repeats: true, block: { (_) in
            self.pointerMotionController.actualize()
            self.handler.remoteCiclicBehavior()
            
        })
        
        controller.device?.motion?.valueChangedHandler = { (motion : GCMotion) -> () in
            self.pointerMotionController.actualize()
            self.handler.remoteDidMove()
            
        }
    }

}
