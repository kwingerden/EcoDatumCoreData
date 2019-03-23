//
//  SiteEntity.swift
//  EcoDatumCoreData
//
//  Created by Kenneth Wingerden on 3/2/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import CoreLocation
import Foundation
import os

fileprivate let log = OSLog(
    subsystem: "org.ecodatum.EcoDatumCoreData",
    category: "SiteEntity")

public typealias SiteEntitySort = (SiteEntity, SiteEntity) throws -> Bool

public extension SiteEntity {
    
    public enum EntityError: Error {
        case InvalidName
        case InvalidLocation(location: CLLocation)
        case NameAlreadyExists(name: String)
    }
    
    public static var sortByName: SiteEntitySort {
        func sort(_ lhs: SiteEntity, _ rhs: SiteEntity) throws -> Bool {
            return lhs.name! < rhs.name!
        }
        return sort
    }
    
    public static func new(_ cdm: CoreDataManager,
                           name: String,
                           at location: CLLocation? = nil,
                           in notebook: NotebookEntity? = nil,
                           with ecoData: [EcoDatumEntity]? = nil) throws -> SiteEntity {
        if name.isEmpty {
            throw EntityError.InvalidName
        }
        if let location = location, !CLLocationCoordinate2DIsValid(location.coordinate) {
            throw EntityError.InvalidLocation(location: location)
        }
        
        let site = NSEntityDescription.insertNewObject(
            forEntityName: "SiteEntity",
            into: cdm.context) as! SiteEntity
        
        site.id = UUID()
        site.name = name
        site.createdDate = Date()
        site.updatedDate = Date()
        
        if let l = location {
            let coordinate = (NSEntityDescription.insertNewObject(
                forEntityName: "CoordinateEntity",
                into: cdm.context) as! CoordinateEntity)
            coordinate.accuracy = l.horizontalAccuracy
            coordinate.latitude = l.coordinate.latitude
            coordinate.longitude = l.coordinate.longitude
            
            let altitude = (NSEntityDescription.insertNewObject(
                forEntityName: "AltitudeEntity",
                into: cdm.context) as! AltitudeEntity)
            altitude.altitude = l.verticalAccuracy
            altitude.accuracy = l.altitude
            
            let location = (NSEntityDescription.insertNewObject(
                forEntityName: "LocationEntity",
                into: cdm.context) as! LocationEntity)
            
            location.coordinate = coordinate
            location.altitude = altitude
            site.location = location
        }
        
        if let notebook = notebook {
            notebook.addToSites(site)
        }
        
        if let ecoData = ecoData {
            for ecoDatum in ecoData {
                site.addToEcoData(ecoDatum)
            }
        }
        
        return site
    }
    
    public static func find(by name: String,
                            in notebook: NotebookEntity) throws -> SiteEntity? {
        return try notebook.sites().first {
            $0.name?.lowercased() == name
        }
    }
    
    public func delete(_ cdm: CoreDataManager) {
        notebook?.removeFromSites(self)
        cdm.context.delete(self)
    }
    
    public static func deleteAll(_ cdm: CoreDataManager,
                                 in notebook: NotebookEntity) throws {
        for site in try notebook.sites() {
            site.delete(cdm)
        }
    }
    
    public func newEcoDatum(_ cdm: CoreDataManager,
                            collectionDate: Date,
                            primaryType: String,
                            secondaryType: String,
                            dataType: String,
                            dataUnit: String? = nil,
                            dataValue: Data,
                            parent: EcoDatumEntity? = nil,
                            children: [EcoDatumEntity]? = nil) throws -> EcoDatumEntity {
        return try EcoDatumEntity.new(
            cdm,
            collectionDate: collectionDate,
            primaryType: primaryType,
            secondaryType: secondaryType,
            dataType: dataType,
            dataUnit: dataUnit,
            dataValue: dataValue,
            parent: parent,
            children: children,
            to: self)
    }
    
    public func deleteAllEcoData() throws {
        if let ecoData = ecoData {
            for ecoDatum in ecoData {
                let ecoDatumEntity = ecoDatum as! EcoDatumEntity
                removeFromEcoData(ecoDatumEntity)
            }
        }
    }
    
    public func ecoData(sorted by: EcoDatumEntitySort = EcoDatumEntity.sortDescendingByCollectionDate) throws -> [EcoDatumEntity] {
        guard let ecoData = ecoData else {
            return []
        }
        return try ecoData.map {
            $0 as! EcoDatumEntity
            }.sorted(by: by)
    }
    
}
