//
//  guideDetailVideoCell.swift
//
//  Created by Jakub Holík on 14.04.17.
//  Copyright © 2017 Symphony No. 9 s.r.o. All rights reserved.
//

import UIKit

class GuideDetailVideoCell: GuideDetailCell {
	
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var titleLabel: UILabel!

	
	override func layoutSubviews() {
		super.layoutSubviews()
		// Set what preferredMaxLayoutWidth you want
		descriptionLabel.preferredMaxLayoutWidth = self.bounds.width - 2 * kLabelHorizontalInsets
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		descriptionLabel.font = GrayTheme.setPTSerifRegular(for: 15)
		dateLabel.font = GrayTheme.setPTSerifRegular(for: 17)
		titleLabel.font = GrayTheme.setPTSerifBold(for: 19)
	}
}
