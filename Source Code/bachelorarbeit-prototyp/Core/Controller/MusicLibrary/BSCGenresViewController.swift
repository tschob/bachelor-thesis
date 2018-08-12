//
//  BSCGenresViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 24.11.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import MediaPlayer

class BSCGenresViewController: BSCMusicLibraryBaseViewController {

	// MARK: View Lifecycle

    override func viewDidLoad() {
		super.viewDidLoad()
		if (self.isFirstLevelController == true) {
			self.loadDataInBackground({ () -> [(title: String, sectionData: [MPMediaEntity])]? in
				return BSCMusicLibraryManager.genresSections()
			})
		}
	}

	// MARK: Abstract Methods Implementation
	
	override func shouldEnableSeachController() -> Bool {
		return isFirstLevelController
	}
	
	override func filteredArrayForSearchTerm(searchTerm: String) -> [MPMediaEntity]? {
		return BSCMusicLibraryManager.genres(searchTerm)
	}
	
	override func titleForFooter() -> (singular: String, plural: String) {
		return (L("word.genre"), L("word.genre"))
	}
	
	// MARK: Segue
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == Constants.Segue.PushGenre),
			let _songsViewController = segue.destinationViewController as? BSCSongsViewController,
			let _songsCollections = sender as? [MPMediaItem] {
				_songsViewController.isFirstLevelController = false
				_songsViewController.sectionsData = [(title: "", sectionData: _songsCollections)]
				_songsViewController.navigationItem.title = _songsCollections.first?.genre
		}
	}
}

// MARK: - UITableView Delegate

extension BSCGenresViewController {
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier.MediaCollectionCell, forIndexPath: indexPath)
		if
			let _itemCollection = self.itemCollectionForIndexPath(indexPath),
			let _cell = cell as? BSCMediaItemCollectionTableViewCell {
				_cell.initWithGenreCollection(_itemCollection, searchTerm: self.searchTerm)
		}
		cell.accessoryType = .DisclosureIndicator
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		 tableView.deselectRowAtIndexPath(indexPath, animated: true)
		if let _itemCollection = self.itemCollectionForIndexPath(indexPath) {
			self.performSegueWithIdentifier(Constants.Segue.PushGenre, sender: _itemCollection.items)
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return Constants.CellHeights.MusicLibraryCollection
	}
}
