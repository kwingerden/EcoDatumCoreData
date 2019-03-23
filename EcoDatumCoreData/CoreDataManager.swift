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

public class CoreDataManager {
    
    private let log = SwiftyBeaver.self
    
    public lazy var context: NSManagedObjectContext = {
        return self.container.viewContext
    }()
    
    private let modelName: String
    
    private lazy var container: NSPersistentContainer = {
        let bundle = Bundle(identifier: "org.ecodatum.EcoDatumCoreData")!
        let modelURL = bundle.url(forResource: "Model", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        let container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel!)
        //container.persistentStoreDescriptions.append(NSPersistentStoreDescription(url: <#T##URL#>))
        container.loadPersistentStores(completionHandler: persistentStoreHandler)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.willSaveContext),
            name: .NSManagedObjectContextWillSave,
            object: nil)
        
        return container
    }()
    
    public init(modelName: String) {
        self.modelName = modelName
    }
    
    public func save() throws {
        guard context.hasChanges else {
            return
        }
        try context.save()
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
