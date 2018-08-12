//
//  BSCMusicPlayer+MPMediaItem.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 12/12/15.
//  Copyright (c) 2015 Hans Seiffert. All rights reserved.
//
import MediaPlayer

extension BSCMusicPlayer {
	
	
	// MARK: Play
	
	func play(mediaItem mediaItem: MPMediaItem) {
		if let _musicPlayerItem = BSCMusicPlayerItem(mediaItem: mediaItem) {
			self.play(_musicPlayerItem)
		}
	}
	
	func play(mediaItems mediaItems: [MPMediaItem], startPosition: Int) {
		// Play first item directly
		if let firstPlayable = BSCMusicPlayer.firstPlayableItem(mediaItems, startPosition: startPosition) {
			// Play the first song directly
			self.play(firstPlayable.item)
			// Remove the first item from the remaining media items
			var remainingMediaItems = mediaItems
			remainingMediaItems.removeRange(Range<Int>(start: 0, end: (firstPlayable.index + 1)))
			// Append the remaining items to queue in the background
			// As we creation of the BSCMusicPlayerItems takes some time, we avoid a blocked UI
			self.append(mediaItems: remainingMediaItems, queueGeneration: self.queueGeneration)
		}
	}
	
	private func append(mediaItems mediaItems: [MPMediaItem], queueGeneration: Int) {
		self.performBlockInBackground {
			let result = BSCMusicPlayerItem.musicPlayerItems(mediaItems, startPosition: 0)
			self.performBlockInMainThread({
				self.append(result.items, queueGeneration: queueGeneration)
			})
		}
	}
	
	// MARK - 
	
	func isPlaying(mediaItem mediaItem: MPMediaItem) -> Bool {
		return self.isPlaying(persistentID: mediaItem.persistentID)
	}
	
	func isPlaying(mediaItemCollection: MPMediaItemCollection) -> Bool {
		for mediaItem in mediaItemCollection.items {
			if (self.isPlaying(mediaItem: mediaItem) == true) {
				return true
			}
		}
		return false
	}
	
	func isPlaying(persistentID persistentID: MPMediaEntityPersistentID) -> Bool {
		if (self.isPlaying()) {
			return persistentID == self.currentMusicPlayerItem()?.mediaItem?.persistentID
		} else {
			return false
		}
	}
	
	// MARK: - Helper
	
	private class func firstPlayableItem(mediaItems: [MPMediaItem], startPosition: Int) -> (item: BSCMusicPlayerItem, index: Int)? {
		// Iterate through all media items
		for index in startPosition..<mediaItems.count {
			let mediaItem = mediaItems[index]
			// Check whether it's playable
			if (mediaItem.isPlayable() == true) {
				// Create the BSCMusicPlayerItem from the first playable media item and return it.
				if let _musicPlayerItem = BSCMusicPlayerItem(mediaItem: mediaItem) {
					return (item: _musicPlayerItem, index: index)
					
				}
			}
		}
		// There is no playable item -> reuturn nil then
		return nil
	}
}
