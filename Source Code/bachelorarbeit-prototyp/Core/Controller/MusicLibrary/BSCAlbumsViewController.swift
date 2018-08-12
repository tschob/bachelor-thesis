//
//  BSCAlbumsViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 23.11.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import MediaPlayer

class BSCAlbumsViewController: BSCMusicLibraryBaseViewController {
	
	// MARK: View Lifecycle

    override func viewDidLoad() {
		super.viewDidLoad()
		if (self.isFirstLevelController == true) {
			self.loadDataInBackground({ () -> [(title: String, sectionData: [MPMediaEntity])]? in
				return BSCMusicLibraryManager.albumsSections()
			})
		}
	}

	// MARK: Abstract Methods Implementation
	
	override func shouldEnableSeachController() -> Bool {
		return isFirstLevelController
	}
	
	override func filteredArrayForSearchTerm(searchTerm: String) -> [MPMediaEntity]? {
		return BSCMusicLibraryManager.albums(searchTerm)
	}
	
	override func titleForFooter() -> (singular: String, plural: String) {
		return (L("word.album"), L("word.albums"))
	}
	
	// MARK: Segue
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == Constants.Segue.PushAlbum),
			let _albumViewController = segue.destinationViewController as? BSCAlbumViewController,
			let _itemCollection = sender as? MPMediaItemCollection {
				_albumViewController.isFirstLevelController = false
				_albumViewController.sectionsData = [(title: "", sectionData: _itemCollection.items)]
		}
	}
}

// MARK: - UITableView Delegate

extension BSCAlbumsViewController {
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier.MediaCollectionCell, forIndexPath: indexPath)
		if
			let _itemCollection = self.itemCollectionForIndexPath(indexPath),
			let _cell = cell as? BSCMediaItemCollectionTableViewCell {
				_cell.initWithAlbumCollection(_itemCollection, searchTerm: self.searchTerm)
		}
		cell.accessoryType = .DisclosureIndicator
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		 tableView.deselectRowAtIndexPath(indexPath, animated: true)
		if let _itemCollection = self.itemCollectionForIndexPath(indexPath) {
			self.performSegueWithIdentifier(Constants.Segue.PushAlbum, sender: _itemCollection)
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return Constants.CellHeights.MusicLibraryCollection
	}
}
