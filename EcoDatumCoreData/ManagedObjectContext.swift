//
//  ManagedObjectContext.swift
//  EcoDatumCoreData
//
//  Created by Kenneth Wingerden on 3/23/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import Foundation

extension NSManagedObjectContext {
    
    func fetchRequestTemplate<T>(for name: String, with vars: [String:Any]) -> NSFetchRequest<T>? {
        guard let objectModel = persistentStoreCoordinator?.managedObjectModel,
            let fetchRequest = objectModel.fetchRequestFromTemplate(withName: name, substitutionVariables: vars) as? NSFetchRequest<T> else {
                return nil
        }
        return fetchRequest
    }
    
}
