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
        let defaultNotebook = try NotebookEntity.new()
        print(defaultNotebook.id!)
    }
    
}
