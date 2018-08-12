//
//  BSCMediaItemTableViewCell.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 23.11.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import MediaPlayer

class BSCMediaItemTableViewCell: UITableViewCell {

	@IBOutlet weak private var positionLabel			: UILabel!
	@IBOutlet weak private var titleLabel				: MarqueeLabel!
	@IBOutlet weak private var durationLabel			: UILabel!
	
	private var isPlayable								= false
	
	func initWithSong(songItem: MPMediaItem) {
		self.positionLabel.text = "\(songItem.albumTrackNumber)"
		self.titleLabel.text = songItem.title
		self.durationLabel.text = songItem.playbackDurationDescription()
		self.isPlayable = songItem.isPlayable()
		// Deactivate the user interaction to prevent the visual feedback for cell selections
		self.userInteractionEnabled = self.isPlayable
	}
	
	func applyColorScheme(colorScheme: LEColorScheme?) {
		if let _colorScheme = colorScheme {
			self.backgroundColor = _colorScheme.backgroundColor
			self.positionLabel.textColor = _colorScheme.primaryTextColor
			self.durationLabel.textColor = _colorScheme.primaryTextColor
			// As we can't play item without asset url, use different text color to indicate the non playable state
			if (self.isPlayable == false) {
				self.titleLabel.textColor = _colorScheme.secondaryTextColor.colorWithAlphaComponent(0.3)
			} else {
				self.titleLabel.textColor = _colorScheme.secondaryTextColor
			}
		}
	}
	
	func applySelectionColorScheme(colorScheme: LEColorScheme?) {
		if let _colorScheme = colorScheme {
			let backgroundView = UIView()
			backgroundView.backgroundColor = _colorScheme.secondaryTextColor.colorWithAlphaComponent(0.3)
			self.selectedBackgroundView = backgroundView
		}
	}
}
