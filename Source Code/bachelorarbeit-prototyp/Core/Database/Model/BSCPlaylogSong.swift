//
//  BSCPlaylogSong.swift
//  
//
//  Created by Hans Seiffert on 23.12.15.
//
//

import Foundation
import CoreData

@objc(BSCPlaylogSong)
class BSCPlaylogSong: NSManagedObject {
	
	// MARK: - Keys
	
	struct Keys {
		static let PlayedDuration			= "playedDuration"
		static let StartDate				= "startDate"
		static let Session					= "session"
	}
	
	// MARK: - Set
	
	func setMusicPlayerItem(musicPlayerItem: BSCMusicPlayerItem) {
		self.startDate = musicPlayerItem.startDate
		self.endDate = musicPlayerItem.endDate
		self.playedDuration = musicPlayerItem.playedTime

		// Create the songInfo object with the own context or if this is nil, as unpersited entity
		if let songInfo = (self.managedObjectContext != nil) ? BSCSongInfo.MR_createEntityInContext(self.managedObjectContext!) : BSCSongInfo.unpersistedEntity() {
			songInfo.setMusicPlayerItem(musicPlayerItem)
			songInfo.addPlaylogSong(self)
		}
	}
	
	// Displayable strings
	
	func displayableDateString() -> String {
		if let _startDate = self.startDate {
			return NSString(fromDate: _startDate, format: "dd.MM.yy' - 'HH:mm") as String
		}
		return "-"
	}
	
	// Relationships
	
	func addSongContext(songContext: BSCSongContext) {
		self.context = songContext
		songContext.playlogSong = self
	}
}
