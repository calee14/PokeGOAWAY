//
//  PokeAnnotation.swift
//  PokeGOAWAY
//
//  Created by Cappillen on 3/5/17.
//  Copyright © 2017 Cappillen. All rights reserved.
//

import UIKit
import MapKit

class PokeAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var pokemon : Pokemon
    
    init(coord: CLLocationCoordinate2D, pokemon: Pokemon) {
        self.coordinate = coord
        self.pokemon = pokemon
    }
}
