//
//  BSCSongsViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 23.11.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import MediaPlayer

class BSCAlbumViewController: BSCMusicLibraryBaseViewController {

	@IBOutlet weak private var backgroundImageView		: UIImageView!
	
	@IBOutlet weak private var coverImageView			: UIImageView!
	@IBOutlet weak private var albumTitleLabel			: MarqueeLabel!
	@IBOutlet weak private var artistTitleLabel			: MarqueeLabel!
	
	@IBOutlet weak private var genreLabel				: MarqueeLabel!
	
	// MARK: View Lifecycle

    override func viewDidLoad() {
		super.viewDidLoad()
		if (self.sectionsData.count == 0) {
			self.loadDataInBackground({ () -> [(title: String, sectionData: [MPMediaEntity])]? in
				return BSCMusicLibraryManager.songsSections()
			})
		}
		
		self.initAlbumHeader()
	}
	
	override func shouldAddDefaultNavigationBarBackground() -> Bool {
		return false
	}
	
	// MARK: Abstract Methods Implementation
	
	override func titleForFooter() -> (singular: String, plural: String) {
		return (L("word.song"), L("word.songs"))
	}
	
	override func shouldUseColorScheme() -> Bool {
		return true
	}

	override func shouldUpdateTableViewInsets() -> Bool {
		return false
	}
	
	// MARK: - Private -
	
	// MARK: Initialization
	
	private func initAlbumHeader() {
		if let _representativeSongItem = self.itemForIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
			self.coverImageView.image = _representativeSongItem.artwork?.imageWithSize(CGSizeMake(150, 150))
			self.albumTitleLabel.text = _representativeSongItem.displayableAlbumTitle()
			self.artistTitleLabel.text = _representativeSongItem.albumArtist
			self.genreLabel.text = _representativeSongItem.genre
			
			// Use colors from the colorscheme
			if let _colorScheme = self.colorScheme {
				self.backgroundImageView.backgroundColor = _colorScheme.backgroundColor
				self.artistTitleLabel.textColor = _colorScheme.secondaryTextColor
				self.albumTitleLabel.textColor = _colorScheme.secondaryTextColor
				self.genreLabel.textColor = _colorScheme.primaryTextColor
				self.tableView.separatorColor = _colorScheme.primaryTextColor
			}
		}
	}
}

// MARK: - UITableView Delegate

extension BSCAlbumViewController {
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier.MediaItemCell, forIndexPath: indexPath)
		if let _item = self.itemForIndexPath(indexPath) {
			if let _cell = cell as? BSCMediaItemTableViewCell {
				_cell.initWithSong(_item)
				_cell.applyColorScheme(self.colorScheme)
				_cell.applySelectionColorScheme(self.colorScheme)
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
}
