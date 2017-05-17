//
//  CellAVPlayerViewController.swift
//
//  Created by Jakub Holík on 20.04.17.
//  Copyright © 2017 Symphony No. 9 s.r.o. All rights reserved.
//

import Foundation
import AVKit

class CellAVPlayerViewController: AVPlayerViewController {
	
	var collectionView: UICollectionView?
	
	override func viewWillDisappear(_ animated: Bool) {
		if let collectionView = collectionView {
			collectionView.collectionViewLayout.invalidateLayout()
		}
	}
}
