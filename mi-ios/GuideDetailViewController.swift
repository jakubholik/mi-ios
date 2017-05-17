//
//  GuideDetailViewController.swift
//
//  Created by Jakub Holík on 11.04.17.
//  Copyright © 2017 Symphony No. 9 s.r.o. All rights reserved.
//

import UIKit

class GuideDetailViewController: UIViewController, UINavigationControllerDelegate {
	
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var placeDescriptionLabel: UILabel!
	let viewModel = GuideDetailViewModel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		viewModel.registerCollectionViewCells()
		viewModel.initializeZoomView()
		
		self.view.backgroundColor = GrayTheme.gray
		self.collectionView.backgroundColor = GrayTheme.black
		self.placeDescriptionLabel.backgroundColor = GrayTheme.gray
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
		
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		if let placeDescription = viewModel.placeDescription {
			
			placeDescriptionLabel.text = placeDescription
			
		}
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		viewModel.viewWillDisappear()
		
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		self.collectionView.collectionViewLayout.invalidateLayout()
		
	}
	
}

extension GuideDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		
		return 1
		
	}
 
	func collectionView(_ collectionView: UICollectionView,
	                    numberOfItemsInSection section: Int) -> Int {
		
		return ((viewModel.posts != nil) ? viewModel.posts!.count : 0)
		
	}
 
	func collectionView(_ collectionView: UICollectionView,
	                    cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		return viewModel.configureCollectionViewCellData(with: indexPath)
		
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		return viewModel.configureCollectionViewCellSize(with: indexPath)
		
	}
	
	func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		viewModel.audioObjects[indexPath.row]?.timer = nil
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		
		return UIEdgeInsetsMake(viewModel.kVerticalInsets, viewModel.kHorizontalInsets, viewModel.kVerticalInsets, viewModel.kHorizontalInsets)
		
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		
		return viewModel.kHorizontalInsets
		
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		
		return viewModel.kVerticalInsets
		
	}
	
}

extension GuideDetailViewController: UIScrollViewDelegate {
	
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		
		return viewModel.zoomedImageView
		
	}
	
	func updateMinZoomScaleForSize(size: CGSize) {
		
		
		
		let widthScale = size.width / viewModel.zoomedImageView.bounds.width
		let heightScale = size.height / viewModel.zoomedImageView.bounds.height
		let minScale = min(widthScale, heightScale)
		
		viewModel.scrollView.minimumZoomScale = minScale
		viewModel.scrollView.zoomScale = minScale
		
	}
	
}
