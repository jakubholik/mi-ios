//
//  SecondViewController.swift
//
//  Created by Jakub Holík on 06.03.17.
//  Copyright © 2017 Symphony No. 9 s.r.o. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion
import GLKit

struct Attitude{
	var roll: Double
	var pitch: Double
	var yaw: Double
	var quaternion: CMQuaternion
}

class PanoramaViewController: UIViewController, CLLocationManagerDelegate {
	
	let viewModel = PanoramaViewModel()
	var locationManager = CLLocationManager()
	var motionManager = CMMotionManager()
    var currentPage = 0
	var currentView: UIView?
	var imageVRView: GVRPanoramaView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if CLLocationManager.headingAvailable() {
			
			locationManager.headingFilter = 1
			locationManager.startUpdatingHeading()
			locationManager.delegate = self
			viewModel.headingAvailable = true
			
		}
		
        GrayTheme.setTheme(for: self)
        
        viewModel.delegate = self
		viewModel.initializePanoramaView()
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		viewModel.reloadPanoramaView()
		
		if motionManager.isDeviceMotionAvailable {
			motionManager.deviceMotionUpdateInterval = 1.0/60.0
			motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, _) in
				
				guard let data = data else { return }
				
				self.viewModel.deviceMotionUpdate(with: data.gravity, and: data.attitude)

			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		if motionManager.isDeviceMotionAvailable {
			motionManager.stopDeviceMotionUpdates()
		}
		if CLLocationManager.headingAvailable() {
			locationManager.stopUpdatingHeading()
		}
	
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		viewModel.isPanoramaLoaded = false
		viewModel.viewStandby = true
		
		if let imageVRView = imageVRView {
			imageVRView.removeFromSuperview()
			self.imageVRView = nil
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		
		if !viewModel.isPanoramaLoaded {
			viewModel.loadFirstPanorama(with: newHeading)
		}
		
	}
	
	func setCurrentViewFromTouch(touchPoint point:CGPoint) {
		if imageVRView!.frame.contains(point) {
			currentView = imageVRView
		}
	}
	
	
	
}

extension PanoramaViewController: GVRWidgetViewDelegate {
	func widgetView(_ widgetView: GVRWidgetView!, didLoadContent content: Any!) {
		if content is UIImage && (imageVRView != nil){
			imageVRView?.isHidden = false
		}
	}
	
	func widgetView(_ widgetView: GVRWidgetView!, didFailToLoadContent content: Any!, withErrorMessage errorMessage: String!)  {
		print(errorMessage)
	}
	
	func widgetView(_ widgetView: GVRWidgetView!, didChange displayMode: GVRWidgetDisplayMode) {
		currentView = widgetView
		viewModel.currentDisplayMode = displayMode
		if currentView == imageVRView && viewModel.currentDisplayMode != GVRWidgetDisplayMode.embedded {
			view.isHidden = true
		} else {
			view.isHidden = false
		}
	}
	
	func widgetViewDidTap(_ widgetView: GVRWidgetView!) {
		guard viewModel.currentDisplayMode != GVRWidgetDisplayMode.embedded else {return}
		if currentView == imageVRView {
			print("WidgetView tapped and is of type VRView")
		}
	}
}



