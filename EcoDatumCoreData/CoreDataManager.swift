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
    
    private lazy var persistentContainer: NSPersistentContainer = {
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
    
    private init() {
        
    }
    
    public func save() throws {
        try persistentContainer.viewContext.save()
    }
    
    public func newSite(name: String) -> SiteEntity {
        let site = NSEntityDescription.insertNewObject(
            forEntityName: "SiteEntity",
            into: persistentContainer.viewContext) as! SiteEntity
        
        site.id = UUID()
        site.name = name
        site.createdDate = Date()
        site.updatedDate = Date()
        site.altitude = 10.0
        site.altitudeAccuracy = 10.0
        site.coordinateAccuracy = 10.0
        site.latitude = -120.05
        site.longitude = 58.93
        
        return site 
    }
    
    public func delete(_ object: NSManagedObject) {
        persistentContainer.viewContext.delete(object)
    }
    
    public func newEcoDatum(site: SiteEntity) -> EcoDatumEntity {
        let ecoDatum = NSEntityDescription.insertNewObject(
            forEntityName: "EcoDatumEntity",
            into: persistentContainer.viewContext) as! EcoDatumEntity
        
        ecoDatum.id = UUID()
        ecoDatum.site = site
        
        return ecoDatum
    }
    
}
