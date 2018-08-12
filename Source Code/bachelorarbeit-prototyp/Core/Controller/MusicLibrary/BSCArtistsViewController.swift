//
//  BSCArtistsViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 24.11.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import MediaPlayer

class BSCArtistsViewController: BSCMusicLibraryBaseViewController {

	// MARK: View Lifecycle

    override func viewDidLoad() {
		super.viewDidLoad()
		if (self.isFirstLevelController == true) {
			self.loadDataInBackground({ () -> [(title: String, sectionData: [MPMediaEntity])]? in
				return BSCMusicLibraryManager.artistsSections()
			})
		}
	}

	// MARK: Abstract Methods Implementation
	
	override func shouldEnableSeachController() -> Bool {
		return isFirstLevelController
	}
	
	override func filteredArrayForSearchTerm(searchTerm: String) -> [MPMediaEntity]? {
		return BSCMusicLibraryManager.artists(searchTerm)
	}
	
	override func titleForFooter() -> (singular: String, plural: String) {
		return (L("word.artist"), L("word.artists"))
	}
	
	// MARK: Segue
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == Constants.Segue.PushArtist),
			let _artistViewController = segue.destinationViewController as? BSCArtistViewController,
			let _albumsCollections = sender as? [MPMediaItemCollection] {
				_artistViewController.isFirstLevelController = false
				// Create an array of only one collection in each section. This is they model which BSCArtistViewController expects
				var sections = [(title: String, sectionData: [MPMediaEntity])]()
				for collection in _albumsCollections {
					sections.append((title: (collection.displayableAlbumTitle()), sectionData: [collection]))
				}
				_artistViewController.sectionsData = sections
		}
	}
}

// MARK: - UITableView Delegate

extension BSCArtistsViewController {
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier.MediaCollectionCell, forIndexPath: indexPath)
		if
			let _itemCollection = self.itemCollectionForIndexPath(indexPath),
			let _cell = cell as? BSCMediaItemCollectionTableViewCell {
				_cell.initWithArtistCollection(_itemCollection, searchTerm: self.searchTerm)
		}
		cell.accessoryType = .DisclosureIndicator
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		 tableView.deselectRowAtIndexPath(indexPath, animated: true)
		if let _itemCollection = self.itemCollectionForIndexPath(indexPath) {
			self.performSegueWithIdentifier(Constants.Segue.PushArtist, sender: BSCMusicLibraryManager.albumsForArtist(_itemCollection.representativeItem))
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return Constants.CellHeights.MusicLibraryCollection
	}
}