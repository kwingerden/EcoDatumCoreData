//
//  NotebookEntityTests.swift
//  EcoDatumCoreDataTests
//
//  Created by Kenneth Wingerden on 3/17/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import EcoDatumCommon
import CoreData
import Foundation
import XCTest
import SwiftyBeaver
@testable import EcoDatumCoreData

class NotebookEntityTests: XCTestCase {
    
    let log = SwiftyBeaver.self
    let consoleDestination = ConsoleDestination()
    
    override func setUp() {
        if !log.destinations.contains(consoleDestination) {
            log.addDestination(consoleDestination)
        }
    }
    
    func test1() throws {
        guard let cdm1 = CoreDataManager.init("EcoDatumV1", ofType: NSInMemoryStoreType) else {
            XCTFail()
            return
        }
        let context = cdm1.container.newBackgroundContext()
        
        let defaultNotebook = try NotebookEntity.new(context)
        XCTAssert(defaultNotebook.name == NotebookEntity.DEFAULT_NAME)
        XCTAssert(try defaultNotebook.sites().isEmpty)
        
        try context.save()
        
        do {
            let _ = try NotebookEntity.new(context)
            XCTFail()
        } catch {
            // Expected, do nothing.
        }
        
        XCTAssert(try NotebookEntity.all(context).count == 1)
        
        let notebook = try NotebookEntity.find(context, by: "deFault")
        XCTAssert(notebook?.id == defaultNotebook.id)
        
        defaultNotebook.delete(context)
        XCTAssert(try NotebookEntity.all(context).count == 0)
        XCTAssert(try NotebookEntity.find(context, by: NotebookEntity.DEFAULT_NAME) == nil)
    }
    
    func test2() throws {
        guard let cdm1 = CoreDataManager.init("EcoDatumV1", ofType: NSInMemoryStoreType) else {
            XCTFail()
            return
        }
        let context = cdm1.container.newBackgroundContext()
        
        let _ = try NotebookEntity.new(context)
        let notebook1 = try NotebookEntity.new(context, name: "notebook1")
        let _ = try NotebookEntity.new(context, name: "notebook2")
        let _ = try NotebookEntity.new(context, name: "notebook3")
        
        try context.save()
        
        do {
            let _ = try NotebookEntity.new(context, name: "notebook1")
            XCTFail()
        } catch {
            // Expected, do nothing.
        }
        
        XCTAssert(try NotebookEntity.all(context).count == 4)
        
        notebook1.delete(context)
        XCTAssert(try NotebookEntity.all(context).count == 3)
        XCTAssert(try NotebookEntity.find(context, by: "notebook1") == nil)
        
        let notebooks = try NotebookEntity.all(context)
        XCTAssert(notebooks[0].name == NotebookEntity.DEFAULT_NAME)
        XCTAssert(notebooks[1].name == "notebook2")
        XCTAssert(notebooks[2].name == "notebook3")
    }
    
}
