//
//  BSCSongsViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 23.11.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import MediaPlayer

class BSCSongsViewController: BSCMusicLibraryBaseViewController {

	// MARK: View Lifecycle

    override func viewDidLoad() {
		super.viewDidLoad()
		if (self.isFirstLevelController == true) {
			self.loadDataInBackground({ () -> [(title: String, sectionData: [MPMediaEntity])]? in
				return BSCMusicLibraryManager.songsSections()
			})
		}
	}

	// MARK: Abstract Methods Implementation
	
	override func shouldEnableSeachController() -> Bool {
		return isFirstLevelController
	}
	
	override func filteredArrayForSearchTerm(searchTerm: String) -> [MPMediaEntity]? {
		return BSCMusicLibraryManager.songs(searchTerm)
	}
	
	override func titleForFooter() -> (singular: String, plural: String) {
		return (L("word.song"), L("word.songs"))
	}
}

// MARK: UITableView Delegate

extension BSCSongsViewController {
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier.MediaCollectionCell, forIndexPath: indexPath)
		
		if let _item = self.itemForIndexPath(indexPath) {
			if let _cell = cell as? BSCMediaItemCollectionTableViewCell {
				_cell.initWithSong(_item, searchTerm: self.searchTerm)
			}
		}
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		if let _item = self.itemForIndexPath(indexPath) {
			let allItems = self.arrayWithAllItems()
			if let _indexOfItem = allItems.indexOf(_item) {
				BSCMusicPlayer.sharedInstance.play(mediaItems: allItems, startPosition: _indexOfItem)
			}
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return Constants.CellHeights.MusicLibrarySong
	}
}
