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

class CoreDataManager {
    
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
    
    func reset() throws {
        try NotebookEntity.deleteAll()
        try save()
    }
    
    public func save() throws {
        try ctx.save()
    }
    
    /*
    public func addSite(name: String, location: CLLocation? = nil, to notebook: NotebookEntity) throws -> SiteEntity {
        if name.isEmpty {
            throw CoreDataManagerError.InvalidSiteName
        }
        if let _ = findSite(by: name, in: notebook) {
            throw CoreDataManagerError.SiteWithNameAlreadyExists(name: name)
        }
        
        let site = NSEntityDescription.insertNewObject(
            forEntityName: "SiteEntity",
            into: ctx) as! SiteEntity
        
        site.id = UUID()
        site.name = name
        site.createdDate = Date()
        site.updatedDate = Date()
        if let l = location {
            site.altitude = l.altitude
            site.altitudeAccuracy = l.verticalAccuracy
            site.coordinateAccuracy = l.horizontalAccuracy
            site.latitude = l.coordinate.latitude
            site.longitude = l.coordinate.longitude
        }
        site.notebook = notebook
        
        return site 
    }
    
    public func findSite(by name: String, in notebook: NotebookEntity) -> SiteEntity? {
        guard let sites = notebook.sites else {
            return nil
        }
        for s in sites {
            let site = (s as! SiteEntity)
            if name.lowercased() == site.name!.lowercased() {
                return site
            }
        }
        return nil
    }
    
    public func getAllSites(in notebook: NotebookEntity) throws -> [SiteEntity] {
        let request: NSFetchRequest<NotebookEntity> = NotebookEntity.fetchRequest()
        return try ctx.fetch(request).sorted(by: NotebookEntity.sortByName(_:_:))
    }
    
    public func addEcoDatum(collectionDate: Date,
                            primaryType: String,
                            secondaryType: String,
                            dataType: String,
                            dataUnit: String? = nil,
                            dataValue: Data,
                            parent: EcoDatumEntity? = nil,
                            children: NSSet? = nil,
                            to site: SiteEntity) throws -> EcoDatumEntity {
        let ecoDatum = NSEntityDescription.insertNewObject(
            forEntityName: "EcoDatumEntity",
            into: pc.viewContext) as! EcoDatumEntity
        
        ecoDatum.id = UUID()
        ecoDatum.createdDate = Date()
        ecoDatum.updatedDate = Date()
        ecoDatum.collectionDate = collectionDate
        ecoDatum.primaryType = primaryType
        ecoDatum.secondaryType = secondaryType
        ecoDatum.dataType = dataType
        ecoDatum.dataUnit = dataUnit
        ecoDatum.dataValue = dataValue
        ecoDatum.parent = parent
        ecoDatum.children = children
        ecoDatum.site = site
    
        return ecoDatum
    }
    */
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
