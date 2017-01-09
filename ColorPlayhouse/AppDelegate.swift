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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
		let configurator = Configurator()
		configurator.installRootViewControllerInto(window: window!)
		
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

	//TODO: remove this from here
//    func getInitialVC() -> UIViewController {
//
//        if !UserDefaults.standard.bool(forKey: "HasLaunchedOnce") {
//            UserDefaults.standard.synchronize()
//            
//            UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
//
//			let storyboard = UIStoryboard(name: "Tutorial", bundle: nil)
//            return storyboard.instantiateViewController(withIdentifier: "TutorialPageVC") as! TutorialPageViewController
//        }
//		
//		let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        return storyboard.instantiateViewController(withIdentifier: "MainMenuScene") as! MainMenuViewController
//
//    }
	
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

