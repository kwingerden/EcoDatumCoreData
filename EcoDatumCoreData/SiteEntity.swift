//
//  SiteEntity.swift
//  EcoDatumCoreData
//
//  Created by Kenneth Wingerden on 3/2/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import Foundation

public extension SiteEntity {
    
    public static func sortByName(_ lhs: SiteEntity, _ rhs: SiteEntity) throws -> Bool  {
        return lhs.name! > rhs.name!
    }
    
}
