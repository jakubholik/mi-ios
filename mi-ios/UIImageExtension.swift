//
//  UIImageExtension.swift
//  Vacation 360
//
//  Created by Jakub Holík on 05.03.17.
//  Copyright © 2017 RayWenderlich. All rights reserved.
//

import Foundation

extension UIImage{
	
	//Crop the left part
	func cropLeftImage(image: UIImage, withPercentage percentage: CGFloat) -> UIImage {
		//first part
		
		let width = CGFloat(image.size.width * image.scale * percentage)
		let rect = CGRect(x: 0, y: 0, width: width, height: image.size.height*image.scale)
		
		return cropImage(image: image, toRect: rect)
	}
	
	// Crop the right part
	func cropRightImage(image: UIImage, withPercentage percentage: CGFloat) -> UIImage {
		
		let width = CGFloat(image.size.width * image.scale * percentage)
		let rect = CGRect(x: image.size.width * image.scale - width, y: 0, width: width, height: image.size.height*image.scale)
		
		return cropImage(image: image, toRect: rect)
	}
	
	func cropImage(image:UIImage, toRect rect:CGRect) -> UIImage{
		let imageRef:CGImage = image.cgImage!.cropping(to: rect)!
		let croppedImage:UIImage = UIImage(cgImage:imageRef)
		return croppedImage
	}
	
	func imageByCombiningImage(firstImage: UIImage, withImage secondImage: UIImage) -> UIImage {
		
		let newImageWidth  = firstImage.size.width + secondImage.size.width
		let newImageHeight = firstImage.size.height
		let newImageSize = CGSize(width : newImageWidth, height: newImageHeight)

		
		UIGraphicsBeginImageContextWithOptions(newImageSize, false, 1.0)
		
		let firstImageDrawX  = CGFloat(0)
		let firstImageDrawY  = CGFloat(0)
		
		let secondImageDrawX = firstImage.size.width
		let secondImageDrawY = CGFloat(0)
		
		firstImage .draw(at: CGPoint(x: firstImageDrawX,  y: firstImageDrawY))
		secondImage.draw(at: CGPoint(x: secondImageDrawX, y: secondImageDrawY))
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		
		UIGraphicsEndImageContext()
		
		
		return image!
	}
	
	func repositionImage(basedOn cardinalPercentage: CGFloat)->UIImage {
		return self
		var correctPercentage = cardinalPercentage
		
		if (correctPercentage - 0.5) < 0 {
			correctPercentage += 0.5
		} else {
			correctPercentage -= 0.5
		}
		
		if cardinalPercentage == 0 || cardinalPercentage == 1{
			correctPercentage = 0.5
		}
		
		
		let leftSide = self.cropLeftImage(image: self, withPercentage: correctPercentage)
		let rightSide = self.cropRightImage(image: self, withPercentage: CGFloat(1-correctPercentage))
		
		//return rightSide
		return self.imageByCombiningImage(firstImage: rightSide, withImage: leftSide)
	}
	
}
