//
//  NotebookEntity.swift
//  EcoDatumCoreData
//
//  Created by Kenneth Wingerden on 3/16/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import CoreLocation
import Foundation
import SwiftyBeaver

public typealias NotebookEntitySort = (NotebookEntity, NotebookEntity) throws -> Bool

public extension NotebookEntity {
    
    public enum EntityError: Error {
        case InvalidEntity(message: String)
        case InvalidName
        case IDAlreadyExists(id: UUID)
        case NameAlreadyExists(name: String)
        case SiteDoesNotExist(name: String)
    }
    
    override func validateForInsert() throws {
        try super.validateForInsert()
        try validateConsistency()
    }
    
    override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateConsistency()
    }
    
    func validateConsistency() throws {
        
    }

    public static let DEFAULT_NAME = "Default"
    
    public static func new(_ context: NSManagedObjectContext,
                           id: UUID? = nil,
                           name: String = DEFAULT_NAME,
                           createdDate: Date? = nil,
                           updatedDate: Date? = nil,
                           sites: [SiteEntity]? = nil) throws -> NotebookEntity {
        if name.isEmpty {
            throw EntityError.InvalidName
        }
        if let _ = try find(context, by: name) {
            throw EntityError.NameAlreadyExists(name: name)
        }
        
        let notebook = NSEntityDescription.insertNewObject(
            forEntityName: "NotebookEntity",
            into: context) as! NotebookEntity
        
        notebook.id = id == nil ? UUID() : id!
        notebook.name = name
        notebook.createdDate = createdDate == nil ? Date() : createdDate!
        notebook.updatedDate = updatedDate == nil ? Date() : updatedDate!
        
        if let sites = sites {
            for site in sites {
                notebook.addToSites(site)
            }
        }
        
        return notebook
    }
    
    public static func find(_ context: NSManagedObjectContext,
                            by name: String) throws -> NotebookEntity? {
        let request: NSFetchRequest<NotebookEntity> = NotebookEntity.fetchRequest()
        let result = try context.fetch(request)
        return result.count == 0 ? nil : result[0]
    }
    
    public static func all(_ context: NSManagedObjectContext) throws -> [NotebookEntity] {
        let request: NSFetchRequest<NotebookEntity> = NotebookEntity.fetchRequest()
        request.includesSubentities = false
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return try context.fetch(request)
    }
    
    public func delete(_ context: NSManagedObjectContext) {
        context.delete(self)
    }
    
    public static func deleteAll(_ context: NSManagedObjectContext) throws {
        for notebook in try all(context) {
            notebook.delete(context)
        }
    }
    
    public func newSite(_ context: NSManagedObjectContext,
                        name: String,
                        at location: CLLocation? = nil) throws -> SiteEntity {
        return try SiteEntity.new(context, name: name, at: location, in: self)
    }
    
    public func findSite(by name: String) throws -> SiteEntity? {
        return try SiteEntity.find(by: name, in: self)
    }
    
    public func deleteSite(by name: String) throws {
        guard let site = try findSite(by: name) else {
            throw EntityError.SiteDoesNotExist(name: name)
        }
        removeFromSites(site)
    }
    
    public func deleteAllSites() throws {
        if let sites = sites {
            for site in sites {
                let siteEntity = site as! SiteEntity
                removeFromSites(siteEntity)
            }
        }
    }
    
    public func sites(sorted by: SiteEntitySort = SiteEntity.sortByName) throws -> [SiteEntity] {
        guard let sites = sites else {
            return []
        }
        return try sites.map {
            $0 as! SiteEntity
            }.sorted(by: by)
    }
    
    /*
    private static func fetchRequest(_ context: NSManagedObjectContext,
                                     with name: String,
                                     with vars: [String: Any]) -> NSFetchRequest<NotebookEntity>? {
        guard let fetchRequest: NSFetchRequest<NotebookEntity> = context.fetchRequestTemplate(with: name, with: vars) else {
            return nil
        }
        return fetchRequest
    }
 */
    
}
