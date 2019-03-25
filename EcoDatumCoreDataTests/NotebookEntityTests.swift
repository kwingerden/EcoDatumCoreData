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
        guard let cdm = CoreDataManager.init("EcoDatumV1", ofType: NSInMemoryStoreType) else {
            XCTFail()
            return
        }
        let context = cdm.newDerivedContext()
        
        let id = UUID()
        let createdDate = Date()
        
        expectation(
            forNotification: .NSManagedObjectContextDidSave,
            object: context) { notification in
                return true
        }
        
        let defaultNotebook = NotebookEntity(context: context)
        defaultNotebook.id = id
        defaultNotebook.createdDate = createdDate
        defaultNotebook.updatedDate = createdDate
        cdm.saveContext(context)
        
        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Save did not occur")
        }
        
        expectation(
            forNotification: .NSManagedObjectContextDidSave,
            object: context) { notification in
                let fetchRequest: NSFetchRequest<NotebookEntity> = NotebookEntity.fetchRequest()
                var notebooks: [NotebookEntity]
                do {
                    notebooks = try context.fetch(fetchRequest)
                } catch let error as NSError {
                    XCTFail(error.localizedDescription)
                    return false
                }
                guard notebooks.count == 1, let updatedDate = notebooks[0].updatedDate else {
                    XCTFail("Unexpected number of notebooks")
                    return false
                }
                XCTAssert(updatedDate > createdDate)
                return true
        }
        
        let fetchRequest: NSFetchRequest<NotebookEntity> = NotebookEntity.fetchRequest()
        let notebooks = try context.fetch(fetchRequest)
        XCTAssert(notebooks.count == 1)
        let notebook = notebooks.first!
        XCTAssert(notebook.id == defaultNotebook.id)
        
        notebook.name = "new"
        cdm.saveContext(context)
        
        waitForExpectations(timeout: 5.0) { error in
            XCTAssertNil(error, "Save did not occur")
        }
    }
    
    func test2() throws {
        guard let cdm = CoreDataManager.init("EcoDatumV1", ofType: NSInMemoryStoreType) else {
            XCTFail()
            return
        }
        let context = cdm.newDerivedContext()
        
        let defaultNotebook = NotebookEntity(context: context)
        defaultNotebook.id = UUID()
        defaultNotebook.createdDate = Date()
        defaultNotebook.updatedDate = Date()
        
        expectation(
            forNotification: .NSManagedObjectContextDidSave,
            object: context) { notification in
                return true
        }
        
        cdm.saveContext(context)
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "Save did not occur")
        }
        
        let fetchRequest: NSFetchRequest<NotebookEntity> = NotebookEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name ==[c] %@", "Default")
        let count = try context.count(for: fetchRequest)
        XCTAssert(count == 1)
    }
    
}
