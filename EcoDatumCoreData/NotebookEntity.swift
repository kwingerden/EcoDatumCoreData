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
import os

fileprivate let log = OSLog(
    subsystem: "org.ecodatum.EcoDatumCoreData",
    category: "NotebookEntity")

public typealias NotebookEntitySort = (NotebookEntity, NotebookEntity) throws -> Bool

public extension NotebookEntity {

    public static let DEFAULT_NAME = "Default"
    
    public enum EntityError: Error {
        case InvalidName
        case NameAlreadyExists(name: String)
        case SiteDoesNotExist(name: String)
    }
    
    public static var sortByName: NotebookEntitySort {
        func sort(_ lhs: NotebookEntity, _ rhs: NotebookEntity) throws -> Bool {
            return lhs.name! < rhs.name!
        }
        return sort
    }
    
    public static var sortByCreatedDate: NotebookEntitySort {
        func sort(_ lhs: NotebookEntity, _ rhs: NotebookEntity) throws -> Bool {
            return lhs.createdDate! > rhs.createdDate!
        }
        return sort
    }
    
    public static var sortByUpdatedDate: NotebookEntitySort {
        func sort(_ lhs: NotebookEntity, _ rhs: NotebookEntity) throws -> Bool {
            return lhs.updatedDate! > rhs.updatedDate!
        }
        return sort
    }
    
    public static func new(_ cdm: CoreDataManager,
                           id: UUID? = nil,
                           name: String = DEFAULT_NAME,
                           createdDate: Date? = nil,
                           updatedDate: Date? = nil,
                           sites: [SiteEntity]? = nil) throws -> NotebookEntity {
        if name.isEmpty {
            throw EntityError.InvalidName
        }
        if let _ = try find(cdm, by: name) {
            throw EntityError.NameAlreadyExists(name: name)
        }
        
        let notebook = NSEntityDescription.insertNewObject(
            forEntityName: "NotebookEntity",
            into: cdm.context) as! NotebookEntity
        
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
    
    public static func find(_ cdm: CoreDataManager,
                            by name: String) throws -> NotebookEntity? {
        let request: NSFetchRequest<NotebookEntity> = NotebookEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[c] %@", name)
        let result = try cdm.context.fetch(request)
        if result.count == 0 {
            return nil
        }
        if result.count > 1 {
            os_log("More than one Notebook found with name: %@", log: log, type: .error, name)
        }
        return result[0]
    }
    
    public static func all(_ cdm: CoreDataManager,
                           sorted by: NotebookEntitySort = sortByName) throws -> [NotebookEntity] {
        let request: NSFetchRequest<NotebookEntity> = NotebookEntity.fetchRequest()
        return try cdm.context.fetch(request).sorted(by: by)
    }
    
    public func delete(_ cdm: CoreDataManager) {
        cdm.context.delete(self)
    }
    
    public static func deleteAll(_ cdm: CoreDataManager) throws {
        for notebook in try all(cdm) {
            notebook.delete(cdm)
        }
    }
    
    public func newSite(_ cdm: CoreDataManager,
                        name: String,
                        at location: CLLocation? = nil) throws -> SiteEntity {
        return try SiteEntity.new(cdm, name: name, at: location, in: self)
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
    
}
