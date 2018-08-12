//
//  BSCArtistAlbumHeaderView.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 10.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import MediaPlayer

class BSCArtistAlbumHeaderView: BSCTableViewHeaderFooterView {

	@IBOutlet weak var backgroundButton			: BSCButton!
	
	@IBOutlet weak var coverImageView			: UIImageView!
	@IBOutlet weak var albumTitleLabel			: UILabel!
	@IBOutlet weak var albumArtistLabel			: UILabel!
	@IBOutlet weak var subtitleLabel			: UILabel!

	@IBOutlet weak var seperatorContainerView	: UIView!
	private var seperatorView					= UIView()
	
	var section									= 0
	var selection								: ((section: Int) -> Void)?
	
	// MARK: Public setter
	
	func initWithItemFromAlbum(item: MPMediaItem) {
		self.initView()
		self.initTitleLabel(item)
		self.initSubtitleLabel(item)
		self.initCoverImage(item)
		self.initSeperatorView()
	}
	
	func applyColorScheme(colorScheme: LEColorScheme?) {
		if let _colorScheme = colorScheme {
			// Set the backgrounds color
			self.backgroundButton.applyBackgroundColorScheme(colorScheme)
			self.backgroundButton.backgroundColor = _colorScheme.backgroundColor
			self.backgroundView?.backgroundColor = _colorScheme.backgroundColor
			self.seperatorView.backgroundColor = _colorScheme.primaryTextColor
			
			// Set the labels color
			self.albumTitleLabel.textColor = _colorScheme.secondaryTextColor
			self.albumArtistLabel.textColor = _colorScheme.secondaryTextColor
			self.subtitleLabel.textColor = _colorScheme.primaryTextColor
		}
	}
	
	// MARK: Initialization
	
	private func initView() {
		self.backgroundButton.setBackgroundImage(UIImage.imageFromColor(UIColor.whiteColor(), size: self.backgroundButton.frameSize), forState: .Normal)
		self.backgroundView = UIView(frame: self.bounds)
	}
	
	private func initCoverImage(item: MPMediaItem) {
		self.coverImageView.image = nil
		let generation = self.generation
		self.performBlockInBackground { () -> Void in
			let image = item.artwork?.imageWithSize(BSCHelper.imageSizeForView(self.coverImageView))
			self.updateInMainQueue({ () -> Void in
				self.coverImageView.image = image
				}, generation: generation)
		}
	}
	
	private func initTitleLabel(item: MPMediaItem) {
		self.albumTitleLabel.text = item.displayableAlbumTitle()
		if let year = item.releaseDate?.year() {
			self.subtitleLabel.text = "\(year)"
		} else {
			self.subtitleLabel.text = nil
		}
	}
	
	private func initSubtitleLabel(item: MPMediaItem) {
		if (item.artist == item.albumArtist) {
			self.albumArtistLabel.text = nil
		} else {
			self.albumArtistLabel.text = item.albumArtist
		}
	}
	
	private func initSeperatorView() {
		let shadowHeight = 1 / UIScreen.mainScreen().scale
		self.seperatorView.frame = CGRectMake(0, 0, self.seperatorContainerView.frameWidth, shadowHeight)
		self.seperatorView.backgroundColor = UIColor.lightGrayColor()
		self.seperatorView.autoresizingMask = [.FlexibleWidth]
		self.seperatorContainerView.addSubview(self.seperatorView)
	}
	
	// IBActions
	
	@IBAction private func didPressBackgroundButton(sender: AnyObject) {
		if let _selection = self.selection {
			_selection(section: self.section)
		}
	}
}
