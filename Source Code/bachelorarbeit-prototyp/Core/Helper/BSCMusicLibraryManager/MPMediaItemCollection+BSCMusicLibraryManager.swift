//
//  MPMediaItemCollection+BSCMusicLibraryManager.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 21.11.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import MediaPlayer

extension MPMediaItemCollection {

	func playlistTitle() -> String? {
		if let playlistName = self.valueForProperty(MPMediaPlaylistPropertyName) as? String {
			return playlistName
		}
		return nil
	}
	
	class func albumCountDescription(collection: MPMediaItemCollection?) -> String? {
		var albumTitleSet = Set<String>()
		if let _collection = collection {
			for song in _collection.items {
				albumTitleSet.insert(song.displayableAlbumTitle())
			}
		}

		let count = albumTitleSet.count
		return self.countDescription(count, type: .Album)
	}

	class func songCountDescription(collections: MPMediaItemCollection?) -> String? {
		let count = collections?.count ?? 0
		return self.countDescription(count, type: .Song)
	}
	
	private class func countDescription(count: Int, type: MusicLibraryType) -> String? {
		if (count == 0) {
			return nil
		} else if (count == 1) {
			return "\(count) \(type.singularTitle.capitalizedString)"
		} else {
			return "\(count) \(type.pluralTitle.capitalizedString)"
		}
	}
}
