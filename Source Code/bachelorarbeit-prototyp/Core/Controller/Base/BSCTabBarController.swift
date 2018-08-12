//
//  BSCTabBarController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 13.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import MediaPlayer

class BSCTabBarController: UITabBarController {

	private var playerViewController			: BSCPlayerViewController?
	private var isPlayerViewControllerVisible	= false
	
	// MARK: View lifecylce
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.initTabBar()
		self.initPlayerPopup()
	}
	
	// MARK: - Initialization
	
	private func initTabBar() {
		if (BSCHelper.showDebugFeatures() == false) {
			if var tabs = self.viewControllers {
				tabs.removeLast()
				self.setViewControllers(tabs, animated: false)
			}
		}
	}
	
	
	// MARK: Player popup
	
	private func initPlayerPopup() {
		self.playerViewController = UIStoryboard.instantiatedPlayerViewController()

		self.updatePlayerPopupBar(BSCMusicPlayer.sharedInstance.currentMusicPlayerItem()?.mediaItem)
		self.updatePlayerPopupBarVisibility()
		
		// Add player state and time callbacks
		BSCMusicPlayer.sharedInstance.addPlayStateChangeCallback(self, callback: { [weak self] (item) -> Void in
			self?.updatePlayerPopupBar(item?.mediaItem)
			self?.updatePlayerPopupBarVisibility()
		})
		BSCMusicPlayer.sharedInstance.addPlaybackTimeChangeCallback(self, callback: { [weak self] (musicPlayerItem: BSCMusicPlayerItem) -> Void in
			self?.updatePlayerPopupBarProgress(musicPlayerItem.currentProgress())
		})
	}
	
	func updatePlayerPopupBar(mediaItem: MPMediaItem?) {
		if let _playerViewController = self.playerViewController {
			var leftButtonItem = UIBarButtonItem()
			if (BSCMusicPlayer.sharedInstance.isPlaying() == true) {
				leftButtonItem = UIBarButtonItem(image: UIImage(named: "ic_pause_small"), style: .Plain, target: BSCMusicPlayer.sharedInstance, action: Selector("pause"))
			} else {
				leftButtonItem = UIBarButtonItem(image: UIImage(named: "ic_play"), style: .Plain, target: BSCMusicPlayer.sharedInstance, action: Selector("play"))
			}
			leftButtonItem.tintColor = UIColor.blackColor()
			let rightButtonItem = UIBarButtonItem(image: UIImage(named: "ic_forward"), style: .Plain, target: BSCMusicPlayer.sharedInstance, action: Selector("forward"))
			rightButtonItem.enabled = BSCMusicPlayer.sharedInstance.canForward()
			rightButtonItem.tintColor = UIColor.blackColor()

			_playerViewController.popupItem.leftBarButtonItems = [leftButtonItem]
			_playerViewController.popupItem.rightBarButtonItems = [rightButtonItem]
			_playerViewController.popupItem.title = mediaItem?.title ?? ""
			_playerViewController.popupItem.subtitle = mediaItem?.artistAlbumDescription()
		}
	}
	
	func updatePlayerPopupBarProgress(progress: Float) {
		if let _playerViewController = self.playerViewController {
			_playerViewController.popupItem.progress = progress
			if let _rightBarButton = _playerViewController.popupItem.rightBarButtonItems?.first {
				_rightBarButton.enabled = BSCMusicPlayer.sharedInstance.canForward()
			}
		}
	}
	
	func updatePlayerPopupBarVisibility() {
		if let _playerViewController = self.playerViewController {
			if (BSCMusicPlayer.sharedInstance.canPlay() == true && self.isPlayerViewControllerVisible == false) {
				// The music player can play a current song and the popover isn't visible yet -> show it
				self.isPlayerViewControllerVisible = true
				self.presentPopupBarWithContentViewController(_playerViewController, animated: true, completion: nil)
			} else if (BSCMusicPlayer.sharedInstance.canPlay() == false && self.isPlayerViewControllerVisible == true) {
				// The music player can't play a current song and the popover is still visible -> hide it
				self.isPlayerViewControllerVisible = false
				self.dismissPopupBarAnimated(true, completion: nil)
			}
		}
	}

}
