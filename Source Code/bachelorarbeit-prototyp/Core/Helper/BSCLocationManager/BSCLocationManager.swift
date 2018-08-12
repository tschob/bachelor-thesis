//
//  BSCLocationManager.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 30.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import CoreLocation

class BSCLocationManager: NSObject {

	// MARK: - Private variables -
	
	private struct BSCLocationManagerConstants {
		static let TimeoutLength				= 2.0
	}
	
	static let sharedInstance					= BSCLocationManager()
	
	private let locationManager					= CLLocationManager()
	
	private var locationCompletionCallbacks		= Dictionary<String,[((location: CLLocation?) -> (Void))]>()

	private var timeoutTimer					: NSTimer?
	private var stopTimeoutTimer				= false

	// MARK: - Public methods
	
	// MARK: - Life cycle
	
	override init() {
		super.init()
		
		self.initLocationManager()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationWillTerminate:"), name: UIApplicationWillTerminateNotification, object: nil)
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	func applicationWillTerminate(notification: NSNotification) {
		BSCLog(Verbose.BSCLocationManager, "Stop  monitoring significant location changes.")
	}
	
	// MARK: - Current Location
	
	class func currentLocation(sender: AnyObject, completion: (location: CLLocation?) -> Void) {
		self.sharedInstance.currentLocation(sender, completion: completion)
	}
	
	class func placemarkFromLocation(location: CLLocation, completion: (placemark: CLPlacemark?) -> Void) {
		self.sharedInstance.placemarkFromLocation(location, completion: completion)
	}
	
	// MARK: - Private methods
	
	// MARK: - Initializaiton
	
	private func initLocationManager() {
		self.locationManager.delegate = self
		self.locationManager.stopMonitoringSignificantLocationChanges()
	}
	
	// MARK: Current Location
	
	private func currentLocation(sender: AnyObject, completion: (location: CLLocation?) -> Void) {
		self.addLocationCompletionCallback(sender, callback: completion)
		if (self.locationManager.location?.timestamp.timeIntervalSinceNow > -30) {
			// As the last known location is new enough we can return it directly without asking for a newer one.
			self.useLastLocaleAsCurrentLocation()
		} else {
			// The last known location is too old, let's get a new one.
			if (CLLocationManager.locationServicesEnabled() == true) {
				// As it's possible that the location service is enabled, but the authorization wasn't requested yet -> request it every time. 
				// This happend after a fresh install during the developmet of this app.
				self.locationManager.requestAlwaysAuthorization()
				// Start the location listening
				BSCLog(Verbose.BSCLocationManager, "Last known location is too old \(self.locationManager.location?.timestamp.timeIntervalSinceNow). Starting location change monitoring.")
				self.locationManager.stopMonitoringSignificantLocationChanges()
			} else {
				// Location services are disabled -> ask for autorization
				BSCLog(Verbose.BSCLocationManager, "Not authorized. Asking user for authorization.")
				self.locationManager.requestAlwaysAuthorization()
			}
			self.startTimeoutTimer()
		}
	}
	
	private func useLastLocaleAsCurrentLocation() {
		BSCLog(Verbose.BSCLocationManager, "Using last known location (\(self.locationManager.location?.timestamp.timeIntervalSinceNow)) as current one: \(self.locationManager.location)")
		self.callLocationCompletionCallbacks(self.locationManager.location)
	}
	
	private func placemarkFromLocation(location: CLLocation, completion: (placemark: CLPlacemark?) -> Void) {
		CLGeocoder().reverseGeocodeLocation(location) { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
			completion(placemark: placemarks?.last)
		}
	}
	
	// MARK: - Location completion callback
	
	func addLocationCompletionCallback(sender: AnyObject, callback: (location: CLLocation?) -> Void) {
		BSCLog(Verbose.BSCLocationManager, "Adding callback for \(sender)")
		let uid = "\(unsafeAddressOf(sender))"
		if var _callbacks = self.locationCompletionCallbacks[uid] {
			_callbacks.append(callback)
		} else {
			self.locationCompletionCallbacks[uid] = [callback]
		}
	}
	
	func removeLocationCompletionCallback(sender: AnyObject) {
		BSCLog(Verbose.BSCLocationManager, "Removing callbacks for \(sender)")
		let uid = "\(unsafeAddressOf(sender))"
		self.locationCompletionCallbacks.removeValueForKey(uid)
	}
	
	private func callLocationCompletionCallbacks(location: CLLocation?) {
		var calledCompletionCallbacks = [String]()
		for sender in self.locationCompletionCallbacks.keys {
			if let _callbacks = self.locationCompletionCallbacks[sender] {
				for callback in _callbacks {
					BSCLog(Verbose.BSCLocationManager, "Perform location completion callback for \(sender) with location: \(location)")
					callback(location: location)
				}
			}
			calledCompletionCallbacks.append(sender)
		}
		for key in calledCompletionCallbacks {
			BSCLog(Verbose.BSCLocationManager, "Remove location completion callbacks for sender (\(key)) as it has been called")
			self.locationCompletionCallbacks.removeValueForKey(key)
		}
	}
	
	private func cancelLocationCompletionCallbacks() {
		BSCLog(Verbose.BSCLocationManager, "canceling location completion callbacks")
		self.callLocationCompletionCallbacks(nil)
	}
	
	// MARK: - Helper
	
	private func startTimeoutTimer() {
		BSCLog(Verbose.BSCLocationManager, "Staring Timeout timer.")

		self.stopTimeoutTimer = false
		self.performBlockInMainThread({
			self.timeoutTimer =  NSTimer.scheduledTimerWithTimeInterval(BSCLocationManagerConstants.TimeoutLength, target: self, selector: "timeout", userInfo: nil, repeats: false)
		})
	}
	
	func timeout() {
		BSCLog(Verbose.BSCLocationManager, "Timeout is reached.")
		
		self.useLastLocaleAsCurrentLocation()
	}
}

// MARK: - CLLocationManagerDelegate

extension BSCLocationManager: CLLocationManagerDelegate {

	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		BSCLog(Verbose.BSCLocationManager, "status: \(status.rawValue)")
		if (status == .Denied) {
			self.cancelLocationCompletionCallbacks()
		}
	}
	
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		BSCLog(Verbose.BSCLocationManager, "locations \(locations)")
		self.locationManager.stopMonitoringSignificantLocationChanges()
		if (locations.count == 0) {
			BSCLog(Verbose.BSCLocationManager, "Warning: CLLocationManager did return zero locations")
		}
		self.callLocationCompletionCallbacks(locations.last)
	}
}