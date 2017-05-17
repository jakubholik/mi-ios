//
//  GuideViewModel.swift
//
//
//  Created by Jakub Holík on 11.04.17.
//  Copyright © 2017 Symphony No. 9 s.r.o. All rights reserved.
//

import Foundation
import RealmSwift

class GuideViewModel: NSObject {
	
	var notificationToken: NotificationToken? = nil
	var delegate: GuideViewController?
	var realm: Realm?
	var places: Results<Place>?
	var placesMonitoringTimer = Timer()
	
	@objc func loadPlacesToMapView(){
		
		guard let delegate = delegate,
			let places = places
			else {
				return
		}
		delegate.mapView.clear()
		
		for i in 0..<places.count {
			
			let marker = GMSMarker()
			marker.position = CLLocationCoordinate2D(latitude: places[i].latitude, longitude: places[i].longitude)
			marker.title = places[i].title
			marker.snippet = places[i].placeDescription
			marker.userData = places[i]
			
			switch(places[i].type){
				
			case PlaceType.historic.rawValue:
				
				marker.icon = UIImage(named: "map_pin")
				marker.map = delegate.mapView
				
				break
				
			case PlaceType.sightseeing.rawValue:
				
				marker.icon = UIImage(named: "map_marker")
				marker.map = delegate.mapView
				
				break
				
			default:
				break
			}
			
		}
		
	}
	
	@objc func loadDetailView(for place: Place){
		
		guard let guideDetailViewController:GuideDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "guideDetailView") as? GuideDetailViewController,
			let delegate = delegate,
			let navigationController = delegate.navigationController
			
			else {
				return
		}
		
		guideDetailViewController.title = place.title
		guideDetailViewController.viewModel.delegate = guideDetailViewController
		guideDetailViewController.viewModel.placeTitle = place.title
		guideDetailViewController.viewModel.placeDescription = place.placeDescription
		guideDetailViewController.viewModel.posts = place.posts
		
		let backItem = UIBarButtonItem()
		backItem.title = "MAP".localized()
		guideDetailViewController.navigationItem.backBarButtonItem = backItem
		
		navigationController.pushViewController(guideDetailViewController, animated: true)
		
	}
	
	@objc func loadPanoramaView(for place: Place){
		
		guard let panoramaViewController:PanoramaViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "panoramaView") as? PanoramaViewController,
			let delegate = delegate,
			let navigationController = delegate.navigationController
			else {
				return
		}
		
		panoramaViewController.viewModel.place = place
		panoramaViewController.viewModel.delegate = panoramaViewController
		panoramaViewController.title = place.title
		navigationController.pushViewController(panoramaViewController, animated: true)
		
	}
	
	func viewDidLoad(){
		realm = try! Realm()
		places = realm?.objects(Place.self)
		
		notificationToken = places?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
			
			switch changes {
			case .initial:
				// Results are now populated and can be accessed without blocking the UI
				self?.loadPlacesToMapView()
				
				break
			case .update(_, let deletions, let insertions, let modifications):
				// Query results have changed, so apply them to the UITableView
				self?.loadPlacesToMapView()
				
				break
			case .error(let error):
				// An error occurred while opening the Realm file on the background worker thread
				fatalError("\(error)")
				break
			}
		}
		
		if let delegate = delegate {
			
			delegate.title = "MAP".localized()
			
			guard let navController = delegate.navigationController,
				let topItem = navController.navigationBar.topItem else {
					return
			}
			navController.title = "MAP".localized()
			topItem.title = "MAP".localized()
		}
		
		
		
	}
	
	deinit {
		notificationToken?.stop()
	}
	
	func monitorPointsDistance(){
		//placesMonitoringTimer.invalidate()
		placesMonitoringTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(checkPlacesDistance), userInfo: nil, repeats: true)
		
	}
	
	@objc private func checkPlacesDistance(){
		
		guard let delegate = delegate,
			let placesArray = places,
			let userLocation = delegate.locationManager.location
			else {
				return
		}
		
		var alertPresented = false
		var i: Int = 0
		
		while !alertPresented && i < placesArray.count {
			
			switch(placesArray[i].type){
				
			case PlaceType.historic.rawValue:
				
				if userLocation.distance(from: CLLocation(latitude: placesArray[i].latitude, longitude: placesArray[i].longitude)) < 50{
					
					let alertController = UIAlertController(title: "POINT_NEARBY_HISTORIC".localized(), message: "POINT_NEARBY_HISTORIC_MESSAGE".localized(), preferredStyle: .alert)
					let acceptAction = UIAlertAction(title: "YES".localized(), style: .default){
						(result : UIAlertAction) -> Void in
						
						self.loadDetailView(for: placesArray[i])
						
					}
					let declineAction = UIAlertAction(title: "NO".localized(), style: .destructive){
						(result : UIAlertAction) -> Void in
						
					}
					
					alertController.addAction(acceptAction)
					alertController.addAction(declineAction)
					
					delegate.present(alertController, animated: true, completion: nil)
					
					alertPresented = true
					placesMonitoringTimer.invalidate()
				} else {
					i += 1
				}
				
				break
				
			default:
				i += 1
				break
			}
			
		}
		
	}
	
}
