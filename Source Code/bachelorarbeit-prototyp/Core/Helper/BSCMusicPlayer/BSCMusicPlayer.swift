//
//  BSCMusicPlayer.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 12/12/15.
//  Copyright (c) 2015 Hans Seiffert. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

class BSCMusicPlayer: NSObject {
	
	struct BSCMusicPlayerConstants {
		struct NotificationKey {
			static let PlayerStateChanged			= "playerStateChanged"
			static let MediaItemStateChanged		= PlayerStateChanged + "_"
		}
	}
	
	static let PlayingTimeRefreshRate				= 0.1
	
	// MARK: - Public variables

	static let sharedInstance						= BSCMusicPlayer()
	
	// MARK: - Private variables

	private var player								: AVPlayer?

    private var queue								= BSCMusicPlayerQueue()
	var queueGeneration								= 0

	private var addedPlayerStateObserver			= false
	
	// MARK: Callbacks
	private var playStateChangeCallbacks			= Dictionary<String,[((musicPlayerItem: BSCMusicPlayerItem?) -> (Void))]>()
	private var playbackPositionChangeCallbacks		= Dictionary<String,[((musicPlayerItem: BSCMusicPlayerItem) -> (Void))]>()

	private var playbackPositionChangeTimer			: NSTimer?
	private var stopPlaybackTimeChangeTimer			= false
	
	// MARK: - Initializaiton
	
    override init() {
        super.init()
		
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("musicPlayerItemDidFinishPlaying"), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationDidEnterBackground:"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	func applicationDidEnterBackground(notification: NSNotification) {
		if (self.isPlaying() == false) {
			self.stop()
			BSCPlaylogManager.cleanUp()
		}
	}
    
    private func initPlayer() {
        
        if let _player = self.player {
            _player.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
            self.addedPlayerStateObserver = true
        }
        
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        if (self.player?.respondsToSelector(Selector("setVolume:")) == true) {
            self.player!.volume = 1.0
        }
        self.player?.allowsExternalPlayback = true
        self.player?.usesExternalPlaybackWhileExternalScreenIsActive = true
    }
	
	// MARK: - Control playback
	
	func togglePlayPause() {
		if self.isPlaying() == true {
			self.pause()
		} else {
			self.play()
		}
	}
	
	// MARK: Play
	
	func canPlay() -> Bool {
		return self.queue.count() > 0
	}
	
	func play() {
		if let _player = self.player {
			_player.play()
			self.callPlayStateChangeCallbacks()
			self.updateNowPlayingInfo()
			self.startPlaybackTimeChangeTimer()
			if let _persitentID = self.currentMusicPlayerItem()?.mediaItemPersitentID {
				NSNotificationCenter.defaultCenter().postNotificationName(self.dynamicType.playerStateChangedNotificationKey(_persitentID), object: nil)
			}
		}
	}
	
	
	
	private func restartCurrentItem() {
		BSCLog(Verbose.BSCMusicPLayer, "restartCurrentItem")
		if (self.player != nil) {
			if (self.addedPlayerStateObserver == true) {
				self.addedPlayerStateObserver = false
				self.player?.removeObserver(self, forKeyPath: "status", context: nil)
			}
			self.stop()
		}
		
		if
			let _currentMusicPlayerItem  = self.queue.currentPlayingItem() {
				self.player = AVPlayer()
				self.initPlayer()
				_currentMusicPlayerItem.loadResource()
				if let _url = _currentMusicPlayerItem.mediaItem?.assetURL {
					let avPlayerItem = AVPlayerItem(URL: _url)
					_currentMusicPlayerItem.prepareForPlaying(avPlayerItem)
					_currentMusicPlayerItem.willStartPlayback()
					self.player?.replaceCurrentItemWithPlayerItem(avPlayerItem)
				}
		}
	}
	
	func play(musicPlayerItem: BSCMusicPlayerItem) {
		BSCLog(Verbose.BSCMusicPLayer, "play(musicPlayerItem: \(musicPlayerItem))")
		self.stop()
		self.play([musicPlayerItem], startPosition: 0)
		self.queueGeneration += 1
	}
	
	func play(musicPlayerItems: [BSCMusicPlayerItem], startPosition: Int) {
		BSCLog(Verbose.BSCMusicPLayer, "play(musicPlayerItems: \(musicPlayerItems.count) items, startPosition: \(startPosition))")
		self.stop()
		var reducedPlayerItems = [] as [BSCMusicPlayerItem]
		for index in 0..<musicPlayerItems.count {
			let musicPlayerItem = musicPlayerItems[index]
				reducedPlayerItems.append(musicPlayerItem)
		}
		
		self.queue.replace(reducedPlayerItems, startPosition: startPosition)

		self.restartCurrentItem()
    }
	
	func append(musicPlayerItems: [BSCMusicPlayerItem], queueGeneration: Int) {
		if (self.queueGeneration == queueGeneration) {
			BSCLog(Verbose.BSCMusicPLayer, "Queue generation (\(queueGeneration)) gets appended with \(musicPlayerItems.count) itmes.")
			self.queue.append(musicPlayerItems)
		} else {
			BSCLog(Verbose.BSCMusicPLayer, "Queue generation (\(queueGeneration)) isn't the same as the current (\(self.queueGeneration)). Won't append \(musicPlayerItems.count) music player items.")
		}
	}
	
	// MARK: Pause
    
    func pause() {
		if let _player = self.player {
            _player.pause()
			self.callPlayStateChangeCallbacks()
			self.stopPlaybackTimeChangeTimer = true
			self.callPlaybackTimeChangeCallbacks()
			if let _persitentID = self.currentMusicPlayerItem()?.mediaItemPersitentID {
				NSNotificationCenter.defaultCenter().postNotificationName(self.dynamicType.playerStateChangedNotificationKey(_persitentID), object: nil)
			}
        }
    }
	
	private func stop() {
		self.currentMusicPlayerItem()?.didStopPlayback()
		self.pause()
		self.player?.seekToTime(CMTimeMake(0, 1))
	}
	
	// MARK: Forward
	
	func canForward() -> Bool {
		return self.queue.canForward()
	}
	
	func forward() {
		self.stop()
		if (self.queue.forward() == true) {
			self.restartCurrentItem()
		}
    }
	
	// MARK: Rewind
	
    func canRewind() -> Bool {
		if (self.currentMusicPlayerItem()?.currentTimeInSeconds() > Float(1) || self.canRewindInQueue()) {
			return true
		}
        return false
    }
	
	private func canRewindInQueue() -> Bool {
		return self.queue.canRewind()
	}
    
    func rewind() {
		if (self.currentMusicPlayerItem()?.currentTimeInSeconds() <= Float(1) && self.canRewindInQueue() == true) {
			self.stop()
			if (self.queue.rewind() == true) {
				self.restartCurrentItem()
			}
		} else {
			// Move to the beginning of the song if we aren't in the beginning.
			self.player?.seekToTime(CMTimeMake(0, 1))
			// Call the callbacks to inform about the new time
			self.callPlaybackTimeChangeCallbacks()
		}
    }
	
	func seekToTime(time: CMTime) {
		self.player?.seekToTime(time)
	}
	
	// MARK: - Internal helper
	
	private func updateNowPlayingInfo() {
		MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = self.currentMusicPlayerItem()?.nowPlayingInfo
	}
	
    func musicPlayerItemDidFinishPlaying() {
        self.forward()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if (object as? NSObject == player) && (keyPath == "status") {
            if self.player?.status == AVPlayerStatus.ReadyToPlay {
				self.play()
            }
        }
    }
	
	// MARK: - Playback time
	
	func addPlaybackTimeChangeCallback(sender: AnyObject, callback: (musicPlayerItem: BSCMusicPlayerItem) -> Void) {
		let uid = "\(unsafeAddressOf(sender))"
		if var _callbacks = self.playbackPositionChangeCallbacks[uid] {
			_callbacks.append(callback)
		} else {
			self.playbackPositionChangeCallbacks[uid] = [callback]
		}
	}
	
	func removePlaybackTimeChangeCallback(sender: AnyObject) {
		let uid = "\(unsafeAddressOf(sender))"
		self.playbackPositionChangeCallbacks.removeValueForKey(uid)
	}
	
	func callPlaybackTimeChangeCallbacks() {
		// Increase the current item playing time if the player is playing
		if let _currentMusicPlayerItem = self.currentMusicPlayerItem() {
			for sender in self.playbackPositionChangeCallbacks.keys {
				if let _callbacks = self.playbackPositionChangeCallbacks[sender] {
					for playbackPositionChangeClosure in _callbacks {
						playbackPositionChangeClosure(musicPlayerItem: _currentMusicPlayerItem)
					}
				}
			}
		}
		if (self.stopPlaybackTimeChangeTimer == true) {
			self.playbackPositionChangeTimer?.invalidate()
		}
	}
	
	private func startPlaybackTimeChangeTimer() {
		self.stopPlaybackTimeChangeTimer = false
		self.playbackPositionChangeTimer =  NSTimer.scheduledTimerWithTimeInterval(BSCMusicPlayer.PlayingTimeRefreshRate, target: self, selector: Selector("callPlaybackTimeChangeCallbacks"), userInfo: nil, repeats: true)
		self.playbackPositionChangeTimer?.fire()
	}
	
	// MARK: - Play state
	
	func addPlayStateChangeCallback(sender: AnyObject, callback: (musicPlayerItem: BSCMusicPlayerItem?) -> Void) {
		let uid = "\(unsafeAddressOf(sender))"
		if var _callbacks = self.playStateChangeCallbacks[uid] {
			_callbacks.append(callback)
		} else {
			self.playStateChangeCallbacks[uid] = [callback]
		}
	}
	
	func removePlayStateChangeCallback(sender: AnyObject) {
		let uid = "\(unsafeAddressOf(sender))"
		self.playbackPositionChangeCallbacks.removeValueForKey(uid)
	}
	
	func callPlayStateChangeCallbacks() {
		for sender in self.playStateChangeCallbacks.keys {
			if let _callbacks = self.playStateChangeCallbacks[sender] {
				for playStateChangeClosure in _callbacks {
					playStateChangeClosure(musicPlayerItem: self.currentMusicPlayerItem())
				}
			}
		}
	}
	
	func isPlaying() -> Bool {
		return self.player?.rate > 0
	}
	
	func currentMusicPlayerItem() -> BSCMusicPlayerItem? {
		return self.queue.currentPlayingItem()
	}
	
	class func playerStateChangedNotificationKey(persistentID: MPMediaEntityPersistentID) -> String {
		return "\(BSCMusicPlayer.BSCMusicPlayerConstants.NotificationKey.MediaItemStateChanged)\(persistentID)"
	}
}
