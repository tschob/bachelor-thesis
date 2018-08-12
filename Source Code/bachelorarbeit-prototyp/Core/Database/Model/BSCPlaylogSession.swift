//
//  BSCPlaylogSession.swift
//  
//
//  Created by Hans Seiffert on 23.12.15.
//
//

import Foundation
import CoreData

@objc(BSCPlaylogSession)
class BSCPlaylogSession: NSManagedObject {
	
	// MARK: - Keys
	
	struct Keys {
		static let EndDate						= "endDate"
		static let StartDate					= "startDate"
		static let PlaylogSongs					= "playlogSongs"
	}
	
	// MARK: - Complete
	
	class func completeAllOpenSessions() {
		if (BSCMusicPlayer.sharedInstance.isPlaying() == false) {
			let predicate = NSPredicate(format: "\(Keys.EndDate) == nil")
			if let openSessions = BSCPlaylogSession.MR_findAllWithPredicate(predicate) as? [BSCPlaylogSession] {
				for openSession in openSessions {
					openSession.complete()
				}
			}
		}
	}
	
	private func complete() {
		MagicalRecord.saveWithBlock({ (managedObjectContext: NSManagedObjectContext!) -> Void in
			// Get session in local context
			if let modifiedSession = self.MR_inContext(managedObjectContext) {
				// Set the enddate
				if let
					_lastPlayedSong = self.sortedPlaylogSongs()?.last,
					_lastStartDate = _lastPlayedSong.startDate {
						// Use the startDate + playedDuration from the last played song as endDate
						modifiedSession.endDate = _lastStartDate.dateByAddingSecondInterval((_lastPlayedSong.playedDuration?.integerValue ?? 0))
				} else {
					// Something went wrong, use the current date as fallback
					modifiedSession.endDate = NSDate()
				}
			
				if let sessionContext = BSCSessionContext.MR_createEntityInContext(managedObjectContext) {
					sessionContext.resetWithContexts(modifiedSession.allContexts())
					modifiedSession.addSessionContext(sessionContext)
				}
				managedObjectContext.MR_saveToPersistentStoreAndWait()
			}
		})
	}
	
	// Displayable Strings
	
	func displayableTitleString() -> String {
		var title = ""
		if let _label = self.sessionContext?.label {
			title = "\(_label) - "
		}
		if let _startDate = self.startDate {
			title += NSString(fromDate: _startDate, format: "dd.MM.yy': 'HH:mm") as String
		}
		if let _endDate = self.endDate {
			title += NSString(fromDate: _endDate, format: "' - 'HH:mm") as String
		} else {
			title += " - ?"
		}
		return title
	}
	
	// Relationships
	
	func addPlaylogSong(playlogSong: BSCPlaylogSong) {
		let playlogSongsSet = self.mutableSetValueForKey(BSCPlaylogSession.Keys.PlaylogSongs)
		playlogSongsSet.addObject(playlogSong)
		self.playlogSongs = playlogSongsSet
		playlogSong.session = self
	}
	
	func addPlaylogSongs(playlogSongs: [BSCPlaylogSong]) {
		for playlogSong in playlogSongs {
			self.addPlaylogSong(playlogSong)
		}
	}
	
	func addSessionContext(sessionContext: BSCSessionContext) {
		self.sessionContext = sessionContext
		sessionContext.playlogSession = self
	}
	
	func allContexts() -> [BSCContext] {
		var contexts = [BSCContext]()
		if let _playlogSongs = self.playlogSongs?.allObjects as? [BSCPlaylogSong] {
			for playlogSong in _playlogSongs {
				if let _context = playlogSong.context {
					contexts.append(_context)
				}
			}
		}
		return contexts
	}
	
	// MARK: - Private
	
	// MARK: - Helper
	
	private func sortedPlaylogSongs() -> [BSCPlaylogSong]? {
		let playlogSongs = self.playlogSongs?.sort({
			if let
				_a = $0 as? BSCPlaylogSong,
				_b = $1 as? BSCPlaylogSong {
					return _a.startDate?.timeIntervalSince1970 < _b.startDate?.timeIntervalSince1970
			} else {
				return true
			}
		})
		if let _playlogSongs = playlogSongs as? [BSCPlaylogSong] {
			return _playlogSongs
		} else {
			return nil
		}
	}
}
