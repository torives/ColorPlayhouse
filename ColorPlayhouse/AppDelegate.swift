//
//  AppDelegate.swift
//  ColorPlayhouse
//
//  Created by Priscila Rosa on 11/8/16.
//  Copyright © 2016 Priscila Rosa. All rights reserved.
//

import UIKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let mainRouter = MainRouter()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
//        let initialViewController = getInitialVC()
//
//        self.window?.rootViewController = initialViewController
//        self.window?.makeKeyAndVisible()

        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func getInitialVC() -> UIViewController {

        if !UserDefaults.standard.bool(forKey: "HasLaunchedOnce") {
            UserDefaults.standard.synchronize()
            
            UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")

			let storyboard = UIStoryboard(name: "Tutorial", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "TutorialPageVC") as! TutorialPageViewController
        }
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "MainMenuScene") as! MainMenuViewController

    }
    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {}
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?,  annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url as URL!, sourceApplication: sourceApplication, annotation: annotation)
    }
}

