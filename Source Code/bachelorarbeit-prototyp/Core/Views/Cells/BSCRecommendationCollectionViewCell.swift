//
//  BSCRecommendationCollectionViewCell.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 28.01.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import Foundation
import MediaPlayer

class BSCRecommendationCollectionViewCell: UICollectionViewCell {
	
	private var mediaItem					: MPMediaItem?
	
	@IBOutlet weak var coverImageView		: UIImageView!
	@IBOutlet weak var playPauseButton		: UIButton!
	@IBOutlet weak var titleLabel			: MarqueeLabel!
	
	@IBOutlet weak var sessionNameLabel		: UILabel!
	
	var playButtonPressed					: (() -> Void)?
	
	deinit {
		if let _mediaItem = self.mediaItem {
			NSNotificationCenter.defaultCenter().removeObserver(self, name: BSCMusicPlayer.playerStateChangedNotificationKey(_mediaItem.persistentID), object: nil)
		}
	}
	
	// MARK: - Setter
	
	func setSessionContext(sessionContext: BSCSessionContext) {
		self.sessionNameLabel.hidden = false
		self.sessionNameLabel.text = sessionContext.label?.stringByReplacingOccurrencesOfString(", ", withString: "\n")
		
		self.titleLabel.text = nil
		self.coverImageView.image = nil
	}
	
	func setMediaItem(mediaItem: MPMediaItem) {
		self.sessionNameLabel.hidden = true

		if let _oldMediaItem = self.mediaItem {
			NSNotificationCenter.defaultCenter().removeObserver(self, name: BSCMusicPlayer.playerStateChangedNotificationKey(_oldMediaItem.persistentID), object: nil)
		}
		
		self.mediaItem = mediaItem
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didChangePlayerState"), name: BSCMusicPlayer.playerStateChangedNotificationKey(mediaItem.persistentID), object: nil)
		self.coverImageView.image = mediaItem.artwork?.imageWithSize(CGSizeMake(50, 50))
		self.titleLabel.text = mediaItem.title
		// Update the playPauseButton state
		self.didChangePlayerState()
	}
	
	// MARK: - IBOutlets
	
	@IBAction private func didPressPlayPauseButton(sender: AnyObject) {
		if let _ = self.mediaItem {
			if (self.playPauseButton.selected == true) {
				BSCMusicPlayer.sharedInstance.pause()
			} else {
				if let _playButtonPressed = self.playButtonPressed {
					_playButtonPressed()
				}
			}
		}
	}
	
	// MARK: - Helper
	
	func didChangePlayerState() {
		if let _mediaItem = self.mediaItem {
			if (BSCMusicPlayer.sharedInstance.isPlaying(persistentID: _mediaItem.persistentID)) {
				self.playPauseButton.selected = true
			} else {
				self.playPauseButton.selected = false
			}
		}
	}
}
