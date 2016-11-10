//
//  MainRouter.swift
//  ColorPlayhouse
//
//  Created by Victor Yves Crispim on 11/5/16.
//  Copyright © 2016 Priscila Rosa. All rights reserved.
//

import UIKit

class MainRouter {
    
    var menuScreen: MainMenuViewController?
    
    func configureFirstSceneOn(_ window: UIWindow){
        
        let menuVC = window.rootViewController as! MainMenuViewController
        menuScreen = menuVC
    }
}

extension MainRouter: MainMenuRouter {
    
    //There's no data to be passed from the main menu, so this stays empty
    func passDataToNextScene(_ segue: UIStoryboardSegue) {}

    func displayDrawingScreen() {
        menuScreen?.performSegue(withIdentifier: "displayDrawingScreen", sender: nil)
    }
    
    func displayPortfolioScreen(){
        menuScreen?.performSegue(withIdentifier: "displayPortfolioScreen", sender: nil)
    }
}
