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
@testable import EcoDatumCoreData

class EcoDatumCoreDataTests: XCTestCase {
    
    var persistentContainer: NSPersistentContainer!
    
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    func test1() throws {
        let mgr = CoreDataManager.shared
        try mgr.reset()
        
        let site1 = try mgr.newSite(name: "Site1")
        let site2 = try mgr.newSite(name: "Site2")
        let site3 = try mgr.newSite(name: "Site3")
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
        let mgr = CoreDataManager.shared
        try mgr.reset()
        
        let location1 = CLLocation(latitude: 37.33182, longitude: -122.03118)
        let site1 = try mgr.newSite(name: "Site1", location: location1)
        
        let site1EcoDatum1 = mgr.newEcoDatum(site: <#T##SiteEntity#>)
        
    }
    
}
