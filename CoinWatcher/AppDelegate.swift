//
//  AppDelegate.swift
//  CoinWatcher
//
//  Created by Joel Reis on 3/23/18.
//  Copyright © 2018 Brave. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        guard let splitVC = window?.rootViewController as? UISplitViewController else { return false }
        splitVC.delegate = self
        splitVC.preferredDisplayMode = .allVisible
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
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
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoinWatcher")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func coin(id: String) -> Coin? {
        let request: NSFetchRequest<Coin> = Coin.fetchRequest()
        request.predicate = NSPredicate(format: "coinId = %@", id)
        let result = try? persistentContainer.viewContext.fetch(request)
        return (result ?? []).first
    }
    
    func insertNewFavoriteCoin(id: String) {
        let entity = NSEntityDescription.entity(forEntityName: Coin.description(), in: persistentContainer.viewContext)!
        let new = Coin(entity: entity, insertInto: persistentContainer.viewContext)
        new.coinId = id
        new.isFavorited = true
        saveContext()
    }
}
