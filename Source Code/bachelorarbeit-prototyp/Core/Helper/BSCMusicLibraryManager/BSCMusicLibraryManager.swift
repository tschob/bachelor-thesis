//
//  BSCMusicLibraryManager.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 21.11.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer

class BSCMusicLibraryManager: NSObject {

	// MARK: - Playlists
	
	class func playlists() -> [MPMediaItemCollection]? {
		return MPMediaQuery.playlistsQuery().collections
	}
	
	class func playlists(seachTerm: String) -> [MPMediaItemCollection]? {
		if let _collections = self.playlists() {
			return _collections.filter({
				$0.playlistTitle()?.lowercaseString.containsString(seachTerm.lowercaseString) == true
			})
		}
		return nil
	}
	
	class func playlistsSections() -> [(title: String, sectionData: [MPMediaEntity])]? {
		return self.sectionsFromCollections(MPMediaQuery.playlistsQuery())
	}
	
	// MARK: - Genres

	class func genres() -> [MPMediaItemCollection]? {
		return MPMediaQuery.genresQuery().collections
	}
	
	class func genres(seachTerm: String) -> [MPMediaItemCollection]? {
		if let _collections = self.genres() {
			return _collections.filter({
				$0.representativeItem?.genre?.lowercaseString.containsString(seachTerm.lowercaseString) == true
			})
		}
		return nil
	}
	
	class func genresSections() -> [(title: String, sectionData: [MPMediaEntity])]? {
		return self.sectionsFromCollections(MPMediaQuery.genresQuery())
	}
	
	// MARK: - Artists

	class func artists() -> [MPMediaItemCollection]? {
		return MPMediaQuery.artistsQuery().collections
	}
	
	class func artists(seachTerm: String) -> [MPMediaItemCollection]? {
		if let _collections = self.artists() {
			return _collections.filter({
				$0.representativeItem?.artist?.lowercaseString.containsString(seachTerm.lowercaseString) == true
			})
		}
		return nil
	}
	
	class func artistsSections() -> [(title: String, sectionData: [MPMediaEntity])]? {
		return self.sectionsFromCollections(MPMediaQuery.artistsQuery())
	}
	
	// MARK: - Albums

	class func albums() -> [MPMediaItemCollection]? {
		return MPMediaQuery.albumsQuery().collections
	}
	
	class func albums(seachTerm: String) -> [MPMediaItemCollection]? {
		if let _collections = self.albums() {
			return _collections.filter({
				$0.representativeItem?.albumTitle?.lowercaseString.containsString(seachTerm.lowercaseString) == true
			})
		}
		return nil
	}
	
	class func albumsSections() -> [(title: String, sectionData: [MPMediaEntity])]? {
		return self.sectionsFromCollections(MPMediaQuery.albumsQuery())
	}
	
	class func albumsForArtist(mediaItem: MPMediaItem?) -> [MPMediaItemCollection]? {
		if let _artistName = mediaItem?.artist {
			let predicate = MPMediaPropertyPredicate(value: _artistName, forProperty: MPMediaItemPropertyArtist, comparisonType: .EqualTo)
			let query = MPMediaQuery(filterPredicates: Set(arrayLiteral: predicate))
			query.groupingType = .Album
			return query.collections
		}
		return nil
	}
	
	// MARK: - Songs

	class func songs() -> [MPMediaItem]? {
		return MPMediaQuery.songsQuery().items
	}
	
	class func songs(seachTerm: String) -> [MPMediaItem]? {
		if let _collections = self.songs() {
			return _collections.filter({
				$0.title?.lowercaseString.containsString(seachTerm.lowercaseString) == true
			})
		}
		return nil
	}
	
	class func songsSections() -> [(title: String, sectionData: [MPMediaEntity])]? {
		return self.sectionsFromItems(MPMediaQuery.songsQuery())
	}
	
	class func songWithPersitentID(pid: NSNumber) -> MPMediaItem? {
		let predicate = MPMediaPropertyPredicate(value: pid, forProperty: MPMediaItemPropertyPersistentID, comparisonType: .EqualTo)
		let query = MPMediaQuery(filterPredicates: Set(arrayLiteral: predicate))
		query.groupingType = .Playlist
		return query.items?.first
	}
	
	// MARK: - Helper
	
	private class func sectionsFromCollections(query: MPMediaQuery) -> [(title: String, sectionData: [MPMediaEntity])]? {
		// Create dictionary which will be returned
		var sectionedCollections = [(title: String, sectionData: [MPMediaEntity])]()
		if let
			_collectionSections = query.collectionSections,
			_collections = query.collections {
				// Iterate through every section and add it to the dictionary
				for sectionDescription in _collectionSections {
					// Create the array which wiil contain all MPMediaItemCollections
					var sectionContent = [MPMediaItemCollection]()
					for index in sectionDescription.range.location..<sectionDescription.range.location + sectionDescription.range.length {
						// Add all items from the sections range to the array
						sectionContent.append(_collections[index])
					}
					// Set the title and the items array
					sectionedCollections.append((sectionDescription.title, sectionContent))
				}
		}
		return sectionedCollections
	}
	
	private class func sectionsFromItems(query: MPMediaQuery) -> [(title: String, sectionData: [MPMediaEntity])]? {
		var sectionedItems = [(title: String, sectionData: [MPMediaEntity])]()
		if let
			_itemSections = query.itemSections,
			items = query.items {
				for sectionDescription in _itemSections {
					var sectionContent = [MPMediaItem]()
					for index in sectionDescription.range.location..<sectionDescription.range.location + sectionDescription.range.length {
						sectionContent.append(items[index])
					}
					sectionedItems.append((sectionDescription.title, sectionContent))
				}
		}
		return sectionedItems
	}
	
	// MARK: Public Helper
	
	class func albumCountTrackCountDescription(itemCollection: MPMediaItemCollection) -> String {
		var description = ""
		if let _albumsCountDescription = MPMediaItemCollection.albumCountDescription(itemCollection) {
			description = _albumsCountDescription
		}
		if let _songsCountDescription = MPMediaItemCollection.songCountDescription(itemCollection) {
			if (description.characters.count > 0) {
				description += " • "
			}
			description += _songsCountDescription
		}
		return description
	}
	
	class func artistTitleTrackCountDescription(itemCollection: MPMediaItemCollection) -> String {
		var description = ""
		if let _artistTitleDescription = itemCollection.representativeItem?.albumArtist {
			description = _artistTitleDescription
		}
		if let _songsCountDescription = MPMediaItemCollection.songCountDescription(itemCollection) {
			if (description.characters.count > 0) {
				description += " • "
			}
			description += _songsCountDescription
		}
		return description
	}
}
