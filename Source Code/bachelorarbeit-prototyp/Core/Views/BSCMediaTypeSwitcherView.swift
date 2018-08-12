//
//  BSCMediaTypeSwitcherView.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 07.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit

class BSCMediaTypeSwitcherView: UIView {

	var buttonPressedHandler							: ((type: MusicLibraryType) -> Void)?

	var isIntitialzed									= false
	
	@IBOutlet  private var artistsButton				: UIButton?
	@IBOutlet  private var albumsButton					: UIButton?
	@IBOutlet weak private var songsButton				: UIButton?
	@IBOutlet weak private var genresButton				: UIButton?
	@IBOutlet weak private var playlistsButton			: UIButton?
	
	// MARK: View lifecycle
	
	override func didMoveToWindow() {
		if (self.isIntitialzed == false) {
			self.initBackground()
			self.initButtons()
			self.isIntitialzed = true
		}
	}
	
	private func initBackground() {
		// Add blur effect
		let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
		visualEffectView.frame = self.bounds
		visualEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
		self.addSubview(visualEffectView)
		self.sendSubviewToBack(visualEffectView)
		self.backgroundColor = UIColor.clearColor()
	}
	
	private func initButtons() {
		self.artistsButton?.setTitle(MusicLibraryType.Artist.pluralTitle.capitalizedString, forState: .Normal)
		self.albumsButton?.setTitle(MusicLibraryType.Album.pluralTitle.capitalizedString, forState: .Normal)
		self.songsButton?.setTitle(MusicLibraryType.Song.pluralTitle.capitalizedString, forState: .Normal)
		self.genresButton?.setTitle(MusicLibraryType.Genre.pluralTitle.capitalizedString, forState: .Normal)
		self.playlistsButton?.setTitle(MusicLibraryType.Playlist.pluralTitle.capitalizedString, forState: .Normal)
	}
	
	@IBAction private func didPressButton(sender: AnyObject?) {
		selectType(nil)
		// Call handler and select choosen button
		if let _buttonPressedHandler = self.buttonPressedHandler {
			if (sender === self.artistsButton) {
				_buttonPressedHandler(type: MusicLibraryType.Artist)
				self.artistsButton?.selected = true
			} else if (sender === self.albumsButton) {
				_buttonPressedHandler(type: MusicLibraryType.Album)
				self.albumsButton?.selected = true
			} else if (sender === self.songsButton) {
				_buttonPressedHandler(type: MusicLibraryType.Song)
				self.songsButton?.selected = true
			} else if (sender === self.genresButton) {
				_buttonPressedHandler(type: MusicLibraryType.Genre)
				self.genresButton?.selected = true
			} else if (sender === self.playlistsButton) {
				_buttonPressedHandler(type: MusicLibraryType.Playlist)
				self.playlistsButton?.selected = true
			}
		}
	}
	
	func selectType(type: MusicLibraryType?) {
		self.artistsButton?.selected = false
		self.albumsButton?.selected = false
		self.songsButton?.selected = false
		self.genresButton?.selected = false
		self.playlistsButton?.selected = false
		
		if let _type = type {
			switch _type {
			case .Artist:
				self.artistsButton?.selected = true
			case .Album:
				self.albumsButton?.selected = true
			case .Song:
				self.songsButton?.selected = true
			case .Genre:
				self.genresButton?.selected = true
			case .Playlist:
				self.playlistsButton?.selected = true
			}
		}
	}

}
