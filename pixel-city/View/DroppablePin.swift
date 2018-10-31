//
//  DroaplePin.swift
//  pixel-city
//
//  Created by Abdelhamid Naeem on 10/31/18.
//  Copyright © 2018 Abdelhamid Naeem. All rights reserved.
//

import UIKit
import MapKit


class DroppablePin: NSObject, MKAnnotation {
    dynamic var coordinate : CLLocationCoordinate2D
    var identifier : String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String){
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
