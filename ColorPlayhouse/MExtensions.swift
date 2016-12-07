//
//  ModelExteinsions.swift
//  AppleTVPointerTest
//
//  Created by Ricardo Venieris on 23/10/16.
//  Copyright © 2016 LES. All rights reserved.
//
import UIKit

extension Double {
    var roundTo2f:Double {
        mutating get {
            return Double(Int(100.0  * self)/100)
        }
    }
    var roundTo3f:Double {
        mutating get {
            return Double(Int(1000.0  * self)/1000)
        }
    }
    func format(decimals: Int) -> String {
        if (self < 0) { return String(format: "%0.\(decimals)f", self) }
        return String(format: "+%0.\(decimals)f", self)
    }
    
}
