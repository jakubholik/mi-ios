//
//  Panorama.swift
//
//  Created by Jakub Holík on 25.04.17.
//  Copyright © 2017 Symphony No. 9 s.r.o. All rights reserved.
//

import Foundation
import RealmSwift

class Panorama: Object {
	
	dynamic var image: String = ""
	let infoPoints = List<PanoramaInfoPoint>()

}
