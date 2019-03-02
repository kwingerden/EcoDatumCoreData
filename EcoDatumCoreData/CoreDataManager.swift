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

public class CoreDataManager {
    
    enum CDMError: Error {
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
    
    private init() {
        
    }
    
    public func deleteAllSites() throws {
        let fetchRequest: NSFetchRequest<SiteEntity> = SiteEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        try ctx.execute(deleteRequest)
    }
    
    public func save() throws {
        try ctx.save()
    }
    
    public func siteCount() throws -> Int {
        let request: NSFetchRequest<SiteEntity> = SiteEntity.fetchRequest()
        return try ctx.count(for: request)
    }
    
    public func getAllSites() throws -> [SiteEntity] {
        let request: NSFetchRequest<SiteEntity> = SiteEntity.fetchRequest()
        return try ctx.fetch(request)
    }
        
    /*
    public func getSiteById(_ id: UUID) -> SiteEntity {
        let request: NSFetchRequest<SiteEntity> = SiteEntity.fetchRequest()
        request.predicate = NSPredicate(format: <#T##String#>, <#T##args: CVarArg...##CVarArg#>)
    }
 */
    
    public func newSite(name: String, location: CLLocation? = nil) throws -> SiteEntity {
        if name.isEmpty {
            throw CDMError.InvalidSiteName
        }
        
        if let location = location, !location.isValid() {
            throw CDMError.InvalidSiteLocation
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
    
    public func delete(_ object: NSManagedObject) {
        pc.viewContext.delete(object)
    }
    
    public func newEcoDatum(site: SiteEntity) -> EcoDatumEntity {
        let ecoDatum = NSEntityDescription.insertNewObject(
            forEntityName: "EcoDatumEntity",
            into: pc.viewContext) as! EcoDatumEntity
        
        ecoDatum.id = UUID()
        ecoDatum.site = site
        
        return ecoDatum
    }
    
    private func toDecimal(_ value: Decimal) -> NSDecimalNumber {
        return NSDecimalNumber(decimal: value)
    }
    
    private func toDecimal(_ value: Double) -> NSDecimalNumber {
        return toDecimal(Decimal(value))
    }
    
}
