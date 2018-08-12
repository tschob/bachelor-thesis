//
//  BSCMusicPlayerItem.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 12/12/15.
//  Copyright (c) 2015 Hans Seiffert. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

class BSCMusicPlayerItem : NSObject {
	
	// MARK: -
	var mediaItem								: MPMediaItem?
	
    var mediaItemPersitentID					: UInt64?
	private var avPlayerItem					: AVPlayerItem?
	
	var nowPlayingInfo							: [String : NSObject]?
	
	// MARK: Playlog
	
	var startDate								: NSDate?
	var endDate									: NSDate?
	var playedTime								= Float(0)
	
	// MARK: - Creation
	
	convenience init?(mediaItemPersitentID: UInt64) {
		self.init()
		self.mediaItemPersitentID = mediaItemPersitentID
	}
	
	convenience init?(mediaItem: MPMediaItem) {
		guard mediaItem.isPlayable() == true else {
			return nil
		}
		self.init(mediaItemPersitentID: mediaItem.persistentID)
		self.mediaItem = mediaItem
	}
	
	class func musicPlayerItems(mediaItems: [MPMediaItem], startPosition: Int) -> (items: [BSCMusicPlayerItem], startPosition: Int) {
		BSCLog(Verbose.BSCMusicPLayer, "musicPlayerItems(mediaItems: \(mediaItems.count) items, startPosition: \(startPosition))")
		var reducedMuicPlayerItems = [BSCMusicPlayerItem]()
		var updatedPosition = startPosition
		for index in 0..<mediaItems.count {
			let mediaItem = mediaItems[index]
			if let _musicPlayerItem = BSCMusicPlayerItem(mediaItem: mediaItem) {
				reducedMuicPlayerItems.append(_musicPlayerItem)
			} else if (index <= startPosition && updatedPosition > 0) {
				updatedPosition -= 1
			}
		}
		return (items: reducedMuicPlayerItems, startPosition: updatedPosition)
	}
	
	override func copy() -> AnyObject {
		if let _mediaItem = self.mediaItem {
			return BSCMusicPlayerItem(mediaItem: _mediaItem)!
		} else if let _mediaItemPersitentID = self.mediaItemPersitentID {
			return BSCMusicPlayerItem(mediaItemPersitentID: _mediaItemPersitentID)!
		}
		return BSCMusicPlayerItem()
	}
	
	// MARK - 
	
	func loadResource() {
		if let _mediaItemPersitentID = self.mediaItemPersitentID {
			self.mediaItem = BSCMusicLibraryManager.songWithPersitentID(NSNumber(unsignedLongLong: _mediaItemPersitentID))
		}
	}
	
	func prepareForPlaying(avPlayerItem: AVPlayerItem) {
		self.avPlayerItem = avPlayerItem
		self.initNowPlayingInfo()
		// Add playback time change callback to calculate the played time
		BSCMusicPlayer.sharedInstance.addPlaybackTimeChangeCallback(self, callback: { (musicPlayerItem) -> Void in
			if
				musicPlayerItem == self &&
				(BSCMusicPlayer.sharedInstance.isPlaying() == true) {
					// Update the played time if the played song is the self one and if the player is playing
					self.playedTime += Float(BSCMusicPlayer.PlayingTimeRefreshRate)
			}
		})
	}
	
	func cleanupAfterPlaying() {
		BSCMusicPlayer.sharedInstance.removePlaybackTimeChangeCallback(self)
		self.avPlayerItem = nil
		self.nowPlayingInfo?.removeAll()
	}
	
	func willStartPlayback() {
		self.playedTime = 0
		self.startDate = NSDate()
	}
	
	func didStopPlayback() {
		// Complete the playback if it's not done yet. As the endDate is only set during the completion, we can use it as decision-making basis
		if (self.startDate != nil && self.endDate == nil) {
			self.cleanupAfterPlaying()
			self.endDate = NSDate()
			BSCPlaylogManager.add(self)
		}
	}
	
	// MARK: - Initialization
	
    func initNowPlayingInfo() {
		self.nowPlayingInfo = [String : NSObject]()
        if let title = self.mediaItem?.title {
            self.nowPlayingInfo?[MPMediaItemPropertyTitle] = title
        }
        if let artistName = self.mediaItem?.artist {
            self.nowPlayingInfo?[MPMediaItemPropertyArtist] = artistName
        }
        if let albumTitle = self.mediaItem?.albumTitle {
            self.nowPlayingInfo?[MPMediaItemPropertyAlbumTitle] = albumTitle
        }
		if let albumCover = self.mediaItem?.artwork {
			self.nowPlayingInfo?[MPMediaItemPropertyArtwork] = albumCover
		}
        self.setNowPlayingInfoPlaybackDuration()
    }
	
	// MARK: - Now playing info
    
    private func setNowPlayingInfoPlaybackDuration() {
		if let _musicPlayerItem = self.avPlayerItem {
			let duration = NSNumber(integer: Int(CMTimeGetSeconds(_musicPlayerItem.asset.duration)))
			self.nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = duration;
		}
    }
	
	// MARK: - Helper
	
	func isPlayables() -> Bool {
		return self.mediaItem?.isPlayable() ?? true
	}
	
	func durationInSeconds() -> Float {
		if let _musicPlayerItem = self.avPlayerItem where _musicPlayerItem.duration != kCMTimeIndefinite {
			return Float(CMTimeGetSeconds(_musicPlayerItem.duration))
		}
		return Float(0)
	}
	
	func currentProgress() -> Float {
		if (self.durationInSeconds() > 0) {
			return self.currentTimeInSeconds() / self.durationInSeconds()
		}
		return Float(0)
	}
	
	func currentTimeInSeconds() -> Float {
		if let _musicPlayerItem = self.avPlayerItem {
			return Float(CMTimeGetSeconds(_musicPlayerItem.currentTime()))
		}
		return Float(0)
	}
	
	func printUnplayableLog() {
		if let _mediaItam = self.mediaItem {
			if (_mediaItam.assetURL == nil) {
				BSCLog(Verbose.BSCMusicPLayer, "\(_mediaItam.title ?? "") is unplayable as it has no asset url. Player item: \(self)")
			}
			if (_mediaItam.cloudItem == true) {
				BSCLog(Verbose.BSCMusicPLayer, "\(_mediaItam.title ?? "") is unplayable as it is a cloud item. Player item: \(self)")
			}
		} else {
			BSCLog(Verbose.BSCMusicPLayer, "Item is unplayable as it has no media item. Item: \(self)")
		}
	}
	
	// MARK: Displayable Time strings
	
	func displayableCurrentTimeString() -> String {
		return BSCHelper.displayableStringFromTimeInterval(NSTimeInterval(self.currentTimeInSeconds()))
	}
	
	func displayableTimeLeftString() -> String {
		let timeLeft = self.durationInSeconds() - self.currentTimeInSeconds()
		return "-\(BSCHelper.displayableStringFromTimeInterval(NSTimeInterval(timeLeft)))"
	}
}
