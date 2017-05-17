//
//  StringExtension.swift
//
//  Created by Jakub Holík on 18.04.17.
//  Copyright © 2017 Symphony No. 9 s.r.o. All rights reserved.
//

import Foundation

extension String {
	
	func localized() -> String {
		
		let path = Bundle.main.path(forResource: globalSettings.language, ofType: "lproj")
		
		if let path = path {
			if let bundle = Bundle(path: path){
			
				return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
			
			} else {
				
				return self
			
			}
		} else {
			
			return self
			
		}
		
	}
	
}
