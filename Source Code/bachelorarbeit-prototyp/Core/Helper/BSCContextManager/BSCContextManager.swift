//
//  BSCContextManager.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 29.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import AVFoundation

class BSCContextManager: NSObject {
	
	// MARK: - Current Context
	
	class func currentSongContext(sender: AnyObject, update: ((songContext: BSCSongContext) -> Void)?, completion: ((songContext: BSCSongContext) -> Void)?) {
		// Create song context object
		let songContext = BSCSongContext.unpersistedEntity()
		self.currentContext(songContext, sender: sender, update: { (context) -> Void in
			if let _songContext = context as? BSCSongContext {
				update?(songContext: _songContext)
			}
		}) { (context) -> Void in
			if let _songContext = context as? BSCSongContext {
				completion?(songContext: _songContext)
			}
		}
	}
	
	class func currentContext(sender: AnyObject, update: ((context: BSCContext) -> Void)?, completion: ((context: BSCContext) -> Void)?) {
		// Create single context object
		let context = BSCContext.unpersistedEntity()
		self.currentContext(context, sender: sender, update: update, completion: completion)
	}
	
	private class func currentContext(context: BSCContext, sender: AnyObject, update: ((context: BSCContext) -> Void)?, completion: ((context: BSCContext) -> Void)?) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
			// Create a gcd group to get notified if every part is ready
			let creationGroup = dispatch_group_create()
			// Add the device context features
			self.addDeviceValues(context)
			self.callUpdateCallback(context, update: update)
			// Get the current motion activity context and add it to the current context
			dispatch_group_enter(creationGroup)
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
				self.appendCurrentMotionContext(sender, context: context, update: { (context) -> Void in
					update?(context: context)
					BSCLog(Verbose.BSCContextManager, "completed the creation of the motion context")
					dispatch_group_leave(creationGroup)
				})
			}
			// Get the current location and add it to the current context
			dispatch_group_enter(creationGroup)
			dispatch_group_async(creationGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
				self.appendCurrentLocationCoordinates(sender, context: context, update: { (context) -> Void in
					BSCLog(Verbose.BSCContextManager, "completed the creation of the location")
					dispatch_group_leave(creationGroup)
				})
			}
			// Get the current weather context and add it to the current context
			dispatch_group_enter(creationGroup)
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
				self.appendCurrentWeatherContext(sender, context: context, update: { (context) -> Void in
					update?(context: context)
					BSCLog(Verbose.BSCContextManager, "completed the creation of the weather context")
					dispatch_group_leave(creationGroup)
				})
			}
			// Call the completion callback if every context features are retrieved
			dispatch_group_notify(creationGroup, dispatch_get_main_queue()) {
				BSCLog(Verbose.BSCContextManager, "completed the creation of all contexts and values")
				self.callCompletionClallback(context, completion: completion)
			}
		}
	}
	
	class func removeCallback(sender: AnyObject) {
		BSCMotionActivityManager.sharedInstance.removeMotionActivityCompletionCallback(sender)
		BSCLocationManager.sharedInstance.removeLocationCompletionCallback(sender)
		BSCWeatherManager.sharedInstance.removeLocationCompletionCallback(sender)
	}
	
	// MARK: - Private
	
	// MARK: - Helper
	
	private class func callUpdateCallback(context: BSCContext, update: ((context: BSCContext) -> Void)?) {
		if let _update = update {
			_update(context: context)
		}
	}
	
	private class func callCompletionClallback(context: BSCContext, completion: ((context: BSCContext) -> Void)?) {
		if let _completion = completion {
			_completion(context: context)
		}
	}
	
	private class func appendCurrentWeatherContext(sender: AnyObject, context: BSCContext, update: ((context: BSCContext) -> Void)?) {
		BSCWeatherManager.currentWeatherContext(sender, completion: { (weatherContext) -> Void in
			self.performBlockInMainThread({
				if let _weatherContext = weatherContext {
					context.addWeatherContext(_weatherContext)
				}
				self.callUpdateCallback(context, update: update)
			})
		})
	}
	
	private class func appendCurrentMotionContext(sender: AnyObject, context: BSCContext, update: ((context: BSCContext) -> Void)?) {
		BSCMotionActivityManager.currentMotionContext(sender, completion: { (motionContext) -> (Void) in
			self.performBlockInMainThread({
				if let _motionContext = motionContext {
					context.addMotionContext(_motionContext)
				}
				self.callUpdateCallback(context, update: update)

			})
		})
	}
	
	private class func appendCurrentLocationCoordinates(sender: AnyObject, context: BSCContext, update: ((context: BSCContext) -> Void)?) {
		BSCLocationManager.currentLocation(sender) { (location) -> Void in
			let locationCoordinates = BSCLocationCoordinates.unpersistedEntity()
			locationCoordinates.latitude = location?.coordinate.latitude
			locationCoordinates.longitude = location?.coordinate.longitude
			locationCoordinates.accuracy = location?.horizontalAccuracy
			self.performBlockInMainThread({
				context.addLocationCoordinates(locationCoordinates)
				// Fetch the country name of the current locaiton
				if let _location = location {
					BSCLocationManager.placemarkFromLocation(_location, completion: { (placemark) -> Void in
						if let _ISOCountryCode = placemark?.ISOcountryCode {
							context.countries = [_ISOCountryCode]
						}
						self.callUpdateCallback(context, update: update)
					})
				} else {
					self.callUpdateCallback(context, update: update)
				}
			})
		}
	}
	
	private class func addDeviceValues(context: BSCContext) -> BSCContext {
		// Get current date
		context.startDate = NSDate()
		context.endDate = context.startDate
		// Get current audio session output type
		if let _avAudioSessionOutputPort = AVAudioSession.sharedInstance().currentRoute.outputs.first?.portType {
			context.avAudioSessionOutputPorts = [_avAudioSessionOutputPort]
		}
		// Get current voume level
		context.volume = NSNumber(float: AVAudioSession.sharedInstance().outputVolume)
		// Get current screen brightness
		context.screenBrightness = NSNumber(float: Float(UIScreen.mainScreen().brightness))
		// Get current applications state
		context.applicationIsInForeground = (UIApplication.sharedApplication().applicationState == UIApplicationState.Active)
		// Get current device locked state
		context.deviceIsLocked = (UIDevice.currentDevice().passcodeStatus != LNPasscodeStatus.Enabled)
		// Get network reachability type
		context.reachableViaWWAN = (Reachability.reachabilityForInternetConnection().currentReachabilityStatus() == .ReachableViaWWAN)
		// Get current wifi SSDI
		if let _wifiSSID = BSCWifiHelper.currentWifiSSID() {
			context.wifiSSIDs = [_wifiSSID]
		}
		return context
	}
}
