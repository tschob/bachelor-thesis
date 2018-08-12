//
//  BSCPlaylistsViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 24.11.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import MediaPlayer

class BSCPlaylistsViewController: BSCMusicLibraryBaseViewController {

	// MARK: View Lifecycle

    override func viewDidLoad() {
		super.viewDidLoad()
		if (self.isFirstLevelController == true) {
			self.loadDataInBackground({ () -> [(title: String, sectionData: [MPMediaEntity])]? in
				return BSCMusicLibraryManager.playlistsSections()
			})
		}
	}

	// MARK: Abstract Methods Implementation
	
	override func shouldEnableSeachController() -> Bool {
		return isFirstLevelController
	}
	
	override func filteredArrayForSearchTerm(searchTerm: String) -> [MPMediaEntity]? {
		return BSCMusicLibraryManager.playlists(searchTerm)
	}
	
	override func titleForFooter() -> (singular: String, plural: String) {
		return (L("word.playlist"), L("word.playlists"))
	}
	
	// MARK: Segue
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == Constants.Segue.PushPlaylist),
			let _songsViewController = segue.destinationViewController as? BSCSongsViewController,
			let _playlistCollection = sender as? MPMediaItemCollection {
				_songsViewController.isFirstLevelController = false
				_songsViewController.sectionsData = [(title: "", sectionData: _playlistCollection.items)]
				_songsViewController.navigationItem.title = _playlistCollection.playlistTitle()
		}
	}
}

// MARK: - UITableView Delegate

extension BSCPlaylistsViewController {
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier.MediaCollectionCell, forIndexPath: indexPath)
		if
			let _itemCollection = self.itemCollectionForIndexPath(indexPath),
			let _cell = cell as? BSCMediaItemCollectionTableViewCell {
				_cell.initWithPlaylistCollection(_itemCollection, searchTerm: self.searchTerm)
		}
		cell.accessoryType = .DisclosureIndicator
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		 tableView.deselectRowAtIndexPath(indexPath, animated: true)
		if let _itemCollection = self.itemCollectionForIndexPath(indexPath) {
			self.performSegueWithIdentifier(Constants.Segue.PushPlaylist, sender: _itemCollection)
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return Constants.CellHeights.MusicLibraryCollection
	}
}
