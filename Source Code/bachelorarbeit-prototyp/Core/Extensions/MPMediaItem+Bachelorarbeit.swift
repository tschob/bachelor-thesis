//
//  MPMediaItem+Bachelorarbeit.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 23.11.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import MediaPlayer

extension MPMediaItem {

	func isPlayable() -> Bool {
		return (self.cloudItem == false && self.assetURL != nil)
	}
	
	func playbackDurationDescription() -> String {
		return BSCHelper.displayableStringFromTimeInterval(self.playbackDuration)
	}
	
	func artistAlbumDescription() -> String {
		var subtitle = ""
		if let _artistName = self.artist {
			subtitle = "\(_artistName)"
		} else {
			subtitle = "?"
		}
		subtitle += " - \(self.displayableAlbumTitle())"
		return subtitle
	}
	
	func colorScheme() -> LEColorScheme? {
		if let _image = self.artwork?.imageWithSize(CGSizeMake(40, 40)) {
			return LEColorPicker().colorSchemeFromImage(_image)
		}
		return nil
	}
	
	func displayableAlbumTitle() -> String {
		if let _albumTitle = self.albumTitle where (_albumTitle.characters.count > 0) {
			return _albumTitle
		}
		return L("album.title.unknown")
	}
}
