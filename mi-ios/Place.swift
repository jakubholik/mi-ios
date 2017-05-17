//
//  Places.swift
//
//  Created by Jakub Holík on 11.04.17.
//  Copyright © 2017 Symphony No. 9 s.r.o. All rights reserved.
//

import Foundation
import RealmSwift

class Place: Object {
	dynamic var id = 0
	dynamic var title = ""
	dynamic var placeDescription = ""
	dynamic var imageFileName = "bg_nature"
	dynamic var latitude: Double = 0.0
	dynamic var longitude: Double = 0.0
	dynamic var type: String = PlaceType.historic.rawValue
	let posts = List<PlacePost>()
	dynamic var panorama: Panorama?
}

enum PlaceType: String {
	
	case historic
	case sightseeing
	
}
