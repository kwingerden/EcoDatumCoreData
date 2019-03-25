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
import SwiftyBeaver
@testable import EcoDatumCoreData

class CoreDataManagerTests: XCTestCase {
    
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
        guard let cdm2 = CoreDataManager.init("EcoDatumV2", ofType: NSInMemoryStoreType) else {
            XCTFail()
            return
        }
        
        let context1 = cdm1.container.newBackgroundContext()
        let context2 = cdm2.container.newBackgroundContext()
        
        let defaultNotebook1 = try NotebookEntity.new(context1)
        try context1.save()
        
        let defaultNotebook2 = try NotebookEntity.new(context2)
        try context2.save()
        
        print(defaultNotebook1.id!)
        print(defaultNotebook2.id!)
 */
    }
    
}
