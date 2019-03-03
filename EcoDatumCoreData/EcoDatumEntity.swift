//
//  EcoDatumEntity.swift
//  EcoDatumCoreData
//
//  Created by Kenneth Wingerden on 3/2/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import Foundation

public extension EcoDatumEntity {
    
    public static func sortByCollectionDate(_ lhs: EcoDatumEntity, _ rhs: EcoDatumEntity) throws -> Bool  {
        return lhs.collectionDate! < rhs.collectionDate!
    }
    
}
