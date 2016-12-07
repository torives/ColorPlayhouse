//
//  VMFunctions.swift
//  AppleTVPointerTest
//
//  Created by Ricardo Venieris on 23/10/16.
//  Copyright © 2016 LES. All rights reserved.
//

import UIKit

func showAxis(vector : Vector3D, labelX : UILabel, labelY : UILabel, labelZ : UILabel) {
    labelX.text = vector.x.format(decimals: 3)
    labelY.text = vector.y.format(decimals: 3)
    labelZ.text = vector.z.format(decimals: 3)
}
