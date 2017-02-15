//
//  CoreDataStack.swift
//  VirtualTourist
//
//  Created by Luke Van In on 2017/01/19.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Provides managed object contexts and helper methods for interacting with a core data store.
//
//  For safety, changes should only be made by calling performChanges() passing a block which implement the desired 
//  modifications.
//
//  Data which needs to be made available to the app, such as for displaying in the UI, should be obtained from
//  mainContext. Queries to mainContext should only be done on the main queue.
//

import UIKit
import CoreData

class CoreDataStack {
    
    let name: String
    let mainContext: NSManagedObjectContext
    
    fileprivate let backgroundContext: NSManagedObjectContext
    fileprivate let changeContext: NSManagedObjectContext
    
    convenience init(name: String) throws {
        try self.init(name: name, bundle: Bundle.main)
    }
    
    required init(name: String, bundle: Bundle) throws {
        self.name = name

        let modelURL = bundle.bundleURL.appendingPathComponent(name).appendingPathExtension("momd")
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let storeURL = documentsDirectory!.appendingPathComponent(name).appendingPathExtension("model")
        
        print("====================")
        print("Initializing Core Data")
        print("Managed Object Model: \(modelURL)")
        print("Persistent Store: \(storeURL)")
        print("====================")
        

        // Load model.
        let model = NSManagedObjectModel(contentsOf: modelURL)
        
        if (model == nil) {
            fatalError("Cannot load model.")
        }
        
        // Create persistent store coordinator.
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model!)
        
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        try persistentStoreCoordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: storeURL,
            options: options
        )
        
        // Create background managed object context on private queue. Used for persisting data to fixed storage.
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        // Create context on main queue. Used for reading data from the store.
        mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainContext.parent = backgroundContext
        
        //
        changeContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        changeContext.parent = mainContext
        
        // Add notification observers to save the context when the app enters the background.
        NotificationCenter.default.addObserver(self, selector: #selector(onApplicationWillResignActiveNotification), name: .UIApplicationWillResignActive, object: nil)
    }
    
    @objc func onApplicationWillResignActiveNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            self.saveNow()
        }
    }
}

extension CoreDataStack {
    
    //
    //  Execute a block on the change context. Any changes
    //
    func performBackgroundChanges(block: @escaping (NSManagedObjectContext) -> Void) {
        changeContext.perform() {
            block(self.changeContext)
        }
    }
}

extension CoreDataStack {
    
    //
    //
    //
    func autosave(every seconds: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.saveNow()
            self.autosave(every: seconds)
        }
    }
    
    //
    //  Save the background context and persist any pending changes to fixed storage.
    //
    func saveNow(completion: (() -> Void)? = nil) {
        assert(Thread.isMainThread)
        if mainContext.hasChanges {
            do {
                try mainContext.save()
                mainContext.processPendingChanges()
            }
            catch {
                print("Cannot save changes from background context")
            }
        }

        let context = self.backgroundContext
        context.perform() {
            if context.hasChanges {
                print("Saving background context")

                do {
                    try context.save()
                    context.processPendingChanges()
                }
                catch {
                    print("Cannot save background context. Reason: \(error)")
                }
            }
            
            completion?()
        }
    }
}
