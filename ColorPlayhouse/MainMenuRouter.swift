//
//  MainMenuRouter.swift
//  ColorPlayhouse
//
//  Created by Victor Yves Crispim on 11/5/16.
//  Copyright © 2016 Priscila Rosa. All rights reserved.
//

import UIKit

protocol MainMenuRouter {
 
    var menuScreen: UIViewController? {get set}
    
    func displayNewDrawingScreen()
    func displayPortfolioScreen()
}
