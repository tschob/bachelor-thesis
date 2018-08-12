//
//  BSCAppDelegate.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 14.11.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

@UIApplicationMain
class BSCAppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	 // MARK: - Setup

	private func setupLoglevel() {
		BSCLogSettings.DetailedLog = true
	}
	
	private func setupDatabase() {
		if (Verbose.Database.Manager == true) {
			MagicalRecord.setLoggingLevel(.Debug)
		}
		MagicalRecord.setupCoreDataStack()
	}
	
	private func setupHockeyApp() {
		if let _hockeyID = NSBundle.entryInPListForKey(Constants.InfoPlistKeys.HockeyAppID) as? String {
			BITHockeyManager.sharedHockeyManager().configureWithIdentifier(_hockeyID)
			BITHockeyManager.sharedHockeyManager().crashManager.crashManagerStatus = BITCrashManagerStatus.AutoSend
			BITHockeyManager.sharedHockeyManager().startManager()
			BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()
		}
	}
	
	// MARK: Appeareance
	
	private func setupAppeareance() {
		UINavigationBar.appearanceWhenContainedInInstancesOfClasses([BSCNavigationControllerViewController.self]).setBackgroundImage(UIImage(), forBarMetrics: .Default)
		UINavigationBar.appearanceWhenContainedInInstancesOfClasses([BSCNavigationControllerViewController.self]).shadowImage = UIImage()
	}
	
	// MARK: - Application lifecylcle

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		
		self.setupLoglevel()
		self.setupDatabase()
		self.setupAppeareance()
		self.setupAudioSession()
		self.setupHockeyApp()
		
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		
		BSCPlaylogManager.cleanUp()
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		MagicalRecord.cleanUp()
	}
	
	// MARK: - Audio

	func setupAudioSession() {
		UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
		let _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
		let _ = try? AVAudioSession.sharedInstance().setActive(false)
	}
	
	// MARK: Remote control
	
	override func remoteControlReceivedWithEvent(event: UIEvent?) {
		switch event!.subtype {
		case UIEventSubtype.RemoteControlPlay:
			BSCMusicPlayer.sharedInstance.play()
		case UIEventSubtype.RemoteControlPause:
			BSCMusicPlayer.sharedInstance.pause()
		case UIEventSubtype.RemoteControlNextTrack:
			BSCMusicPlayer.sharedInstance.forward()
		case UIEventSubtype.RemoteControlPreviousTrack:
			BSCMusicPlayer.sharedInstance.rewind()
		case UIEventSubtype.RemoteControlTogglePlayPause:
			BSCMusicPlayer.sharedInstance.togglePlayPause()
		default:
			break
		}
	}
}

