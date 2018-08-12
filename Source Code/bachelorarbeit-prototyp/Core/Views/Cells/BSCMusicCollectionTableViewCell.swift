//
//  BSCMediaItemCollectionTableViewCell.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 21.11.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import MediaPlayer

class BSCMediaItemCollectionTableViewCell: BSCTableViewCell {

	private var mediaItem									: MPMediaItem?
	private var mediaItemCollection							: MPMediaItemCollection?
	
	@IBOutlet weak private var iconImageView				: UIImageView!
	@IBOutlet weak private var titleLabel					: MarqueeLabel!
	@IBOutlet weak private var descriptionLabel				: MarqueeLabel!
	@IBOutlet weak private var rightLabel					: UILabel!
	@IBOutlet weak private var pauseButton					: UIButton!
	
	func initWithArtistCollection(artistCollection: MPMediaItemCollection, searchTerm: String?) {
		self.addMediaItemCollection(artistCollection)
		self.titleLabel.attributedText = BSCHelper.highlightedString(artistCollection.representativeItem?.artist ?? "", hightlightedTerm: searchTerm, fontSize: self.titleLabel.font.pointSize)
		
		// As the image and descrition label creation takes some time, it's done in the background
		self.setImageInBackground { ()
			return artistCollection.representativeItem?.artwork?.imageWithSize(BSCHelper.imageSizeForView(self.iconImageView))
		}
		self.descriptionLabel.text = "..."
		self.setDescriptionLabelInBackground {
			return BSCMusicLibraryManager.albumCountTrackCountDescription(artistCollection)
		}
	}
	
	func initWithAlbumCollection(albumCollection: MPMediaItemCollection, searchTerm: String?) {
		self.addMediaItemCollection(albumCollection)
		self.titleLabel.attributedText = BSCHelper.highlightedString(albumCollection.displayableAlbumTitle(), hightlightedTerm: searchTerm, fontSize: self.titleLabel.font.pointSize)
		self.descriptionLabel.text = BSCMusicLibraryManager.artistTitleTrackCountDescription(albumCollection)
		
		// As the image creation takes some time, it's done in the background
		self.setImageInBackground { ()
			return albumCollection.representativeItem?.artwork?.imageWithSize(BSCHelper.imageSizeForView(self.iconImageView))
		}
	}
	
	func initWithPlaylistCollection(playlistCollection: MPMediaItemCollection, searchTerm: String?) {
		self.addMediaItemCollection(playlistCollection)
		self.titleLabel.attributedText = BSCHelper.highlightedString(playlistCollection.playlistTitle() ?? "", hightlightedTerm: searchTerm, fontSize: self.titleLabel.font.pointSize)
		self.descriptionLabel.text = MPMediaItemCollection.songCountDescription(playlistCollection)
		
		// As the image creation takes some time, it's done in the background
		self.setImageInBackground { ()
			return playlistCollection.artworkImageWithSize(BSCHelper.imageSizeForView(self.iconImageView))
		}
	}
	
	func initWithGenreCollection(genreCollection: MPMediaItemCollection, searchTerm: String?) {
		self.addMediaItemCollection(genreCollection)
		self.titleLabel.attributedText = BSCHelper.highlightedString(genreCollection.representativeItem?.genre ?? "", hightlightedTerm: searchTerm, fontSize: self.titleLabel.font.pointSize)
		self.descriptionLabel.text = MPMediaItemCollection.songCountDescription(genreCollection)
		
		// As the image creation takes some time, it's done in the background
		self.setImageInBackground { ()
			return genreCollection.artworkImageWithSize(BSCHelper.imageSizeForView(self.iconImageView))
		}
	}
	
	func initWithSong(songItem: MPMediaItem, searchTerm: String?) {
		self.addMediaItem(songItem)
		self.rightLabel.text = songItem.playbackDurationDescription()
		self.titleLabel.attributedText = BSCHelper.highlightedString(songItem.title ?? "", hightlightedTerm: searchTerm, fontSize: self.titleLabel.font.pointSize)
		self.descriptionLabel.text = songItem.artistAlbumDescription()
		
		// As we can't play item without asset url, use gray text color to indicate the non playable state
		if (songItem.isPlayable() == false) {
			self.titleLabel.textColor = UIColor.lightGrayColor()
		} else {
			self.titleLabel.textColor = UIColor.blackColor()
		}
		
		// Deactivate the user interaction to prevent the visual feedback for cell selections
		self.userInteractionEnabled = songItem.isPlayable()
		
		// As the image creation takes some time, it's done in the background
		self.setImageInBackground { ()
			return songItem.artwork?.imageWithSize(BSCHelper.imageSizeForView(self.iconImageView))
		}
	}
	
	func didChangePlayerState() {
		if let _mediaItem = self.mediaItem {
			if (BSCMusicPlayer.sharedInstance.isPlaying(persistentID: _mediaItem.persistentID)) {
				self.pauseButton.hidden = false
				return
			}
		} else if let _mediaItemCollection = self.mediaItemCollection {
			if (BSCMusicPlayer.sharedInstance.isPlaying(_mediaItemCollection)) {
				self.pauseButton.hidden = false
				return
			}
		}
		self.pauseButton.hidden = true
	}
	
	// MARK: - IBOutlets
	
	@IBAction private func didPressPlayPauseButton(sender: AnyObject) {
		BSCMusicPlayer.sharedInstance.pause()
	}
	
	// MARK: - Helper
	
	private func addMediaItemCollection(mediaItemCollection: MPMediaItemCollection) {
		// Remove former mediaItem(-Collection)
		self.removeMediaItem()
		self.removeMediaItemCollection()
		
		self.mediaItemCollection = mediaItemCollection
		for mediaItem in mediaItemCollection.items {
			NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didChangePlayerState"), name: BSCMusicPlayer.playerStateChangedNotificationKey(mediaItem.persistentID), object: nil)
		}
		// Update the playPauseButton state
		self.didChangePlayerState()
	}
	
	private func removeMediaItemCollection() {
		if let _oldMediaItemCollection = self.mediaItemCollection {
			for mediaItem in _oldMediaItemCollection.items {
				NSNotificationCenter.defaultCenter().removeObserver(self, name: BSCMusicPlayer.playerStateChangedNotificationKey(mediaItem.persistentID), object: nil)
			}
		}
		self.mediaItemCollection = nil
	}
	
	private func addMediaItem(mediaItem: MPMediaItem) {
		// Remove former mediaItem(-Collection)
		self.removeMediaItem()
		self.removeMediaItemCollection()
		
		self.mediaItem = mediaItem
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didChangePlayerState"), name: BSCMusicPlayer.playerStateChangedNotificationKey(mediaItem.persistentID), object: nil)
		// Update the playPauseButton state
		self.didChangePlayerState()
	}
	
	private func removeMediaItem() {
		if let _oldMediaItem = self.mediaItem {
			NSNotificationCenter.defaultCenter().removeObserver(self, name: BSCMusicPlayer.playerStateChangedNotificationKey(_oldMediaItem.persistentID), object: nil)
		}
		self.mediaItem = nil
	}
	
	private func setImageInBackground(operation: () -> UIImage?) {
		let generation = self.generation
		self.iconImageView.image = nil
		self.performBlockInBackground { () -> Void in
			let image = operation()
			self.updateInMainQueue({ () -> Void in
				self.iconImageView.image = image
				}, generation: generation)
		}
	}
	
	private func setDescriptionLabelInBackground(operation: () -> String?) {
		let generation = self.generation
		self.performBlockInBackground { () -> Void in
			let description = operation()
			self.updateInMainQueue({ () -> Void in
					self.descriptionLabel.text = description
				}, generation: generation)
		}
	}
}
