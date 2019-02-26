//
//  CoreDataManager.swift
//  EcoDatumCoreData
//
//  Created by Kenneth Wingerden on 2/25/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataManager {
    
    public static let shared = CoreDataManager()
    
    private let identifier = "org.ecodatum.EcoDatumCoreData"
    private let model = "Model"
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let messageKitBundle = Bundle(identifier: self.identifier)
        let modelURL = messageKitBundle!.url(forResource: self.model, withExtension: "momd")!
        let managedObjectModel =  NSManagedObjectModel(contentsOf: modelURL)
        let container = NSPersistentContainer(name: self.model, managedObjectModel: managedObjectModel!)
        container.loadPersistentStores {
            (storeDescription, err) in
            if let err = err {
                fatalError("❌ Loading of store failed:\(err)")
            }
        }
        return container
    }()
    
    private init() {
        
    }
    
    public func createSite(name: String) throws -> SiteEntity {
        let context = persistentContainer.viewContext
        let site = NSEntityDescription.insertNewObject(forEntityName: "SiteEntity", into: context) as! SiteEntity
        site.altitude = 10.0
        site.altitudeAccuracy = 10.0
        site.coordinateAccuracy = 10.0
        site.createdDate = Date()
        site.updatedDate = Date()
        site.id = UUID()
        site.latitude = -120.05
        site.longitude = 58.93
        site.name = name
        try context.save()
        return site 
    }
    
    
}
