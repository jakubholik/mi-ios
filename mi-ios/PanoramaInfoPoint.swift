//
//  PanoramaInfoPoint.swift
//
//  Created by Jakub Holík on 25.04.17.
//  Copyright © 2017 Symphony No. 9 s.r.o. All rights reserved.
//

import Foundation
import RealmSwift

class PanoramaInfoPoint: Object {
	
	dynamic var type: String = PanoramaInfoPointType.information.rawValue
	dynamic var title: String = ""
	dynamic var positionX: Int = 0
	dynamic var positionY: Int = 0
	
}

enum PanoramaInfoPointType: String {
	
	case question
	case information
	
}
