//
//  AppDelegate.swift
//  CoinWatcher
//
//  Created by Joel Reis on 3/23/18.
//  Copyright © 2018 Brave. All rights reserved.
//

import UIKit
import SwinjectStoryboard

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    
    private let persistenceWorker = SwinjectStoryboard.defaultContainer.resolve(CoinPersistenceWorker.self)

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        guard let splitVC = window?.rootViewController as? UISplitViewController else { return false }
        splitVC.delegate = self
        splitVC.preferredDisplayMode = .allVisible
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        persistenceWorker?.saveContext()
    }

    // MARK: - Split view

    func splitViewController(_ svc: UISplitViewController, shouldHide vc: UIViewController, in orientation: UIInterfaceOrientation) -> Bool {
        return false
    }

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let navController = secondaryViewController as? UINavigationController else { return false }
        guard let detailViewController = navController.viewControllers.first as? DetailViewController else { return false }
        if detailViewController.fetchedCoin == nil {
            // Return true to indicate that we have handled the collapse (by doing nothing)
            return true
        }
        return false
    }
}
