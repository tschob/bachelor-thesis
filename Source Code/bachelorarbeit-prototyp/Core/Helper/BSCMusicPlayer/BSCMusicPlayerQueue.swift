//
//  BSCMusicPlayerQueue.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 15.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit

class BSCMusicPlayerQueue: NSObject {

	// MARK: -
	
	private struct Constants {
		static let MaxCurrentQueueSize			= 30
	}
	
	// MARK: - Public variables
	
	
	// MARK: - Private variables
	
	private var originalQueue					= [BSCMusicPlayerItem]()
	
	private var currentMuiscPlayerItem			: BSCMusicPlayerItem?
	
	private var currentQueue					= [BSCMusicPlayerItem]()
	
	private var history							= [BSCMusicPlayerItem]()

	// MARK: Set
	
	func replace(musicPlayerItems: [BSCMusicPlayerItem]?, startPosition: Int) {
		BSCLog(Verbose.BSCMusicPLayer, "replace(musicPlayerItems: \(musicPlayerItems), startPosition: \(startPosition))")
		if let _musicPlayerItems = musicPlayerItems {
			// Add the current playing item to the history
			self.appendCurrentPlayingItemToQueue()
			// Replace the original queue
			self.originalQueue = _musicPlayerItems
			// Replace the current queue
			self.currentQueue.removeAll()
			self.currentMuiscPlayerItem = _musicPlayerItems[startPosition]
			for index in (startPosition + 1)..<_musicPlayerItems.count {
				self.currentQueue.append(_musicPlayerItems[index])
			}
		} else {
			self.originalQueue.removeAll()
		}
		self.originalQueue.indices
	}
	
	func append(musicPlayerItems: [BSCMusicPlayerItem]) {
		self.originalQueue.appendContentsOf(musicPlayerItems)
		self.currentQueue.appendContentsOf(musicPlayerItems)
	}
	
	func resortCurrentQueue(shuffled: Bool) {
		// Sort current queue
	}
	
	func itemFinishedPlaying() {
		self.currentQueue.removeFirst()
	}
	
	// MARK: Forward
	
	func canForward() -> Bool {
		return (self.currentQueue.count > 0 && self.followingItem() != nil)
	}
	
	func forward() -> Bool {
		if (self.canForward() == true),
			let _currentMusicPlayerItem = self.currentMuiscPlayerItem,
			let _followingPlayerItem = self.followingItem() {
				// Add current musicPlayerItem to the history
				_currentMusicPlayerItem.cleanupAfterPlaying()
				self.appendCurrentPlayingItemToQueue()
				// Replace current musicPlayerItem with the new one
				self.currentMuiscPlayerItem = _followingPlayerItem
				// Remove current musicPlayerItem from the current queue
				self.currentQueue.removeFirst()
				return true
		}
		return false
	}

	private func followingItem() -> BSCMusicPlayerItem? {
		return self.currentQueue.first
	}
	
	// MARK: Rewind
	
	func canRewind() -> Bool {
		return (self.previousItem() != nil)
	}
	
	func rewind() -> Bool {
		if (self.canRewind() == true),
			let _currentMusicPlayerItem = self.currentMuiscPlayerItem {
				_currentMusicPlayerItem.cleanupAfterPlaying()
				// Add current musicPlayerItem to the current queue
				self.currentQueue.insert(_currentMusicPlayerItem, atIndex: 0)
				// Replace the current musicPlayerItem with the former musicPlayerItem
				self.currentMuiscPlayerItem = self.previousItem()
				// Remove the now current item from the history
				self.history.removeLast()
				return true
		}
		return false
	}
	
	private func previousItem() -> BSCMusicPlayerItem? {
		return self.history.last
	}
	
	// MARK: Get
	
	func currentPlayingItem() -> BSCMusicPlayerItem? {
		return self.currentMuiscPlayerItem
	}
	
	func previousPlayingItem() -> BSCMusicPlayerItem? {
		return self.previousItem()
	}
	
	func count() -> Int {
		return self.originalQueue.count
	}
	
	// History
	
	private func appendCurrentPlayingItemToQueue() {
		if let _currentMusicPlayerItem = self.currentMuiscPlayerItem {
			self.history.append(_currentMusicPlayerItem)
		}
	}
}
