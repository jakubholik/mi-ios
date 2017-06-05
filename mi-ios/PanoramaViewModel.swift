//
//  PanoramaViewModel.swift
//
//  Created by Jakub Holík on 09.04.17.
//  Copyright © 2017 Symphony No. 9 s.r.o. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion
import RealmSwift

class PanoramaViewModel {
	
	var delegate: PanoramaViewController?
	var place: Place?
	var headingAvailable: Bool = false
	var isPanoramaLoaded: Bool = false
	var initialHeading: CGFloat = 0.0
	var viewStandby: Bool = false
	var currentDisplayMode = GVRWidgetDisplayMode.fullscreen
	
	func initializePanoramaView(){
		
		guard let place = place,
			let panorama = place.panorama else {
				return
		}
		
		assignGVRView()
		
		if !headingAvailable {
			loadPanoramaImage(for: panorama, with: getCardinalPercentage(from: initialHeading))
		}
		
	}
	
	func reloadPanoramaView(){
		if viewStandby {
			assignGVRView()
			
			guard let place = place,
				let panorama = place.panorama else {
					return
			}
			
			loadPanoramaImage(for: panorama, with: getCardinalPercentage(from: initialHeading))
			
			viewStandby = false
		}
	}
	
	func assignGVRView(){
		guard let delegate = delegate else {
			return
		}
		
		delegate.imageVRView = GVRPanoramaView(frame: delegate.view.frame)
		
		
		
		if let imageVRView = delegate.imageVRView {
			
			imageVRView.enableCardboardButton = true
			delegate.view.addSubview(imageVRView)
			
			imageVRView.translatesAutoresizingMaskIntoConstraints = false
			//Leading
			delegate.view.addConstraint(NSLayoutConstraint(item: imageVRView, attribute: .leading, relatedBy: .equal, toItem: delegate.view, attribute: .leading, multiplier: 1, constant: 0))
			//Bottom
			delegate.view.addConstraint(NSLayoutConstraint(item: delegate.bottomLayoutGuide, attribute: .top, relatedBy: .equal, toItem: imageVRView, attribute: .bottom, multiplier: 1, constant: 0))
			//Top
			delegate.view.addConstraint(NSLayoutConstraint(item: imageVRView, attribute: .top, relatedBy: .equal, toItem: delegate.topLayoutGuide, attribute:.bottom, multiplier: 1, constant: 0))
			//Trailing
			delegate.view.addConstraint(NSLayoutConstraint(item: delegate.view, attribute: .trailing, relatedBy: .equal, toItem: imageVRView, attribute: .trailing, multiplier: 1, constant: 0))
			
		}
		
	}
	
	func loadFirstPanorama(with heading: CLHeading){
		
		guard let place = place,
			let panorama = place.panorama else {
				return
		}
		
		initialHeading = CGFloat(heading.magneticHeading)
		loadPanoramaImage(for: panorama, with: getCardinalPercentage(from: initialHeading))
		
	}
	
	
	//Loads panorama image to imageVRView and sets info points
	
	func loadPanoramaImage(for panorama: Panorama, with cardinalPercentage: CGFloat){
		
		guard let delegate = delegate ,
			let panoramaImage = UIImage(named: panorama.image),
			let imageVRView = delegate.imageVRView else {
				return
		}
		
		isPanoramaLoaded = true
		imageVRView.load(panoramaImage.repositionImage(basedOn: cardinalPercentage), of: .mono)
		
		delegate.locationManager.stopUpdatingHeading()
		
		for i in 0..<panorama.infoPoints.count {
			
			let buttonView = UIView(frame: CGRect(x: 0, y: 0, width: 85, height: 85))
			buttonView.center = CGPoint(x: imageVRView.frame.width * 0.5, y: imageVRView.frame.height * 0.5)
			let infoPoint = UIButton(frame: CGRect(x: 0, y: 0, width: 85, height: 85))
			
			buttonView.isUserInteractionEnabled = true
			buttonView.transform = CGAffineTransform(rotationAngle: 0).translatedBy(x: CGFloat(panorama.infoPoints[i].positionX), y: CGFloat(panorama.infoPoints[i].positionY))
			
			infoPoint.isUserInteractionEnabled = true
			infoPoint.tag = i+1
			infoPoint.addTarget(self, action: #selector(panoramaInfoPointTapped(_:)), for: .touchUpInside)
			infoPoint.transform = CGAffineTransform(rotationAngle: 0)
			
			if let icon = UIImage(named: "panorama_\(panorama.infoPoints[i].type)_icon") {
				
				infoPoint.setImage(icon, for: .normal)
				
			}
			
			DispatchQueue.main.async {
				buttonView.addSubview(infoPoint)
				imageVRView.addSubview(buttonView)
			}
			
			
		}
		
		
	}
	
	
	// Action when infoPoint tapped
	
	@objc func panoramaInfoPointTapped(_ sender: UIButton) {
		print(sender)
		guard let place = place,
			let delegate = delegate,
			let panorama = place.panorama,
			panorama.infoPoints.indices.contains(sender.tag-1) else {
				print("Didnt find data for tapped button")
				return
		}
		
		let infoPoint = panorama.infoPoints[sender.tag-1]
		
		let alertController = UIAlertController(title: infoPoint.title, message: infoPoint.type, preferredStyle: .alert)
		let declineAction = UIAlertAction(title: "OK".localized(), style: .default){
			(result : UIAlertAction) -> Void in
			
		}
		alertController.addAction(declineAction)
		
		delegate.present(alertController, animated: true, completion: nil)
		
	}
	
	
	// Update posiotions of all infoPoints on device position change
	
	func deviceMotionUpdate(with gravity: CMAcceleration, and attitude: CMAttitude){
		
		guard let delegate = delegate,
			let place = place,
			let panorama = place.panorama,
			let imageVRView = delegate.imageVRView else {
				return
		}
		
		let quaternion = attitude.quaternion
		var roll: Double = 0
		var pitch: Double = 0
		var yaw: Double = 0
		var fullWidth: Double = 0
		var fullHeight: Double = 0
		var rotation: CGFloat = 0
		
		switch(UIDevice.current.orientation){
		
		case UIDeviceOrientation.landscapeLeft:
			
			roll = atan2(2*(quaternion.x*quaternion.z - quaternion.y*quaternion.w), 1 - 2*quaternion.y*quaternion.y - 2*quaternion.x*quaternion.x)
			pitch = asin(2*(quaternion.x*quaternion.w + quaternion.z*quaternion.y))
			yaw = atan2(2.0 * (quaternion.z * quaternion.w - quaternion.y * quaternion.x) , -1.0 + 2.0 * (quaternion.w * quaternion.w + quaternion.y * quaternion.y))
			fullWidth = Double(imageVRView.bounds.height)*Double.pi
			fullHeight = Double(imageVRView.bounds.width)*Double.pi
			rotation = CGFloat(atan2(gravity.x, gravity.y) - (3/2)*Double.pi)
			yaw = yaw - Double.pi/2
			
			break
		
		case UIDeviceOrientation.landscapeRight:
			
			roll = atan2(2*(-quaternion.x*quaternion.z + quaternion.y*quaternion.w), 1 - 2*quaternion.y*quaternion.y - 2*quaternion.x*quaternion.x)
			pitch = asin(2*(-quaternion.x*quaternion.w-quaternion.z*quaternion.y))
			yaw = atan2(2.0 * (quaternion.z * quaternion.w - quaternion.y * quaternion.x) , -1.0 + 2.0 * (quaternion.w * quaternion.w + quaternion.y * quaternion.y))
			fullWidth = Double(imageVRView.bounds.height)*Double.pi
			fullHeight = Double(imageVRView.bounds.width)*Double.pi
			rotation = CGFloat(atan2(gravity.x, gravity.y) - Double.pi/2)
			yaw = yaw + Double.pi/2
			
			break
			
		case UIDeviceOrientation.portraitUpsideDown:
			
			roll = atan2(2*(-quaternion.y * quaternion.z - quaternion.x * quaternion.w), 1 - 2 * quaternion.x * quaternion.x - 2 * quaternion.y * quaternion.y)
			pitch = asin(2*(-quaternion.y * quaternion.w + quaternion.z * quaternion.x))
			yaw = atan2(2.0 * (quaternion.z * quaternion.w + quaternion.x * quaternion.y) , -1.0 + 2.0 * (quaternion.w * quaternion.w + quaternion.x * quaternion.x))
			fullWidth = Double(imageVRView.bounds.width)*Double.pi
			fullHeight = Double(imageVRView.bounds.height)*Double.pi
			rotation = CGFloat(atan2(gravity.x, gravity.y) - Double.pi)
			
			break
			
		default:
			
			roll = atan2(2*(quaternion.y*quaternion.z + quaternion.x*quaternion.w), 1 - 2*quaternion.x*quaternion.x - 2*quaternion.y*quaternion.y)
			pitch = asin(2*(quaternion.y*quaternion.w - quaternion.z*quaternion.x))
			yaw = atan2(2.0 * (quaternion.z * quaternion.w + quaternion.x * quaternion.y) , -1.0 + 2.0 * (quaternion.w * quaternion.w + quaternion.x * quaternion.x))
			fullWidth = Double(imageVRView.bounds.width)*Double.pi
			fullHeight = Double(imageVRView.bounds.height)*Double.pi
			rotation = CGFloat(atan2(gravity.x, gravity.y) - Double.pi)
			
			break
		}
		
		
		let yawReset = (getCardinalPercentage(from: initialHeading) < CGFloat(0.5)) ? (-1)*getCardinalPercentage(from: initialHeading)*180*2 : (1-getCardinalPercentage(from: initialHeading))*360
		
		let rollDifference: Double = abs(Double.pi/2 - roll)
		
		var translateX = CGFloat(fullWidth*(self.degrees(radians: yaw)/180)*0.6)
		var translateY = CGFloat(rollDifference/Double.pi)*CGFloat(fullHeight)*CGFloat((gravity.z/abs(gravity.z)))*0.45
		
		//print("Roll: \(roll) Pitch: \(pitch) Yaw: \(yaw)")
		
		for subview in imageVRView.subviews {
			
			for button in subview.subviews {
				
				guard button.tag > 0,
					button is UIButton,
					let panorama = place.panorama,
					panorama.infoPoints.indices.contains(button.tag-1) else {
						continue
				}
				
				let infoPoint = panorama.infoPoints[button.tag-1]
				var basePositionX = CGFloat(0)
				var basePositionY = CGFloat(0)
				var rotationFixX: CGFloat = 0
				var rotationFixY: CGFloat = 0
				
				if let image = UIImage(named: panorama.image) {
					let height = image.size.height * image.scale
					let width = image.size.width * image.scale
					
					let heightDifference = (CGFloat(infoPoint.positionY) > height/2) ? (CGFloat(infoPoint.positionY)-height/2) : (-(height/2 - CGFloat(infoPoint.positionY)))
					let heightRatio = heightDifference/(height/2)
					
					let widthDifference = (CGFloat(infoPoint.positionX) > width/2) ? -(width/2 + (width/2 - CGFloat(infoPoint.positionX))) : CGFloat(infoPoint.positionX)
					var widthRatio = widthDifference/(width/2)
					
					basePositionY = CGFloat((Double(heightRatio)*(Double.pi/2))/Double.pi)*CGFloat(fullHeight)*0.5
					basePositionX = CGFloat(fullWidth)*widthRatio*CGFloat(cos(degrees: 45))
					
					rotationFixX = (-(imageVRView.frame.width - CGFloat(cos(degrees: degrees(radians: pitch))) * imageVRView.frame.width)*CGFloat((pitch/abs(pitch)) * Double.pi))*0.2
					rotationFixY = (-(imageVRView.frame.width - CGFloat(cos(degrees: degrees(radians: pitch))) * imageVRView.frame.width)*CGFloat(Double.pi*1/3))*0.2
					
					if CGFloat(infoPoint.positionY) > height/2 {
						rotationFixX = rotationFixX * (-1)
					}
					
					if getCardinalPercentage(from: initialHeading) < CGFloat(0.5){
						
						let rest = width*getCardinalPercentage(from: initialHeading)
						let absolutePosition = CGFloat(infoPoint.positionX) - rest + width/2
						basePositionX = (absolutePosition > width/2) ? (-(width/2 - absolutePosition)) : absolutePosition
						widthRatio = basePositionX/(width/2)
						
					} else {
						
						let rest = width - width*getCardinalPercentage(from: initialHeading)
						let absolutePosition = rest + CGFloat(infoPoint.positionX)
						basePositionX = (absolutePosition > width/2) ? -(width - absolutePosition) : absolutePosition
						widthRatio = basePositionX/(width/2)
						
					}
					
					basePositionX = CGFloat(fullWidth)*widthRatio*0.65
				}
				
				if abs(translateX - subview.transform.tx) < 0.5 {
					translateX = subview.transform.tx
				}
				if abs(translateY-subview.transform.ty) < 0.5 {
					translateY = subview.transform.ty
				}
				

				subview.transform = CGAffineTransform(rotationAngle: 0).translatedBy(x: CGFloat(translateX + basePositionX + rotationFixX), y: CGFloat(translateY + basePositionY + rotationFixY))
				button.transform = CGAffineTransform(rotationAngle: rotation)
			}
			
			
		}
		
	}
	
	
	// Get sin form degrees
	
	func sin(degrees: Double) -> Double {
		return __sinpi(degrees/180.0)
	}
	
	
	// Get cos form degrees
	
	func cos(degrees: Double) -> Double {
		return __cospi(degrees/180.0)
	}
	
	
	// Get degrees form radians
	
	func degrees(radians:Double) -> Double {
		return 180 / Double.pi * radians
	}
	
	
	// Get magnitude of attitude
	
	func magnitude(from attitude: CMAttitude) -> Double {
		return sqrt(pow(attitude.roll, 2) + pow(attitude.yaw, 2) + pow(attitude.pitch, 2))
	}
	
	
	// Get percentage of heading with 360 base
	
	func getCardinalPercentage(from heading: CGFloat)->CGFloat{
		return heading/360.0
	}
}
