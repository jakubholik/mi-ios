//
//  Global.swift
//
//  Created by Jakub Holík on 16.04.17.
//  Copyright © 2017 Symphony No. 9 s.r.o. All rights reserved.
//

import Foundation

class Global {
	
	let dateFormatter = "dd.MM.yyyy"
	let userDefaults = Foundation.UserDefaults.standard
	var language = "en"
	
	init() {
		
		self.loadAppLanguage()
		
	}
	
	func realmBundleURL(by name: String) -> URL? {
		
		return Bundle.main.url(forResource: name, withExtension: "realm")
		
	}
	
	func loadAppLanguage(){
		var languageToSet = AppLanguage.english
		
		if let value  = userDefaults.string(forKey: "language") {
			
			if let lang = AppLanguage(rawValue: value) {
				
				languageToSet = lang
				
			}
			
		}
		
		setAppLanguage(lang: languageToSet)
		
	}
	
	func setAppLanguage(lang: AppLanguage){
		
		language = lang.rawValue
		
		userDefaults.set( language, forKey: "language")
		
	}
	
}

enum AppLanguage: String {
	
	case english = "en"
	case czech = "cs"
	case german = "de"
	
}
