//
//  EcoDatumCoreDataTests.swift
//  EcoDatumCoreDataTests
//
//  Created by Kenneth Wingerden on 2/25/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import XCTest
import Foundation
import CoreData
import CoreLocation
import EcoDatumCommon
@testable import EcoDatumCoreData

class CoreDataManagerTests: XCTestCase {
    
    var persistentContainer: NSPersistentContainer!
    
    let mgr = CoreDataManager.shared
    
    override func setUp() {
        do {
            try mgr.reset()
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    override func tearDown() {
    }
    
    func test1() throws {
        let site1 = try mgr.newSite("Site1")
        let site2 = try mgr.newSite("Site2")
        let site3 = try mgr.newSite("Site3")
        let sitesOriginal = try [site1, site2, site3].sorted(by: SiteEntity.sortByName)
        try mgr.save()
        
        let sitesLoaded = try mgr.getAllSites().sorted(by: SiteEntity.sortByName)
        XCTAssert(try mgr.getAllSites().count == 3)
        XCTAssert(try mgr.siteCount() == 3)
        XCTAssert(sitesOriginal == sitesLoaded)
        
        mgr.delete(site1)
        try mgr.save()
        XCTAssert(try mgr.getAllSites().count == 2)
    }
    
    func test2() throws {
        let location1 = CLLocation(latitude: 37.33182, longitude: -122.03118)
        let site1 = try mgr.newSite("Site1", location: location1)
        try mgr.save()
        let site2 = try mgr.findSite(byId: site1.id!)
        XCTAssert(site1 == site2)
    }
    
    func test3() throws {
        let site1Location = CLLocation(latitude: 37.33182, longitude: -122.03118)
        let site1 = try mgr.newSite("Site1", location: site1Location)
        
        let site1EcoDatum1 = try mgr.newEcoDatum(
            collectionDate: "2018-05-24T04:38:31Z".iso8601Date()!,
            primaryType: "primaryType11",
            secondaryType: "secondaryType",
            dataType: "dataType",
            dataValue: "dataValue".data(using: .utf8)!,
            for: site1)
        site1.addToEcoData(site1EcoDatum1)
        
        let site1EcoDatum2 = try mgr.newEcoDatum(
            collectionDate: "2018-01-24T04:38:31Z".iso8601Date()!,
            primaryType: "primaryType12",
            secondaryType: "secondaryType",
            dataType: "dataType",
            dataValue: "dataValue".data(using: .utf8)!,
            for: site1)
        site1EcoDatum2.addToChildren(site1EcoDatum1)
        site1.addToEcoData(site1EcoDatum2)
        
        let site1EcoDatum3 = try mgr.newEcoDatum(
            collectionDate: "2018-03-24T04:38:31Z".iso8601Date()!,
            primaryType: "primaryType13",
            secondaryType: "secondaryType",
            dataType: "dataType",
            dataValue: "dataValue".data(using: .utf8)!,
            for: site1)
        site1.addToEcoData(site1EcoDatum3)
        
        let site2Location = CLLocation(latitude: 37.33182, longitude: -122.03118)
        let site2 = try mgr.newSite("Site2", location: site2Location)
        
        let site2EcoDatum1 = try mgr.newEcoDatum(
            collectionDate: "2018-10-24T04:38:31Z".iso8601Date()!,
            primaryType: "primaryType21",
            secondaryType: "secondaryType",
            dataType: "dataType",
            dataValue: "dataValue".data(using: .utf8)!,
            for: site2)
        site2.addToEcoData(site2EcoDatum1)
        
        try mgr.save()
        
        XCTAssert(try mgr.getAllEcoDatum().count == 4)
        XCTAssert(try mgr.getAllEcoDatum() == [site1EcoDatum2, site1EcoDatum3, site1EcoDatum1, site2EcoDatum1])
        XCTAssert(try mgr.ecoDatumCount() == 4)
        
        XCTAssert(try mgr.getAllEcoDatum(for: site1).count == 3)
        XCTAssert(try mgr.getAllEcoDatum(for: site1) == [site1EcoDatum2, site1EcoDatum3, site1EcoDatum1])
        XCTAssert(try mgr.ecoDatumCount(for: site1) == 3)
        
        XCTAssert(try mgr.getAllEcoDatum(for: site2).count == 1)
        XCTAssert(try mgr.ecoDatumCount(for: site2) == 1)
        
        let site1EcoDatum1Loaded = try mgr.findEcoDatum(byId: site1EcoDatum1.id!)
        XCTAssert(site1EcoDatum1Loaded?.site == site1)
        XCTAssert(site1EcoDatum1Loaded?.parent != nil)
        XCTAssert(site1EcoDatum1Loaded?.children!.count == 0)
        
        let site1EcoDatum2Loaded = try mgr.findEcoDatum(byId: site1EcoDatum2.id!)
        XCTAssert(site1EcoDatum2Loaded?.site == site1)
        XCTAssert(site1EcoDatum2Loaded?.parent == nil)
        XCTAssert(site1EcoDatum2Loaded?.children!.count == 1)
    }
    
}
