//
//  CoreDataManager.swift
//  EcoDatumCoreData
//
//  Created by Kenneth Wingerden on 2/25/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import EcoDatumCommon
import SwiftyBeaver

private let log = SwiftyBeaver.self

public class CoreDataManager {
    
    public let modelName: String
    
    public let container: NSPersistentContainer
    
    public let mainContext: NSManagedObjectContext
    
    public init?(_ modelName: String,
                 ofType storeType: String = NSSQLiteStoreType,
                 at storeURL: URL = NSPersistentContainer.defaultDirectoryURL()) {
        self.modelName = modelName
        
        let bundle = Bundle(identifier: "org.ecodatum.EcoDatumCoreData")!
        let modelURL = bundle.url(forResource: "Model", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        let container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel!)
        
        switch storeType {
        case NSInMemoryStoreType:
            do {
                try container.persistentStoreCoordinator.addPersistentStore(
                    ofType: NSInMemoryStoreType,
                    configurationName: "Default",
                    at: nil,
                    options: nil)
            } catch let error as NSError {
                log.error("Failed to add in-memory persistent store: \(error)")
                return nil
            }
        case NSSQLiteStoreType:
            do {
                try container.persistentStoreCoordinator.addPersistentStore(
                    ofType: NSSQLiteStoreType,
                    configurationName: "Default",
                    at: storeURL.appendingPathComponent(modelName),
                    options: nil)
            } catch let error as NSError {
                log.error("Failed to add SQLite persistent store: \(error)")
                return nil
            }
        default:
            log.error("Store type is not supported: \(storeType)")
            return nil
        }
        
        self.container = container
        self.mainContext = container.viewContext
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.willSaveContext),
            name: .NSManagedObjectContextWillSave,
            object: nil)
    }
    
    public func newDerivedContext() -> NSManagedObjectContext {
        return container.newBackgroundContext()
    }
    
    public func saveContext() {
        saveContext(mainContext)
    }
    
    public func saveContext(_ context: NSManagedObjectContext) {
        if context != mainContext {
            saveDerivedContext(context)
            return
        }
        
        context.perform {
            do {
                try context.save()
            } catch let error as NSError {
                log.error("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    public func saveDerivedContext(_ context: NSManagedObjectContext) {
        context.perform {
            do {
                try context.save()
            } catch let error as NSError {
                log.error("Unresolved error \(error), \(error.userInfo)")
            }
            self.saveContext(self.mainContext)
        }
    }
    
    @objc private func willSaveContext(_ notification: NSNotification) {
        if let context = notification.object as? NSManagedObjectContext {
            context.updatedObjects.forEach {
                if let _ = $0.entity.propertiesByName["updatedDate"] {
                    $0.setValue(Date(), forKey: "updatedDate")
                }
            }
        }
    }
    
}
