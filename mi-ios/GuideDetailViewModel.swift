//
//  GuideDetailViewModel.swift
//
//  Created by Jakub Holík on 11.04.17.
//  Copyright © 2017 Symphony No. 9 s.r.o. All rights reserved.
//

import Foundation
import RealmSwift
import AVFoundation
import AVKit

class GuideDetailViewModel: NSObject {
	
	var delegate: GuideDetailViewController?
	var placeTitle: String?
	var placeDescription: String?
	var posts: List<PlacePost>?
	var currentAudioObject: AudioObject?
	var audioObjects: [Int:AudioObject] = [:]
	
	var zoomView = UIView()
	var zoomedImageView = UIImageView()
	var scrollView = UIScrollView()
	
	let kHorizontalInsets: CGFloat = 10.0
	let kVerticalInsets: CGFloat = 10.0
	var offscreenCells = Dictionary<String, UICollectionViewCell>()
	
	
	func viewWillDisappear(){
		stopAudioTrack()
	}
	
	
	func registerCollectionViewCells(){
		
		let cells = [
			"ImageCell",
			"AudioCell",
			"VideoCell"
		]
		
		for cell in cells as [String] {
			let myCellNib = UINib(nibName: "GuideDetail\(cell)", bundle: nil)
			
			if let delegate = delegate {
				
				delegate.collectionView.register(myCellNib, forCellWithReuseIdentifier: cell)
				
			}
			
		}
	}
	
	
	func initializeAudioPlayer(with fileName: String)->AVAudioPlayer {
		
		if let audioPath = Bundle.main.path(forResource: fileName, ofType: "mp3") {
			
			do{
				
				let audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))
				
				return audioPlayer
				
			} catch{
				
				print("Couldn't initialize audio player for track: \(fileName)")
				return AVAudioPlayer()
			}
			
		} else {
			
			print("Couldn't find audio track: \(fileName)")
			return AVAudioPlayer()
			
		}
		
	}
	
	func initializeVideoPlayer(_ sender: UIButton){
		
		if let superview = sender.superview {
			
			if let cell = superview.superview as? GuideDetailVideoCell {
				
				if let post = cell.post{
					if let delegate = delegate{
						if let videoPath = Bundle.main.path(forResource: post.mediaFileName, ofType: "mp4") {
							
							let player = AVPlayer(url: URL(fileURLWithPath: videoPath))
							let playerViewController = CellAVPlayerViewController()
							playerViewController.player = player
							playerViewController.collectionView = delegate.collectionView
							self.delegate?.present(playerViewController, animated: true) {
								playerViewController.player!.play()
							}
							
						}
					}
				}
			}
		}
		
	}
	
	@objc func toggleAudioTrack(_ sender: UIButton){
		
		guard let superview = sender.superview,
			let cell = superview.superview as? GuideDetailAudioCell else {
				return
		}
		
		
		let object = audioObjects.map({
			key, value in
			
			if value.cell == cell {
				
				if let player = value.audioPlayer {
					
					if player.isPlaying {
						
						player.pause()
						value.timer = nil
						
					} else {
						
						player.play()
						value.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgressSlider), userInfo: cell, repeats: true)
						
					}
					
				}
			}
		})
		
	}
	
	
	func stopAudioTrack(){
		_ = audioObjects.map({
			key, value in
			
			if let audioPlayer = value.audioPlayer {
				
				if audioPlayer.isPlaying {
					
					audioPlayer.stop()
					
				}
				
			}
		})
		
		
	}
	
	func updateProgressSlider(timer: Timer){
		
		guard let cell = timer.userInfo as? GuideDetailAudioCell,
			let delegate = delegate,
			let index = delegate.collectionView.indexPath(for: cell),
			let audioObject = audioObjects[index.row],
			let audioPlayer = audioObject.audioPlayer else {
				return
		}
		
		UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {
			cell.progressView.setProgress(Float(audioPlayer.currentTime/audioPlayer.duration), animated: false)
		}, completion: nil)
		
	}
	
	
	func configureCollectionViewCellData(with indexPath: IndexPath) -> UICollectionViewCell {
		
		var cell = UICollectionViewCell()
		
		guard let posts = posts,
			let delegate = delegate,
			posts.indices.contains(indexPath.row)
			else {
				return cell
		}
		
		let post = posts[indexPath.row]
		
		if post.mediaType == PlacePostMediaType.image.rawValue {
			
			if let cellView = delegate.collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? GuideDetailImageCell {
				
				cellView.post = post
				cellView.titleLabel.text = post.title
				cellView.descriptionLabel.text = post.textContent
				cellView.imageView.image = UIImage(named: post.mediaFileName)
				cellView.setDate(with: post.date, label: cellView.dateLabel)
				cellView.cellLayout()
				cellView.imageView.tag = indexPath.row
				
				cellView.layoutIfNeeded()
				cellView.imageView.isUserInteractionEnabled = true
				let tap = UITapGestureRecognizer(target: self, action: #selector(bringUpZoomView(_:)))
				cellView.imageView.addGestureRecognizer(tap)
				
				cell = cellView
				
			}
			
			
		} else if post.mediaType == PlacePostMediaType.audio.rawValue {
			if let cellView = delegate.collectionView.dequeueReusableCell(withReuseIdentifier: "AudioCell", for: indexPath) as? GuideDetailAudioCell {
				
				cellView.post = post
				cellView.titleLabel.text = post.title
				cellView.descriptionLabel.text = post.textContent
				cellView.imageView.image = UIImage(named: "bg_audio")
				cellView.setDate(with: post.date, label: cellView.dateLabel)
				cellView.cellLayout()
				
				if let object = audioObjects[indexPath.row] {
					
					if let player = object.audioPlayer {
						
						cellView.playButton.addTarget(self, action: #selector(toggleAudioTrack(_:)), for: .touchUpInside)
						
					}
					
				} else {
					
					let object = AudioObject()
					object.audioPlayer = initializeAudioPlayer(with: post.mediaFileName)
					object.cell = cellView
					
					audioObjects[indexPath.row] = object
					cellView.playButton.addTarget(self, action: #selector(toggleAudioTrack(_:)), for: .touchUpInside)
					
				}
				
				cellView.layoutIfNeeded()
				cell = cellView
				
				
			}
		} else if post.mediaType == PlacePostMediaType.video.rawValue {
			if let cellView = delegate.collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as? GuideDetailVideoCell {
				
				cellView.post = post
				cellView.titleLabel.text = post.title
				cellView.descriptionLabel.text = post.textContent
				cellView.imageView.image = UIImage(named: "bg_video")
				cellView.setDate(with: post.date, label: cellView.dateLabel)
				cellView.playButton.addTarget(self, action: #selector(initializeVideoPlayer(_:)), for: .touchUpInside)
				cellView.cellLayout()
				
				cellView.layoutIfNeeded()
				cell = cellView
				
			}
		} else {
			
			print("No cell match")
			
		}
		
		
		cell.layoutIfNeeded()
		return cell
	}
	
	
	func configureCollectionViewCellSize(with indexPath: IndexPath) -> CGSize {
		
		if let delegate = delegate {
			
			let targetWidth = (delegate.collectionView.bounds.width - 3 * kHorizontalInsets)
			
			if (posts?[indexPath.row]) != nil {
				
				// Use fake cell to calculate height
				let reuseIdentifier = "GuideDetailImageCell"
				var cell: GuideDetailImageCell? = offscreenCells[reuseIdentifier] as? GuideDetailImageCell
				
				if cell == nil {
					cell = Bundle.main.loadNibNamed("GuideDetailImageCell", owner: self, options: nil)?[0] as? GuideDetailImageCell
					self.offscreenCells[reuseIdentifier] = cell
				}
				
				if let post = posts?[indexPath.row] {
					// Config cell and let system determine size
					cell!.titleLabel.text = post.title
					cell!.descriptionLabel.text = post.textContent
					cell!.imageView.image = UIImage(named: "bg_nature")
					cell!.cellLayout()
				}
				
				
				// Cell's size is determined in nib file, need to set it's width (in this case), and inside, use this cell's width to set label's preferredMaxLayoutWidth, thus, height can be determined, this size will be returned for real cell initialization
				cell!.bounds = CGRect(x: 0, y: 0, width: targetWidth, height: cell!.bounds.height)
				cell!.contentView.bounds = cell!.bounds
				
				// Layout subviews, this will let labels on this cell to set preferredMaxLayoutWidth
				cell!.setNeedsLayout()
				cell!.layoutIfNeeded()
				
				var size = cell!.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
				// Still need to force the width, since width can be smalled due to break mode of labels
				size.width = targetWidth
				
				return size
				
			} else {
				
				return CGSize.zero
				
			}
			
			
		} else {
			
			return CGSize.zero
			
		}
		
	}
	
	func initializeZoomView() {
		
		guard let delegate = delegate else {
			return
		}
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage(_:)))
		
		zoomView.frame = CGRect(x: 0, y: 0, width: delegate.view.bounds.size.width, height: delegate.view.bounds.size.height)
		zoomView.translatesAutoresizingMaskIntoConstraints = false
		
		zoomedImageView.backgroundColor = .black
		zoomedImageView.clipsToBounds = false
		zoomedImageView.isUserInteractionEnabled = true
		zoomedImageView.addGestureRecognizer(tap)
		
		
		scrollView.frame = CGRect(x: 0, y: 0, width: zoomView.bounds.size.width, height: zoomView.bounds.size.height)
		scrollView.alwaysBounceVertical = true
		scrollView.alwaysBounceHorizontal = true
		scrollView.showsVerticalScrollIndicator = false
		scrollView.backgroundColor = .black
		scrollView.isScrollEnabled = true
		scrollView.contentSize = zoomedImageView.bounds.size
		scrollView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
		scrollView.minimumZoomScale = CGFloat(0.1)
		scrollView.maximumZoomScale = CGFloat(4.0)
		scrollView.zoomScale = 1.0
		scrollView.delegate = delegate
		scrollView.isMultipleTouchEnabled = true
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		
		scrollView.addSubview(zoomedImageView)
		zoomView.addSubview(scrollView)
		
		//Leading
		zoomView.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .leading, relatedBy: .equal, toItem: zoomView, attribute: .leading, multiplier: 1, constant: 0))
		//Bottom
		zoomView.addConstraint(NSLayoutConstraint(item: zoomView, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1, constant: 0))
		//Top
		zoomView.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: zoomView, attribute: .top, multiplier: 1, constant: 0))
		//Trailing
		zoomView.addConstraint(NSLayoutConstraint(item: zoomView, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1, constant: 0))
		
		
		
		print("Initialized")
	}
	
	func setZoomViewConstraints(){
		
		guard let delegate = delegate else {
			return
		}
		
		//Leading
		delegate.view.addConstraint(NSLayoutConstraint(item: delegate.view, attribute: .leading, relatedBy: .equal, toItem: zoomView, attribute: .leading, multiplier: 1, constant: 0))
		//Bottom
		delegate.view.addConstraint(NSLayoutConstraint(item: zoomView, attribute: .bottom, relatedBy: .equal, toItem: delegate.view, attribute: .bottom, multiplier: 1, constant: 0))
		//Top
		delegate.view.addConstraint(NSLayoutConstraint(item: delegate.view, attribute: .top, relatedBy: .equal, toItem: zoomView, attribute: .top, multiplier: 1, constant: 0))
		//Trailing
		delegate.view.addConstraint(NSLayoutConstraint(item: zoomView, attribute: .trailing, relatedBy: .equal, toItem: delegate.view, attribute: .trailing, multiplier: 1, constant: 0))
		
	}
	
	func bringUpZoomView(_ sender: UITapGestureRecognizer) {
		print("Tapped")
		
		guard let imageView = sender.view as? UIImageView,
			let delegate = delegate,
			let posts = posts,
			posts.indices.contains(imageView.tag),
			let image = UIImage(named: posts[imageView.tag].mediaFileName) else {
				return
		}
		
		zoomedImageView.image = image
		zoomedImageView.frame = CGRect(x: 0, y: 0, width: image.size.width*image.scale, height: image.size.height*image.scale)
		
		let imageTopOffset = scrollView.frame.height/2 - image.size.height*(4/5)
		var imageLeftOffset: CGFloat = 0.0
		
		
		if scrollView.frame.width > (image.size.width * image.scale) {
			
			imageLeftOffset = (scrollView.frame.width-(image.size.width*image.scale))/CGFloat(2)
			
		} else {
			
			imageLeftOffset = 0
			
		}
		
		scrollView.contentOffset = CGPoint(x: image.size.width, y: image.size.height)
		scrollView.contentInset = UIEdgeInsetsMake(imageTopOffset - 44.0, imageLeftOffset, imageTopOffset, imageLeftOffset)
		delegate.updateMinZoomScaleForSize(size: delegate.view.bounds.size)
		
		
		UIView.transition(with: delegate.view, duration: 0.5, options: .transitionFlipFromRight,
		                  animations: {
							
							delegate.view.addSubview(self.zoomView)
							self.setZoomViewConstraints()
							
		}, completion: { (value: Bool) in
			
		})
		
	}
	
	func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
		print("Image tapped")
		
		guard let delegate = delegate else {
			return
		}
		
		UIView.transition(with: delegate.view, duration: 0.5, options: .transitionFlipFromLeft,
		                  animations: {
							
							self.zoomView.removeFromSuperview()
							
		}, completion: { (value: Bool) in
			
		})
	}
	
	func viewWillTransition(to size: CGSize) {
		
	}
	
}
