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
    
    enum CoreDataManagerError: Error {
        case InvalidSiteName
        case InvalidSiteLocation
    }

    public static let shared = CoreDataManager()
    
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
    
    private lazy var ctx = pc.viewContext
    
    private let log = OSLog(subsystem: "org.ecodatum.EcoDatumCoreData", category: "CoreDataManager")
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willSaveContext),
            name: .NSManagedObjectContextWillSave,
            object: nil)
    }
    
    public func reset() throws {
        try deleteAllSites()
        try save()
    }
    
    public func save() throws {
        try ctx.save()
    }
    
    public func delete(_ object: NSManagedObject) {
        pc.viewContext.delete(object)
    }

    public func newSite(_ name: String, location: CLLocation? = nil) throws -> SiteEntity {
        if name.isEmpty {
            throw CoreDataManagerError.InvalidSiteName
        }
        
        if let location = location, !location.isValid() {
            throw CoreDataManagerError.InvalidSiteLocation
        }
    
        let site = NSEntityDescription.insertNewObject(
            forEntityName: "SiteEntity",
            into: ctx) as! SiteEntity
        
        site.id = UUID()
        site.name = name
        site.createdDate = Date()
        site.updatedDate = Date()
        if let l = location {
            site.altitude = toDecimal(l.altitude)
            site.altitudeAccuracy = toDecimal(l.verticalAccuracy)
            site.coordinateAccuracy = toDecimal(l.horizontalAccuracy)
            site.latitude = toDecimal(l.coordinate.latitude)
            site.longitude = toDecimal(l.coordinate.longitude)
        }
        
        return site 
    }
    
    public func findSite(byId id: UUID) throws -> SiteEntity? {
        let request: NSFetchRequest<SiteEntity> = SiteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id.uuidString)
        let result = try ctx.fetch(request)
        if result.count == 0 {
            return nil
        }
        if result.count > 1 {
            os_log("More than one site found with id: %@", log: log, type: .error, id.uuidString)
        }
        return result[0]
    }
    
    public func siteCount() throws -> Int {
        let request: NSFetchRequest<SiteEntity> = SiteEntity.fetchRequest()
        return try ctx.count(for: request)
    }
    
    public func getAllSites() throws -> [SiteEntity] {
        let request: NSFetchRequest<SiteEntity> = SiteEntity.fetchRequest()
        return try ctx.fetch(request).sorted(by: SiteEntity.sortByName)
    }

    public func deleteAllSites() throws {
        let fetchRequest: NSFetchRequest<SiteEntity> = SiteEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        try ctx.execute(deleteRequest)
    }
    
    public func newEcoDatum(collectionDate: Date,
                            primaryType: String,
                            secondaryType: String,
                            dataType: String,
                            dataUnit: String? = nil,
                            dataValue: Data,
                            parent: EcoDatumEntity? = nil,
                            children: NSSet? = nil,
                            for site: SiteEntity) throws -> EcoDatumEntity {
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
    
    public func findEcoDatum(byId id: UUID) throws -> EcoDatumEntity? {
        let request: NSFetchRequest<EcoDatumEntity> = EcoDatumEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id.uuidString)
        let result = try ctx.fetch(request)
        if result.count == 0 {
            return nil
        }
        if result.count > 1 {
            os_log("More than one ecodatum found with id: %@", log: log, type: .error, id.uuidString)
        }
        return result[0]
    }
    
    public func ecoDatumCount(for site: SiteEntity? = nil) throws -> Int {
        let request: NSFetchRequest<EcoDatumEntity> = EcoDatumEntity.fetchRequest()
        if let site = site {
            request.predicate = NSPredicate(format: "site.id = %@", site.id!.uuidString)
        }
        return try ctx.count(for: request)
    }
    
    public func getAllEcoDatum(for site: SiteEntity? = nil) throws -> [EcoDatumEntity] {
        let request: NSFetchRequest<EcoDatumEntity> = EcoDatumEntity.fetchRequest()
        if let site = site {
            request.predicate = NSPredicate(format: "site.id = %@", site.id!.uuidString)
        }
        return try ctx.fetch(request).sorted(by: EcoDatumEntity.sortByCollectionDate)
    }
    
    public func deleteAllEcoDatum(for site: SiteEntity? = nil) throws {
        let fetchRequest: NSFetchRequest<EcoDatumEntity> = EcoDatumEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        try ctx.execute(deleteRequest)
    }
    
    private func toDecimal(_ value: Decimal) -> NSDecimalNumber {
        return NSDecimalNumber(decimal: value)
    }
    
    private func toDecimal(_ value: Double) -> NSDecimalNumber {
        return toDecimal(Decimal(value))
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
