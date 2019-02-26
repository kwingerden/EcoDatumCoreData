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
        let dm = CoreDataManager.shared
        let site1 = dm.newSite(name: "Site1")
        let site2 = dm.newSite(name: "Site2")
        let site3 = dm.newSite(name: "Site3")
        
        try dm.save()
        
        print(site1.name!)
        print(site2.name!)
        print(site3.name!)
        
        dm.delete(site1)
        try dm.save()
    }
}
