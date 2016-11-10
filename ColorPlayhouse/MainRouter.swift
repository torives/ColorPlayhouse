//
//  MainRouter.swift
//  ColorPlayhouse
//
//  Created by Victor Yves Crispim on 11/5/16.
//  Copyright © 2016 Priscila Rosa. All rights reserved.
//

import UIKit

class MainRouter {
    
    var menuScreen: UIViewController?
    
    func configureFirstSceneOn(_ window: UIWindow){
        
        let presenter = MainMenuPresenter()
        presenter.router = self
        
        let menuVC = window.rootViewController as! MainMenuViewController
        menuVC.delegate = presenter
        menuScreen = menuVC
    }
}

extension MainRouter: MainMenuRouter {

    func displayNewDrawingScreen() {
     
        
    }
    
    func displayPortfolioScreen(){
        
    }
}
