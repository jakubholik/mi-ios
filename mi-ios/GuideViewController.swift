//
//  GuideViewController.swift
//
//  Created by Jakub Holík on 11.04.17.
//  Copyright © 2017 Symphony No. 9 s.r.o. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import RealmSwift

class GuideViewController: UIViewController, UINavigationControllerDelegate{
	
	@IBOutlet weak var mapView: GMSMapView!
	let locationManager = CLLocationManager()
	var viewModel: GuideViewModel?
	var mapLoaded = false
	var tappedMarker = GMSMarker()
	var markerInfoWindow = MarkerInfoWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		globalSettings.setAppLanguage(lang: .czech)
		GrayTheme.setTheme(for: self)
		
		locationManager.delegate = self
		if CLLocationManager.authorizationStatus() == .notDetermined {
			locationManager.requestWhenInUseAuthorization()
			locationManager.startUpdatingLocation()
		}
		viewModel = GuideViewModel()
		viewModel?.delegate = self
		viewModel?.viewDidLoad()
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		
		if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
			locationManager.startUpdatingLocation()
			viewModel?.monitorPointsDistance()
		}
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		
		locationManager.stopUpdatingLocation()
		viewModel?.placesMonitoringTimer.invalidate()
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
		
		
	}
	
	override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
		markerInfoWindow.removeFromSuperview()
	}
	
}

extension GuideViewController: CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		
		if status == .authorizedWhenInUse {
			
			mapView.isMyLocationEnabled = true
			mapView.settings.myLocationButton = true
			
		}
		
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		if let location = locations.first {
			
			if !mapLoaded{
				
				mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
				mapLoaded = true
				
			}
			
		}
	}
	
}

extension GuideViewController: GMSMapViewDelegate {
	
	// return empty uiview for default infoMarkerWindow
	func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
		
		return UIView()
		
	}
	
	// reset custom infowindow whenever marker is tapped
	func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
		
		let location = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
		
		tappedMarker = marker
		markerInfoWindow.removeFromSuperview()

		if let place = marker.userData as? Place {
			
			switch(place.type) {
			case PlaceType.historic.rawValue:
				
				guard let markerNib = Bundle.main.loadNibNamed("MarkerInfoWindowHistoricView", owner: self, options: nil),
					let newMarkerInfoWindow = markerNib.first as? MarkerInfoWindow else {
						print("couldnt init MarkerInfoWindowHistoricView")
						return false
				}
				
				markerInfoWindow = newMarkerInfoWindow
				markerInfoWindow.title.text = "HB: \(place.title)"
				markerInfoWindow.previewImage.image = UIImage(named: place.imageFileName)
				markerInfoWindow.detailButton.setTitle(" \(place.posts.count) postů", for: .normal)
				markerInfoWindow.detailButton.addTarget(self, action: #selector(loadDetailView(_:)), for: .touchUpInside)
				break
				
			case PlaceType.sightseeing.rawValue:
				
				guard let markerNib = Bundle.main.loadNibNamed("MarkerInfoWindowSightseeingView", owner: self, options: nil),
					let newMarkerInfoWindow = markerNib.first as? MarkerInfoWindow else {
						print("couldnt init MarkerInfoWindowSightseeingView")
						return false
				}
				
				markerInfoWindow = newMarkerInfoWindow
				markerInfoWindow.title.text = "PB: \(place.title)"
				
				if let panorama = place.panorama {
					markerInfoWindow.detailButton.setTitle("Panorama", for: .normal)
					markerInfoWindow.detailButton.addTarget(self, action: #selector(loadPanoramaView(_:)), for: .touchUpInside)
				} else {
					markerInfoWindow.detailButton.isHidden = true
				}
				
				break
				
			default:
				return false
			}
			
			markerInfoWindow.layer.cornerRadius = 4.0
			markerInfoWindow.placeDescription.text = place.placeDescription
			markerInfoWindow.center = mapView.projection.point(for: location)
			markerInfoWindow.center.y -= 50
			
		}
		
		self.view.addSubview(markerInfoWindow)
		
		
		return false
		
	}
	
	func loadDetailView(_ sender: UIButton!){
		
		guard let viewModel = viewModel,
			let place = tappedMarker.userData as? Place else {
				print("Couldnt parse as Place")
				return
		}
		
		viewModel.loadDetailView(for: place)
		
	}
	
	func loadPanoramaView(_ sender: UIButton!){
		
		guard let viewModel = viewModel,
			let place = tappedMarker.userData as? Place else {
				print("Couldnt parse as Place")
				return
		}
		
		viewModel.loadPanoramaView(for: place)
		
	}
	
	func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
		
		viewModel?.loadPlacesToMapView()
		if !markerInfoWindow.isHidden{
			markerInfoWindow.center = mapView.projection.point(for: tappedMarker.position)
			markerInfoWindow.center.y -= 140
		}
		
	}
	
	// take care of the close event
	func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
		
		markerInfoWindow.removeFromSuperview()
		
	}
	
}
