///
//  AppDelegate.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 08-12-15.
//  Copyright © 2015 Jorrit Oosterhof. All rights reserved.
//

import UIKit
import ZeeguuAPI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
		self.window?.backgroundColor = UIColor.whiteColor()
		
		let splitViewController = UISplitViewController()
		
		let mainVC = UINavigationController(rootViewController: ArticleListViewController())
		let detailVC = UINavigationController(rootViewController: ArticleViewController())
		
		splitViewController.viewControllers = [mainVC, detailVC]
		
		window?.rootViewController = splitViewController
		
//		let splitViewController = self.window!.rootViewController as! UISplitViewController
		
		detailVC.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
		splitViewController.delegate = self
		self.window?.makeKeyAndVisible()
		
		if (!ZeeguuAPI.sharedAPI().isLoggedIn) {
			ZeeguuAPI.sharedAPI().loginWithEmail("j.oosterhof.4@student.rug.nl", password: "JLq-E6q-MzL-8pp") { (success) -> Void in
				print("Logged in: \(success)")
			}
		}
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	// MARK: - Split view

	func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
//	    guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
//	    guard let topAsDetailController = secondaryAsNavController.topViewController as? ArticleViewController else { return false }
//	    if topAsDetailController.detailItem == nil {
//	        // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
//	        return true
//	    }
	    return true
	}

}

