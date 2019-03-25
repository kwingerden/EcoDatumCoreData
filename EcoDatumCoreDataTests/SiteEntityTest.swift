//
//  SiteEntityTest.swift
//  EcoDatumCoreDataTests
//
//  Created by Kenneth Wingerden on 3/17/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreLocation
import CoreData
import EcoDatumCommon
import Foundation
import XCTest
import SwiftyBeaver
@testable import EcoDatumCoreData

class SiteEntityTests: XCTestCase {
    
    let log = SwiftyBeaver.self
    let consoleDestination = ConsoleDestination()
    
    override func setUp() {
        if !log.destinations.contains(consoleDestination) {
            log.addDestination(consoleDestination)
        }
    }
    
    func test1() throws {
        /*
        guard let cdm1 = CoreDataManager.init("EcoDatumV1", ofType: NSInMemoryStoreType) else {
            XCTFail()
            return
        }
        let context = cdm1.container.newBackgroundContext()
        
        let defaultNotebook = try NotebookEntity.new(context)
        XCTAssert(try defaultNotebook.sites().count == 0)
        
        let _ = try defaultNotebook.newSite(
            context,
            name: "site1",
            at: CLLocation(
                coordinate: CLLocationCoordinate2DMake(37.33182, -122.03118),
                altitude: 10.0,
                horizontalAccuracy: 10.0,
                verticalAccuracy: 10.0,
                timestamp: Date()))
        
        try context.save()
        
        do {
            let _ = try SiteEntity.new(context, name: "site1", in: defaultNotebook)
            XCTFail()
            return
        } catch {
            // Expected, do nothing
        }
        
        XCTAssert(try defaultNotebook.sites().count == 1)
        
        let site2 = try defaultNotebook.newSite(context, name: "2site")
        let site3 = try defaultNotebook.newSite(context, name: "site3")
        let _ = try defaultNotebook.newSite(context, name: "site4")
        
        XCTAssert(try defaultNotebook.findSite(by: "2site")?.id == site2.id)
        
        XCTAssert(try defaultNotebook.sites().count == 4)
        
        site3.delete(context)
        
        let sites = try defaultNotebook.sites()
        XCTAssert(sites.count == 3)
        XCTAssert(sites[0].name == "2site")
        XCTAssert(sites[1].name == "site1")
        XCTAssert(sites[2].name == "site4")
        
        try defaultNotebook.deleteSite(by: "site4")
        XCTAssert(try defaultNotebook.sites().count == 2)
        
        XCTAssert(try SiteEntity.find(by: "test1", in: defaultNotebook) == nil)
        XCTAssert(try SiteEntity.find(by: "site1", in: defaultNotebook)?.location?.altitude?.altitude == 10.0)
        
        try SiteEntity.deleteAll(context, in: defaultNotebook)
        XCTAssert(try defaultNotebook.sites().count == 0)
 */
    }
    
}
