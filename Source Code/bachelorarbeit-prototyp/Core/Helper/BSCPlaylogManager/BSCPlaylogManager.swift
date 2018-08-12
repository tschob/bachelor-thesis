//
//  BSCPlaylogManager.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 23.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import Foundation

class BSCPlaylogManager {
	
	private struct BSCPlaylogManagerConstants {
		static let MinPlayedTimeSecondsForPersistation			= Float(15)
	}
	
	class func add(musicPlayerItem: BSCMusicPlayerItem) {
		
		// Variable to store the playlogSong after it has been inserted. The playlog is fetched in the completion block using the objectID
		var insertedPlaylogSong : BSCPlaylogSong?
		
		if (musicPlayerItem.playedTime >= BSCPlaylogManagerConstants.MinPlayedTimeSecondsForPersistation) {
			MagicalRecord.saveWithBlock({ (managedObjectContext: NSManagedObjectContext!) -> Void in
				if let playlogSong = self.playlogSongFromMusicPlayerItem(musicPlayerItem, managedObjectContext: managedObjectContext) {
					// Create or get the current session
					if let playlogSession = self.currentPlaylogSession(playlogSong, managedObjectContext: managedObjectContext) {
						// Create the relationship between the session and the song
						playlogSession.addPlaylogSong(playlogSong)
					}
					// Store the objectID to enable the fetching in the completion block
					insertedPlaylogSong = playlogSong
				
					BSCLog(Verbose.BSCPLaylogManager, "Created playlog: \(playlogSong)")
				}
			}, completion: { (success: Bool, error: NSError?) -> Void in
					if let
						_insertedPlaylogSong = insertedPlaylogSong,
						optionalPlaylogSong = try? NSManagedObjectContext.MR_defaultContext().existingObjectWithID(_insertedPlaylogSong.objectID) as? BSCPlaylogSong,
						_playlogSong = optionalPlaylogSong {
							self.addContextTo(_playlogSong)
					} else {
						BSCLog(Verbose.BSCPLaylogManager, "Error: The playlogSong (id: \(insertedPlaylogSong?.objectID) couldn't be fetched from the managed object context)")
					}
			})
		}
	}
	
	private class func addContextTo(playlogSong: BSCPlaylogSong) {
		BSCContextManager.currentSongContext(self, update: nil, completion: { (songContext: BSCSongContext) -> Void in
			let defaultManagedObjectContext = NSManagedObjectContext.MR_defaultContext()
			
			if let _insertedContext = songContext.persistedEntity(defaultManagedObjectContext) {
				playlogSong.addSongContext(_insertedContext)
				defaultManagedObjectContext.MR_saveToPersistentStoreAndWait()
				BSCLog(Verbose.BSCPLaylogManager, "Added singlecontext: \(_insertedContext) to playlogSong: \(playlogSong) in managedObjectContext: \(defaultManagedObjectContext)")
			} else {
				BSCLog(Verbose.BSCPLaylogManager, "Error: The persisted entity couldn't be created")
			}
		})
	}

	// MARK: - Helper
	
	class private func playlogSongFromMusicPlayerItem(musicPlayerItem: BSCMusicPlayerItem, managedObjectContext: NSManagedObjectContext!) -> BSCPlaylogSong? {
		let song = BSCPlaylogSong.MR_createEntityInContext(managedObjectContext)
		song?.setMusicPlayerItem(musicPlayerItem)
		return song
	}
	
	class func currentPlaylogSession(managedObjectContext: NSManagedObjectContext!) -> BSCPlaylogSession? {
		let predicate = NSPredicate(format: "\(BSCPlaylogSession.Keys.EndDate) == nil")
		if let _playlogSession = BSCPlaylogSession.MR_findFirstWithPredicate(predicate, sortedBy: BSCPlaylogSession.Keys.StartDate, ascending: false, inContext: managedObjectContext) {
			return _playlogSession
		} else {
			return nil
		}
	}
	
	class private func currentPlaylogSession(playlogSong: BSCPlaylogSong, managedObjectContext: NSManagedObjectContext!) -> BSCPlaylogSession? {
		if let _playlogSession = self.currentPlaylogSession(managedObjectContext) {
			BSCLog(Verbose.BSCPLaylogManager, "Using existing playlog session as current one: \(_playlogSession)")
			return _playlogSession
		} else {
			let playlogSession = BSCPlaylogSession.MR_createEntityInContext(managedObjectContext)
			playlogSession?.startDate = playlogSong.startDate
			BSCLog(Verbose.BSCPLaylogManager, "Creating new playlog session as current one: \(playlogSession)")
			return playlogSession
		}
	}
	
	// MARK: -
	
	class func resetPlaylog() {
		BSCPlaylogSession.MR_truncateAll()
		BSCPlaylogSong.MR_truncateAll()
		BSCSongInfo.MR_truncateAll()
		BSCContext.MR_truncateAll()
		BSCWeatherContext.MR_truncateAll()
		BSCMotionContext.MR_truncateAll()
		BSCLocationCoordinates.MR_truncateAll()
		NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
	}
	
	// MARK: - Clean up

	class func cleanUp() {
		BSCLog(Verbose.BSCPLaylogManager, "Cleaning up the playlogs")
		self.cleanUpUncompletedPlaylogs()
		self.cleanUpBrokenSessionContexts()
		self.cleanUpUnusedSongInfos()
		BSCPlaylogSession.completeAllOpenSessions()
		NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
	}
	
	// MARK: Clean up (Private)
	
	class private func cleanUpUncompletedPlaylogs() {
		let predicate = NSPredicate(format: "\(BSCPlaylogSong.Keys.PlayedDuration) == 0")
		if let openPlaylogs = BSCPlaylogSong.MR_findAllWithPredicate(predicate) {
			for openPlaylog in openPlaylogs {
				openPlaylog.MR_deleteEntity()
			}
		}
	}
	
	class private func cleanUpBrokenSessionContexts() {
		let predicate = NSPredicate(format: "\(BSCContext.Key.StartDate) == nil")
		if let sessionsWithoutStartDate = BSCSessionContext.MR_findAllWithPredicate(predicate) as? [BSCSessionContext] {
			for sessionWithoutStartDate in sessionsWithoutStartDate {
				sessionWithoutStartDate.MR_deleteEntity()
			}
		}
	}
	
	class private func cleanUpUnusedSongInfos() {
		let predicate = NSPredicate(format: "\(BSCSongInfo.Keys.PlaylogSongs).@count == 0")
		if let unusedSongInfos = BSCSongInfo.MR_findAllWithPredicate(predicate) {
			for unusedSongInfo in unusedSongInfos {
				unusedSongInfo.MR_deleteEntity()
			}
		}
	}
}