//
//  Location.swift
//  EcoDatumCoreData
//
//  Created by Kenneth Wingerden on 3/1/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocation {
    
    func isValid() -> Bool {
        return CLLocationCoordinate2DIsValid(coordinate) &&
            horizontalAccuracy >= 0 &&
            verticalAccuracy >= 0
    }
    
}
