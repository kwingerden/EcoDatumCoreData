//
//  EcoDatumEntity.swift
//  EcoDatumCoreData
//
//  Created by Kenneth Wingerden on 3/2/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import Foundation

public typealias EcoDatumEntitySort = (EcoDatumEntity, EcoDatumEntity) throws -> Bool

public extension EcoDatumEntity {
    
    public enum EntityError: Error {
        case InvalidPrimaryType(primaryType: String)
        case InvalidSecondaryType(secondaryType: String)
        case InvalidDataType(dataType: String)
        case InvalidDataUnit(dataUnit: String)
    }
    
    public static var sortDescendingByCollectionDate: EcoDatumEntitySort {
        func sort(_ lhs: EcoDatumEntity, _ rhs: EcoDatumEntity) throws -> Bool {
            return lhs.collectionDate! > rhs.collectionDate!
        }
        return sort
    }
    
    public static var sortAscendingByCollectionDate: EcoDatumEntitySort {
        func sort(_ lhs: EcoDatumEntity, _ rhs: EcoDatumEntity) throws -> Bool {
            return lhs.collectionDate! < rhs.collectionDate!
        }
        return sort
    }
    
    public static func new(_ context: NSManagedObjectContext,
                           collectionDate: Date,
                           primaryType: String,
                           secondaryType: String,
                           dataType: String,
                           dataUnit: String? = nil,
                           dataValue: Data,
                           parent: EcoDatumEntity? = nil,
                           children: [EcoDatumEntity]? = nil,
                           to site: SiteEntity? = nil) throws -> EcoDatumEntity {
        if primaryType.isEmpty {
            throw EntityError.InvalidPrimaryType(primaryType: primaryType)
        }
        if secondaryType.isEmpty {
            throw EntityError.InvalidSecondaryType(secondaryType: secondaryType)
        }
        if dataType.isEmpty {
            throw EntityError.InvalidDataType(dataType: dataType)
        }
        if let dataUnit = dataUnit, dataUnit.isEmpty {
            throw EntityError.InvalidDataUnit(dataUnit: dataUnit)
        }
        
        let ecoDatum = NSEntityDescription.insertNewObject(
            forEntityName: "EcoDatumEntity",
            into: context) as! EcoDatumEntity
        
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
        
        if let children = children {
            ecoDatum.children?.addingObjects(from: children)
        } else {
            ecoDatum.children = nil
        }
        
        if let site = site {
            site.addToEcoData(ecoDatum)
        }
        
        return ecoDatum
    }
    
    public func delete(context: NSManagedObjectContext) {
        site?.removeFromEcoData(self)
        context.delete(self)
    }
    
    public static func deleteAll(in site: SiteEntity) throws {
        try site.deleteAllEcoData()
    }
    
}
