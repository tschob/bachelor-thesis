//
//  BSCArtistViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 24.11.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import MediaPlayer

class BSCArtistViewController: BSCMusicLibraryBaseViewController {
	
	private var selectedSectionHeaderIndex		= -1
	
	// MARK: View Lifecycle

    override func viewDidLoad() {
		super.viewDidLoad()
		
		self.tableView.registerNib(UINib(nibName: "BSCArtistAlbumHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: Constants.CellIdentifier.ArtistAlbumHeaderView)

		self.navigationItem.title = self.itemForIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.artist
	}
	
	// MARK: Abstract Methods Implementation
	
	override func shouldShowFooter() -> Bool {
		return false
	}
	
	override func shouldUseColorScheme() -> Bool {
		return true
	}
	
	override func shouldAddDefaultNavigationBarBackground() -> Bool {
		return false
	}
	
	// MARK: Helper
	
	override func itemForIndexPath(indexPath: NSIndexPath) -> MPMediaItem? {
		if let _collection = self.itemCollectionForSection(indexPath.section) {
			if (indexPath.row < _collection.items.count) {
				return _collection.items[indexPath.row]
			}
		}
		return nil
	}
	
	func itemForSection(section: Int) -> MPMediaItem? {
		return self.itemForIndexPath(NSIndexPath(forRow: 0, inSection: section))
	}
	
	func itemCollectionForSection(section: Int) -> MPMediaItemCollection? {
		return self.itemCollectionForIndexPath(NSIndexPath(forRow: 0, inSection: section))
	}
	
	override func arrayWithAllItems() -> [MPMediaItem] {
		var allItems = [MPMediaItem]()
		for section in 0..<self.sectionsData.count {
			if let _albumCollection = self.itemCollectionForSection(section) {
				allItems.appendContentsOf(_albumCollection.items)
			}
		}
		return allItems
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

extension BSCArtistViewController {
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier.MediaItemCell, forIndexPath: indexPath)
		if
			let _item = self.itemForIndexPath(indexPath),
			let _cell = cell as? BSCMediaItemTableViewCell {
				_cell.initWithSong(_item)
				_cell.applyColorScheme(self.colorScheme)
				_cell.applySelectionColorScheme(self.colorScheme)
		}
		return cell
	}
	
	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(Constants.CellIdentifier.ArtistAlbumHeaderView)
		if let
			_view = view as? BSCArtistAlbumHeaderView,
			_albumItem = self.itemForSection(section) {
				_view.initWithItemFromAlbum(_albumItem)
				_view.applyColorScheme(self.colorScheme)
				_view.section = section
				_view.selection = { (section: Int) -> Void in
					self.selectedSectionHeaderIndex = section
					if let _itemCollection = self.itemCollectionForSection(section) {
						self.performSegueWithIdentifier(Constants.Segue.PushAlbum, sender: _itemCollection)
					}
				}
		}
		return view
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (self.sectionsData.count < 4) {
			if let _albumCollection = self.sectionsData[section].sectionData as? [MPMediaItemCollection] {
				return _albumCollection.first?.items.count ?? 0
			}
		}
		return 0
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return self.sectionsData.count ?? 0
	}
	
	
	override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
		return nil
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
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 60
	}
}
