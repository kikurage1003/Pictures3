/*
	Copyright (C) 2017 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	Manages app lifecycle  split view.
 */


import UIKit
import Photos

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) -> Bool {
       /*
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        #if os(iOS)
        let navigationController = splitViewController.viewControllers.last! as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        #endif
       
 */
//        let tabBarController = self.window!.rootViewController as! UITabBarController;
        //let navigationController = tabBarController.viewControllers?.last! as! UINavigationController
        //navigationController.topViewController!.navigationItem.leftBarButtonItem = tabBarController.displayModeButtonItem
         //splitViewController.delegate = self
        /*
        self.window = UIWindow(frame:UIScreen.main.bounds);
        let storyboard = UIStoryboard(name:"Main",bundle:nil);
        let initi = storyboard.instantiateViewController(withIdentifier: "start");
        self.window?.rootViewController = initi;
        self.window?.makeKeyAndVisible();
 */
 return true
    }

    // MARK: Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? AssetGridViewController else { return false }
        if topAsDetailController.fetchResult == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        // Let the storyboard handle the segue for every case except going from detail:assetgrid to detail:asset.
        guard !splitViewController.isCollapsed else { return false }
        guard !(vc is UINavigationController) else { return false }
        guard let detailNavController =
            splitViewController.viewControllers.last! as? UINavigationController,
            detailNavController.viewControllers.count == 1
            else { return false }

        detailNavController.pushViewController(vc, animated: true)
        return true
    }
}
