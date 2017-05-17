//
//  AppDelegate.swift
//
//  Created by Jakub Holík on 06.03.17.
//  Copyright © 2017 Symphony No. 9 s.r.o. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMaps

let globalSettings = Global()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		UIApplication.shared.statusBarStyle = .lightContent
		
		GMSServices.provideAPIKey("AIzaSyAvNwWDWd6POq5b-6ARG0gStJ9dS_kQYkE")
		migrateRealmDatabase()
		
		return true
	}
	
	func migrateRealmDatabase(){
		
		let bundlePath = Bundle.main.path(forResource: "default", ofType: "realm")
		let destPath = Realm.Configuration.defaultConfiguration.fileURL?.path
		let fileManager = FileManager.default
		
		//Copy bundlded realm if doesnt exists yet
		if fileManager.fileExists(atPath: destPath!) {
			print("exists")
			print(fileManager.fileExists(atPath: destPath!))
		
		} else {
			do {
		
				try fileManager.copyItem(atPath: bundlePath!, toPath: destPath!)
				print("copied")
			} catch {
			
				print("\n",error)
			
			}
		}
		
		let migrationBlock: MigrationBlock = { migration, oldSchemaVersion in
			
			if oldSchemaVersion < 1 {
				
			}
			if oldSchemaVersion < 2 {
				
			}
			if oldSchemaVersion < 7 {
				
				migration.enumerateObjects(ofType: PanoramaInfoPoint.className()) { oldObject, newObject in
					let typeString = oldObject!["type"] as! String
					newObject?["type"] = typeString.lowercased()
				}
				
				migration.enumerateObjects(ofType: Place.className()) { oldObject, newObject in
					let typeString = oldObject!["type"] as! String
					newObject?["type"] = typeString.lowercased()
				}
				
				migration.enumerateObjects(ofType: PlacePost.className()) { oldObject, newObject in
					let typeString = oldObject!["mediaType"] as! String
					newObject?["mediaType"] = typeString.lowercased()
				}
				
			}
			print("Migration complete.")
		}
		
		Realm.Configuration.defaultConfiguration = Realm.Configuration(schemaVersion: 7, migrationBlock: migrationBlock)
		let defaultURL = Realm.Configuration.defaultConfiguration.fileURL!
		
		print(defaultURL)
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can
		//occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when
		//the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks.
		//Games should use this method to pause the game.
	}
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application
		//state information to restore yourapplication to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
}

