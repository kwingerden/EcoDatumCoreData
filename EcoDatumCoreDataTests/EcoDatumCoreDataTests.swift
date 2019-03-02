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
@testable import EcoDatumCoreData

class EcoDatumCoreDataTests: XCTestCase {
    
    var persistentContainer: NSPersistentContainer!
    
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    func test1() throws {
        let mgr = CoreDataManager.shared
        try mgr.deleteAllSites()
        try mgr.save()
        
        let site1 = try mgr.newSite(name: "Site1")
        let site2 = try mgr.newSite(name: "Site2")
        let site3 = try mgr.newSite(name: "Site3")
        let sitesOriginal = try [site1, site2, site3].sorted(by: sortSitesByName)
        try mgr.save()
        
        let sitesLoaded = try mgr.getAllSites().sorted(by: sortSitesByName)
        XCTAssert(try mgr.getAllSites().count == 3)
        XCTAssert(try mgr.siteCount() == 3)
        XCTAssert(sitesOriginal == sitesLoaded)
        
        mgr.delete(site1)
        try mgr.save()
        XCTAssert(try mgr.getAllSites().count == 2)
    }
    
    func sortSitesByName(_ lhs: SiteEntity, _ rhs: SiteEntity) throws -> Bool {
        return lhs.name! > rhs.name!
    }
}
