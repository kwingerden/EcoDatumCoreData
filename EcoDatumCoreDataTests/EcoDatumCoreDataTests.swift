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
        let site1 = try CoreDataManager.shared.createSite(name: "test1")
        print(site1.name!)
        print("done")
    }
}
