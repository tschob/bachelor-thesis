//
//  BSCWeatherManager.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 01.01.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import UIKit
import CoreLocation

class BSCWeatherManager: NSObject {

	// MARK: - Private variables -
	
	static let sharedInstance								= BSCWeatherManager()
	
	private var weatherContextCompletionCallbacks		= Dictionary<String,[((weatherContext: BSCWeatherContext?) -> (Void))]>()
	
	private var currentWeatherConditionsResult				: [NSObject: AnyObject]?
	private var todaysWeatherForecastResult					: [NSObject: AnyObject]?

	// MARK: - Public methods
	
	// MARK: - Life cycle
	
	override init() {
		super.init()
		
		self.initYWeatherAPI()
	}
	
	// MARK: - Current weather context

	class func currentWeatherContext(sender: AnyObject, completion: (weatherContext: BSCWeatherContext?) -> Void) {
		self.sharedInstance.currentWeatherContext(sender, completion: completion)
	}
	
	// MARK: - Private methods

	// MARK: - Initializaiton
	
	private func initYWeatherAPI() {
		YWeatherAPI.sharedManager().cacheEnabled = false
		YWeatherAPI.sharedManager().defaultDistanceUnit = KM
		YWeatherAPI.sharedManager().defaultSpeedUnit = KMPH
		YWeatherAPI.sharedManager().defaultTemperatureUnit = C
	}
	
	// MARK: - CleanUp
	
	private func cleanUp() {
		self.currentWeatherConditionsResult = nil
		self.todaysWeatherForecastResult = nil
	}
	
	// MARK: - Current weather context
	
	private func currentWeatherContext(sender: AnyObject, completion: (weatherContext: BSCWeatherContext?) -> Void) {
		// Store the completion callback
		self.addWeatherContextCompletionCallback(sender, callback: completion)
		// Get the current location
		BSCLocationManager.currentLocation(self) { (location: CLLocation?) -> Void in
			if let _location = location {
				// Fetch the current weather conditions
				self.fetchCurrentWeatherConditions(_location, success: {
					// Fetch todays weather forecast
					self.fetchTodaysForecast(_location, success: {
						// Call the completion callback
						self.callWeatherContextCompletionCallbacks()
						}, failure: {
							self.cancelWeatherContextCompletionCallbacks()
						})
					}, failure: {
						self.cancelWeatherContextCompletionCallbacks()
				})
			} else {
				// Call the completion callback
				self.cancelWeatherContextCompletionCallbacks()
			}
		}
	}
	
	private func fetchCurrentWeatherConditions(location: CLLocation, success: () -> Void, failure: () -> Void) {
		// Fetch the current weather for the given location
		YWeatherAPI.sharedManager().allCurrentConditionsForCoordinate(location, success: { (result: [NSObject: AnyObject]!) -> Void in
			// Append the weather information from the result to the weather context
			self.currentWeatherConditionsResult = result
			// Call the success closure
			success()
			}, failure: { (response: AnyObject!, error: NSError!) -> Void in
				BSCLog(Verbose.BSCWeatherManager, "Error fetching current weather: \(error) response: \(response)")
				// Call failure closure
				failure()
		})
	}
	
	func fetchTodaysForecast(location: CLLocation, success: () -> Void, failure: () -> Void) {
		// Fetch todays weather forecasyt for the given location
		YWeatherAPI.sharedManager().todaysForecastForCoordinate(location, success: { (result: [NSObject: AnyObject]!) -> Void in
			// Append the weather information from the result to the weather context
			self.todaysWeatherForecastResult = result
			// Call the success closure
			success()
			}, failure: { (response: AnyObject!, error: NSError!) -> Void in
				BSCLog(Verbose.BSCWeatherManager, "Error fetching weather forecast: \(error) response: \(response)")
				// Call failure closure
				failure()
		})
	}
	
	// MARK: - Helper
	
	func currentWeatherContext() -> BSCWeatherContext {
		let weatherContext = BSCWeatherContext.unpersistedEntity()
		if let _currentWeatherConditionsResult = self.currentWeatherConditionsResult {
			weatherContext.addCurrentWeatherCondition(_currentWeatherConditionsResult)
		}
		if let _todaysWeatherForecastResult = self.todaysWeatherForecastResult {
			weatherContext.addTodaysForcast(_todaysWeatherForecastResult)
		}
		return weatherContext
	}
	
	// MARK: - Location completion callback
	
	private func addWeatherContextCompletionCallback(sender: AnyObject, callback: (weatherContext: BSCWeatherContext?) -> Void) {
		let uid = "\(unsafeAddressOf(sender))"
		if var _callbacks = self.weatherContextCompletionCallbacks[uid] {
			_callbacks.append(callback)
		} else {
			self.weatherContextCompletionCallbacks[uid] = [callback]
		}
	}
	
	func removeLocationCompletionCallback(sender: AnyObject) {
		let uid = "\(unsafeAddressOf(sender))"
		self.weatherContextCompletionCallbacks.removeValueForKey(uid)
	}
	
	private func callWeatherContextCompletionCallbacks() {
		var calledCompletionCallbacks = [String]()
		for sender in self.weatherContextCompletionCallbacks.keys {
			if let _callbacks = self.weatherContextCompletionCallbacks[sender] {
				for callback in _callbacks {
					BSCLog(Verbose.BSCWeatherManager, "Perform weather context completion callback for \(sender)")
					let weatherContext = self.currentWeatherContext()
					callback(weatherContext: weatherContext)
				}
			}
			calledCompletionCallbacks.append(sender)
		}
		for key in calledCompletionCallbacks {
			BSCLog(Verbose.BSCWeatherManager, "Remove weather context completion callbacks for sender (\(key)) as it has been called")
			self.weatherContextCompletionCallbacks.removeValueForKey(key)
		}
	}
	
	private func cancelWeatherContextCompletionCallbacks() {
		BSCLog(Verbose.BSCWeatherManager, "canceling weather context completion callbacks")
		self.callWeatherContextCompletionCallbacks()
	}
}
