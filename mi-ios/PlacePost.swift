//
//  PlacePost.swift
//
//  Created by Jakub Holík on 11.04.17.
//  Copyright © 2017 Symphony No. 9 s.r.o. All rights reserved.
//

import Foundation
import RealmSwift

class PlacePost: Object {
	
	dynamic var title = ""
	dynamic var date = NSDate(timeIntervalSince1970: 1)
	dynamic var textContent = ""
	dynamic var mediaType = PlacePostMediaType.image.rawValue
	dynamic var mediaFileName = ""
	
}

enum PlacePostMediaType: String {
	
	case image
	case audio
	case video

}
