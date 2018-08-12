//
//  BSCPlayerViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 13.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import MediaPlayer

class BSCPlayerViewController: UIViewController {

	@IBOutlet weak var coverImageView					: UIImageView!
	@IBOutlet weak var backgroundImageView				: UIImageView!
	
	weak var songTimeSlider								: BSCSongTimeSlider?
	@IBOutlet weak var songTimeSliderContainerView		: UIView!
	@IBOutlet weak var progressSliderMinLabel			: UILabel!
	@IBOutlet weak var progressSliderMaxLabel			: UILabel!
	
	@IBOutlet weak var songTitleLabel					: MarqueeLabel!
	@IBOutlet weak var artistAlbumTitleLabel			: MarqueeLabel!
	
	@IBOutlet weak var loopButton						: UIButton!
	@IBOutlet weak var rewindButton						: UIButton!
	@IBOutlet weak var playButton						: UIButton!
	@IBOutlet weak var pauseButton						: UIButton!
	@IBOutlet weak var forwardButton					: UIButton!
	@IBOutlet weak var shuffleButton					: UIButton!

	@IBOutlet weak var volumeView						: MPVolumeView!
	
	// MARK: - View lifecycle

	override func viewDidLoad() {
        super.viewDidLoad()

		self.initSongTimeSlider()
		self.initVolumeView()
		self.initPlayStateChangeCallback()
		self.initPlaybackTimeChangeCallback()
		
		if let _currentMusicPlayerItem = BSCMusicPlayer.sharedInstance.currentMusicPlayerItem() {
			self.updateSongMetaData(_currentMusicPlayerItem)
		}
    }
	
	// MARK: - Initialization
	
	private func initSongTimeSlider() {
		if let _songTimeSlider = BSCSongTimeSlider.loadFromNib() {
			_songTimeSlider.frame = self.songTimeSliderContainerView.bounds
			_songTimeSlider.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
			self.songTimeSliderContainerView.addSubview(_songTimeSlider)
			self.songTimeSlider = _songTimeSlider
		}
	}
	
	private func initVolumeView() {
		self.volumeView.setRouteButtonImage(UIImage(named: "ic_airplay"), forState: .Normal)
		for view in self.volumeView.subviews {
			if let _view = view as? UISlider {
				_view.setThumbImage(UIImage(named: "slider_thumb"), forState: .Normal)
			}
		}
	}
	
	private func initPlayStateChangeCallback() {
		BSCMusicPlayer.sharedInstance.addPlayStateChangeCallback(self, callback: { (musicPlayerItem: BSCMusicPlayerItem?) -> Void in
			self.updateSongTimeSlider(musicPlayerItem)
			self.updateSongMetaData(musicPlayerItem)
			self.updateSongControlButtons()
		})
	}
	
	private func initPlaybackTimeChangeCallback() {
		BSCMusicPlayer.sharedInstance.addPlaybackTimeChangeCallback(self, callback: { (musicPlayerItem: BSCMusicPlayerItem) -> Void in
			self.updateSongTimeSlider(musicPlayerItem)
			// Update the controll buttons as the forward and rewind state might have to change
			self.updateSongControlButtons()
		})
	}
	
	// MARK: - Layout
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
	
	// MARK: - LNPopupController customization
	
	override func viewForPopupInteractionGestureRecognizer() -> UIView {
		return self.coverImageView
	}

	// MARK: - IBActions
	
	@IBAction private func didPressLoopButton(sender: AnyObject) {
		
	}
	
	@IBAction private func didPressRewindButton(sender: AnyObject) {
		BSCMusicPlayer.sharedInstance.rewind()
	}
	
	@IBAction private func didPressPlayButton(sender: AnyObject) {
		BSCMusicPlayer.sharedInstance.play()
	}
	
	@IBAction private func didPressPauseButton(sender: AnyObject) {
		BSCMusicPlayer.sharedInstance.pause()
	}
	
	@IBAction private func didPressForwardButton(sender: AnyObject) {
		BSCMusicPlayer.sharedInstance.forward()
	}
	
	@IBAction private func didPressShuffleButton(sender: AnyObject) {
		
	}
	
	// MARK: - Helper
	
	private func updateSongTimeSlider(musicPlayerItem: BSCMusicPlayerItem?) {
		self.songTimeSlider?.minimumValue = 0
		self.songTimeSlider?.maximumValue = musicPlayerItem?.durationInSeconds() ?? 0
		self.songTimeSlider?.value = musicPlayerItem?.currentTimeInSeconds() ?? 0
		// St
		self.progressSliderMinLabel.text = musicPlayerItem?.displayableCurrentTimeString() ?? "0:00"
		self.progressSliderMaxLabel.text = musicPlayerItem?.displayableTimeLeftString() ?? "-0:00"
	}
	
	private func updateSongMetaData(musicPlayerItem: BSCMusicPlayerItem?) {
		self.coverImageView.image = musicPlayerItem?.mediaItem?.artwork?.imageWithSize(self.coverImageView.frameSize)
		self.backgroundImageView.image = self.coverImageView.image
		self.songTitleLabel.text = musicPlayerItem?.mediaItem?.title ?? "-"
		self.artistAlbumTitleLabel.text = musicPlayerItem?.mediaItem?.artistAlbumDescription() ?? "-"
	}
	
	private func updateSongControlButtons() {
		if (BSCMusicPlayer.sharedInstance.isPlaying() == true) {
			self.playButton.hidden = true
			self.pauseButton.hidden = false
		} else {
			self.playButton.hidden = false
			self.pauseButton.hidden = true
		}
		self.rewindButton.enabled = BSCMusicPlayer.sharedInstance.canRewind()
		self.forwardButton.enabled = BSCMusicPlayer.sharedInstance.canForward()
	}
}
