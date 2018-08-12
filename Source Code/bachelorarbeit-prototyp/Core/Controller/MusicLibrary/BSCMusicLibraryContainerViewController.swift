//
//  BSCMusicLibraryContainerViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 07.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit

class BSCMusicLibraryContainerViewController: BSCViewController {

	private var contentViewController							: BSCContainerViewController?

	private var navigationBarTitleButtonView					: BSCMusicLibraryContainerTypeButtonView?
	
	// MARK Type switcher
	@IBOutlet weak private var typeSwitcherView					: BSCMediaTypeSwitcherView?
	private var typeSwitcherOriginalHeight						: CGFloat?
	@IBOutlet weak private var typeSwitcherHeightConstraint		: NSLayoutConstraint?
	@IBOutlet weak var typeSwitcherCloseButton					: UIButton?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        self.initNavigationBarTitleButtonView()
		self.initTypeSwitcherView()
		
		// Set the presentation context to make sure the search bar isn't staying on the pushed view controllers
		self.definesPresentationContext = true
    }
	
	private func initNavigationBarTitleButtonView() {
		self.navigationBarTitleButtonView = BSCMusicLibraryContainerTypeButtonView.initFromNib()
		self.updateTypeSwitcherTitleWithType(BSCPreferences.activeMusicLibraryType)
		self.navigationBarTitleButtonView?.buttonPressedHandler = { [weak self] in
			self?.toogleTypeSwitcherVisiblity(true)
		}
		self.navigationItem.titleView = self.navigationBarTitleButtonView
	}
	
	// MARK: TypeSwitcherView
	
	private func initTypeSwitcherView() {
		self.self.typeSwitcherOriginalHeight = self.typeSwitcherHeightConstraint?.constant
		self.toogleTypeSwitcherVisiblity(false)
		self.typeSwitcherView?.buttonPressedHandler = { (type: MusicLibraryType) -> Void  in
			self.showType(type)
			self.toogleTypeSwitcherVisiblity(true)
		}
	}
	
	private var isTypeSwitcherVisible: Bool {
		get {
			return (self.typeSwitcherHeightConstraint?.constant == self.typeSwitcherOriginalHeight)
		}
	}
	
	private func toogleTypeSwitcherVisiblity(animated: Bool) {
		if (self.isTypeSwitcherVisible == false) {
			self.typeSwitcherHeightConstraint?.constant = self.typeSwitcherOriginalHeight ?? 0
			self.typeSwitcherCloseButton?.hidden = false
		} else {
			self.typeSwitcherHeightConstraint?.constant = 0
			self.typeSwitcherCloseButton?.hidden = true
		}
		let animationDuration = (animated ? 0.3 : 0)
		UIView.animateWithDuration(animationDuration, animations: { () -> Void in
			self.typeSwitcherView?.layoutIfNeeded()
		})
	}
	
	func showType(type: MusicLibraryType) {
		switch type {
		case .Artist:
			self.contentViewController?.swapWithSegueIdentifier(Constants.Segue.EmbedArtists)
			// Set the text from the original title view as this string is also used for the back button in the following view controllers
			self.navigationItem.title = MusicLibraryType.Artist.pluralTitle.capitalizedString
		case .Album:
			self.contentViewController?.swapWithSegueIdentifier(Constants.Segue.EmbedAlbums)
			self.navigationItem.title = MusicLibraryType.Album.pluralTitle.capitalizedString
		case .Song:
			self.contentViewController?.swapWithSegueIdentifier(Constants.Segue.EmbedSongs)
			self.navigationItem.title = MusicLibraryType.Song.pluralTitle.capitalizedString
		case .Genre:
			self.contentViewController?.swapWithSegueIdentifier(Constants.Segue.EmbedGenres)
			self.navigationItem.title = MusicLibraryType.Genre.pluralTitle.capitalizedString
		case .Playlist:
			self.contentViewController?.swapWithSegueIdentifier(Constants.Segue.EmbedPlaylists)
			self.navigationItem.title = MusicLibraryType.Playlist.pluralTitle.capitalizedString
		}
		BSCPreferences.activeMusicLibraryType = type
		self.updateTypeSwitcherTitleWithType(type)
	}
	
	func updateTypeSwitcherTitleWithType(type: MusicLibraryType) {
		self.navigationItem.title = type.pluralTitle.capitalizedString
		// Set the text of the visible title view
		self.navigationBarTitleButtonView?.setTitle(self.navigationItem.title ?? "")
	}
	
	@IBAction private func didPressTypeSwitcherCloseButton(sender: AnyObject) {
		self.toogleTypeSwitcherVisiblity(true)
	}
	
	// MARK: Navigation
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == Constants.Segue.EmbedContainerView),
			let _containerViewController = segue.destinationViewController as? BSCContainerViewController {
				self.contentViewController = _containerViewController
				self.contentViewController?.defaultSegueIdentifier = BSCPreferences.activeMusicLibraryType.embedSegueIdentfier
		}
	}
}
