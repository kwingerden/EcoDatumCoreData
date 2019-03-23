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
    
    let modelName: String
    
    let container: NSPersistentContainer
    
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.willSaveContext),
            name: .NSManagedObjectContextWillSave,
            object: nil)
    }
    
    private func persistentStoreHandler(description: NSPersistentStoreDescription, error: Error?) {
        if let error = error as NSError? {
            log.error("Failed to create persistent store for model: \(modelName), \(error.description), \(error.userInfo)")
        } else {
            log.info("Successfully created persistent store for model: \(modelName), \(description.url!.absoluteString)")
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
