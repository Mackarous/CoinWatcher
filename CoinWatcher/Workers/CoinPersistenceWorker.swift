//
//  CoinPersistenceWorker.swift
//  CoinWatcher
//
//  Created by Andrew Mackarous on 2018-08-31.
//  Copyright © 2018 Brave. All rights reserved.
//

import CoreData

final class CoinPersistenceWorker {
    
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
