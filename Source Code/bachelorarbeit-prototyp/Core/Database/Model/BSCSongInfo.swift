//
//  BSCSongInfo.swift
//  
//
//  Created by Hans Seiffert on 23.12.15.
//
//

import Foundation
import CoreData

@objc(BSCSongInfo)
class BSCSongInfo: NSManagedObject {

	// MARK: - Keys
	
	struct Keys {
		static let PlaylogSongs			= "playlogSongs"
	}
	
	// MARK: - Set
	
	func setMusicPlayerItem(musicPlayerItem: BSCMusicPlayerItem) {
		self.albumTitle = musicPlayerItem.mediaItem?.albumTitle
		self.artistName = musicPlayerItem.mediaItem?.artist
		self.duration = musicPlayerItem.mediaItem?.playbackDuration
		self.genre = musicPlayerItem.mediaItem?.genre
		if let _persistentID = musicPlayerItem.mediaItem?.persistentID {
			self.persistentID = NSNumber(unsignedLongLong: _persistentID)
		} else {
			self.persistentID = nil
		}
		self.title = musicPlayerItem.mediaItem?.title
	}

	// Relationships
	
	func addPlaylogSong(playlogSong: BSCPlaylogSong) {
		let playlogSongsSet = self.mutableSetValueForKey(BSCSongInfo.Keys.PlaylogSongs)
		playlogSongsSet.addObject(playlogSong)
		self.playlogSongs = playlogSongsSet
		playlogSong.songInfo = self
	}
}
