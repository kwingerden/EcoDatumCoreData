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
import os

public class CoreDataManager {
    
    public static let shared = CoreDataManager()
    
    lazy var ctx = pc.viewContext
    
    private lazy var pc: NSPersistentContainer = {
        let bundle = Bundle(identifier: "org.ecodatum.EcoDatumCoreData")!
        let modelURL = bundle.url(forResource: "Model", withExtension: "momd")!
        let managedObjectModel =  NSManagedObjectModel(contentsOf: modelURL)
        let container = NSPersistentContainer(name: "Model", managedObjectModel: managedObjectModel!)
        container.loadPersistentStores {
            (storeDescription, err) in
            if let err = err {
                fatalError("Failed to load Core Data Model: \(err)")
            }
        }
        return container
    }()
    
    private let log = OSLog(subsystem: "org.ecodatum.EcoDatumCoreData", category: "CoreDataManager")
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willSaveContext),
            name: .NSManagedObjectContextWillSave,
            object: nil)
    }
    
    public func reset() throws {
        try NotebookEntity.deleteAll()
        try save()
    }
    
    public func save() throws {
        try ctx.save()
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
