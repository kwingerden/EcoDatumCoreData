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
        let cdm1 = CoreDataManager.init(modelName: "EcoDatumV1")
        let cdm2 = CoreDataManager.init(modelName: "EcoDatumV2")
        
        let defaultNotebook1 = try NotebookEntity.new(cdm1)
        try cdm1.save()
        
        let defaultNotebook2 = try NotebookEntity.new(cdm2)
        try cdm2.save()
        
        print(defaultNotebook1.id!)
        print(defaultNotebook2.id!)
    }
    
}
