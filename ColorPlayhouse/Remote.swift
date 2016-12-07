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
		controller.device = GCController.controllers().first!
		
		pointerMotionController = PointerMotion(controller: controller,
                                                screenBounds: UIScreen.main.bounds.bounds3D)
        
	
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
