//
//  Location.swift
//  rainyshinycloudy
//
//  Created by John Martin on 2/6/17.
//  Copyright © 2017 ProObject. All rights reserved.
//

import CoreLocation

class Location {
    static var sharedInstance = Location()
    private init() {}
    
    var latitude: Double!
    var longitude: Double!
}
