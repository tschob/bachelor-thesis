//
//  MPMediaItemCollection+Bachelorarbeit.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 23.11.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import MediaPlayer

extension MPMediaItemCollection {

	func albums() -> [MPMediaItemCollection]? {
		return BSCMusicLibraryManager.albumsForArtist(self.representativeItem)
	}
	
	func artworkImageWithSize(size: CGSize) -> UIImage? {
		var uniqueArtworkImages = [Int: MPMediaItemArtwork]()
		for item in self.items {
			if let _artwork = item.artwork {
				uniqueArtworkImages[_artwork.hash] = item.artwork
			}
		}
		if (uniqueArtworkImages.count >= 4) {
			//TODO: create multi image
			return uniqueArtworkImages.values.first?.imageWithSize(size)
		} else if (uniqueArtworkImages.count > 0) {
			return uniqueArtworkImages.values.first?.imageWithSize(size)
		} else {
			return nil
		}
	}
	
	func displayableAlbumTitle() -> String {
		if let _albumTitle = self.representativeItem?.albumTitle where (_albumTitle.characters.count > 0) {
			return _albumTitle
		}
		return L("album.title.unknown")
	}
}
