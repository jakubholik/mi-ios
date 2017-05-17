//
//  GrayTheme.swift
//
//  Created by Jakub Holík on 16.04.17.
//  Copyright © 2017 Symphony No. 9 s.r.o. All rights reserved.
//

import Foundation
import UIKit

struct GrayTheme {
	
	static let black = UIColor(red: 17.0/255, green: 17.0/255, blue: 17.0/255, alpha: 1)
	static let mineShaft = UIColor(red: 57.0/255, green: 57.0/255, blue: 57.0/255, alpha: 1)
	static let boulder = UIColor(red: 119.0/255, green: 119.0/255, blue: 119.0/255, alpha: 1)
	static let gray = UIColor(red: 146.0/255, green: 146.0/255, blue: 146.0/255, alpha: 1)
	static let white = UIColor.white
	
	
	static func setTheme(for viewController: UIViewController){
		
		UIApplication.shared.statusBarStyle = .lightContent
		
		if let navController = viewController.navigationController{
			
			navController.navigationBar.isTranslucent = false
			navController.navigationBar.tintColor = GrayTheme.white
			navController.navigationBar.barTintColor = GrayTheme.black
			navController.navigationBar.titleTextAttributes = [
				NSForegroundColorAttributeName:GrayTheme.white,
				NSFontAttributeName: setPTSerifRegular(for: 20)
			]
			
		}
		
		if let tabBarController = viewController.tabBarController {

			tabBarController.tabBar.isTranslucent = false
			tabBarController.tabBar.barTintColor = GrayTheme.black
			tabBarController.tabBar.tintColor = GrayTheme.white

		}
	}
	
	static func setPTSerifRegular(for fontSize: Int) -> UIFont {
		
		if let font = UIFont(name: "PTSerif-Regular", size: CGFloat(fontSize)) {
			return font
		}
		
		return UIFont(name: "HelveticaNeue", size: CGFloat(fontSize))!
	}
	
	static func setPTSerifBold(for fontSize: Int) -> UIFont {
		
		if let font = UIFont(name: "PTSerif-Bold", size: CGFloat(fontSize)) {
			return font
		}
		
		return UIFont(name: "HelveticaNeue", size: CGFloat(fontSize))!
	}
	
	static func setPTSerifItalic(for fontSize: Int) -> UIFont {
		
		if let font = UIFont(name: "PTSerif-Italic", size: CGFloat(fontSize)) {
			return font
		}
		
		return UIFont(name: "HelveticaNeue", size: CGFloat(fontSize))!
	}
}
