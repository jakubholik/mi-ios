//
//  guideDetailCell.swift
//
//  Created by Jakub Holík on 14.04.17.
//  Copyright © 2017 Symphony No. 9 s.r.o. All rights reserved.
//

import UIKit

class GuideDetailCell: UICollectionViewCell {
	
	let dateFormatter = DateFormatter()
	let kLabelVerticalInsets: CGFloat = 8.0
	let kLabelHorizontalInsets: CGFloat = 8.0
	var post: PlacePost?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
		self.layer.masksToBounds = true
		
		setStyle()
	}
	
	
	func cellLayout() {
		self.setNeedsLayout()
		self.layoutIfNeeded()
	}
	
	func setStyle(){
		self.layer.cornerRadius = 5
		self.backgroundColor = UIColor.white
		
	}
	
	func setDate(with date: NSDate, label: UILabel){
		
		dateFormatter.dateFormat = globalSettings.dateFormatter
		label.text = dateFormatter.string(from: date as Date)
		label.backgroundColor = GrayTheme.black
		label.textColor = GrayTheme.white
		
	}
	
}
