//
//  EcoDatumEntityTests.swift
//  EcoDatumCoreDataTests
//
//  Created by Kenneth Wingerden on 3/17/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreLocation
import EcoDatumCommon
import Foundation
import XCTest
@testable import EcoDatumCoreData

class EcoDatumEntityTests: XCTestCase {
    
    override func setUp() {
        do {
            try CoreDataManager.shared.reset()
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    override func tearDown() {
    }
    
    func test1() throws {
        let defaultNotebook = try NotebookEntity.new()
        let site1 = try defaultNotebook.newSite(
            name: "site1",
            at: CLLocation(
                coordinate: CLLocationCoordinate2DMake(37.33182, -122.03118),
                altitude: 10.0,
                horizontalAccuracy: 10.0,
                verticalAccuracy: 10.0,
                timestamp: Date()))
        let _ = try site1.newEcoDatum(
            collectionDate: "2019-02-24T04:38:31Z".iso8601Date()!,
            primaryType: "primaryType1",
            secondaryType: "secondaryType1",
            dataType: "dataType1",
            dataValue: "data1".data(using: .utf8)!)
        
        XCTAssert(site1.ecoData?.count == 1)
        
        let _ = try site1.newEcoDatum(
            collectionDate: "2019-03-17T14:12:10Z".iso8601Date()!,
            primaryType: "primaryType2",
            secondaryType: "secondaryType2",
            dataType: "dataType2",
            dataValue: "data2".data(using: .utf8)!)
        let _ = try site1.newEcoDatum(
            collectionDate: "2018-11-01T10:22:45Z".iso8601Date()!,
            primaryType: "primaryType3",
            secondaryType: "secondaryType3",
            dataType: "dataType3",
            dataValue: "data3".data(using: .utf8)!)
        
        XCTAssert(site1.ecoData?.count == 3)
        
        let ecoDataDescending = try site1.ecoData()
        XCTAssert(ecoDataDescending[0].primaryType == "primaryType2")
        XCTAssert(ecoDataDescending[1].primaryType == "primaryType1")
        XCTAssert(ecoDataDescending[2].primaryType == "primaryType3")
        
        let ecoDataAscending = try site1.ecoData(sorted: EcoDatumEntity.sortAscendingByCollectionDate)
        XCTAssert(ecoDataAscending[0].primaryType == "primaryType3")
        XCTAssert(ecoDataAscending[1].primaryType == "primaryType1")
        XCTAssert(ecoDataAscending[2].primaryType == "primaryType2")
        
    }
}
