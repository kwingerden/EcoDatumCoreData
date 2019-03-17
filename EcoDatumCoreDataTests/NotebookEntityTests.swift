//
//  NotebookEntityTests.swift
//  EcoDatumCoreDataTests
//
//  Created by Kenneth Wingerden on 3/17/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import EcoDatumCommon
import Foundation
import XCTest
@testable import EcoDatumCoreData

class NotebookEntityTests: XCTestCase {
    
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
        XCTAssert(defaultNotebook.name == NotebookEntity.DEFAULT_NAME)
        XCTAssert(try defaultNotebook.sites().isEmpty)
        
        do {
            let _ = try NotebookEntity.new()
            XCTFail()
        } catch {
            // Expected, do nothing.
        }
        
        XCTAssert(try NotebookEntity.all().count == 1)
        
        let notebook = try NotebookEntity.find(by: "deFault")
        XCTAssert(notebook?.id == defaultNotebook.id)
        
        defaultNotebook.delete()
        XCTAssert(try NotebookEntity.all().count == 0)
        XCTAssert(try NotebookEntity.find(by: NotebookEntity.DEFAULT_NAME) == nil)
    }
    
    func test2() throws {
        let _ = try NotebookEntity.new()
        let notebook1 = try NotebookEntity.new(name: "notebook1")
        let _ = try NotebookEntity.new(name: "notebook2")
        let _ = try NotebookEntity.new(name: "notebook3")
        
        do {
            let _ = try NotebookEntity.new(name: "notebook1")
            XCTFail()
        } catch {
            // Expected, do nothing.
        }
        
        XCTAssert(try NotebookEntity.all().count == 4)
        
        notebook1.delete()
        XCTAssert(try NotebookEntity.all().count == 3)
        XCTAssert(try NotebookEntity.find(by: "notebook1") == nil)
        
        let notebooks = try NotebookEntity.all()
        XCTAssert(notebooks[0].name == NotebookEntity.DEFAULT_NAME)
        XCTAssert(notebooks[1].name == "notebook2")
        XCTAssert(notebooks[2].name == "notebook3")
    }
    
}
