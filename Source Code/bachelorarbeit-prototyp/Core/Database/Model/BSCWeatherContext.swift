//
//  BSCWeatherContext.swift
//  
//
//  Created by Hans Seiffert on 11.01.16.
//
//

import Foundation
import CoreData

@objc(BSCWeatherContext)
class BSCWeatherContext: NSManagedObject {

	// MARK: - Key
	
	struct Key {
		static let DayMaxTemperature		= "dayMaxTemperature"
		static let DayMinTemperature		= "dayMinTemperature"
		static let Visibility				= "visibility"
		static let IsDaylight				= "isDaylight"
		static let Humidity					= "humidity"
		static let Temperature				= "temperature"
		static let WindSpeed				= "windSpeed"
		static let YWeatherConditions		= "yWeatherConditions"
		static let YWeatherConditionCodes	= "yWeatherConditionCodes"
	}
	
	// MARK: - Set
	
	func addCurrentWeatherCondition(yahooWeatherResultDict: [NSObject: AnyObject]) {
		self.visibility = GET_NUMBER(yahooWeatherResultDict, kYWAVisibilityInKM)
		self.isDaylight = self.isDaylight(yahooWeatherResultDict)
		self.humidity = GET_NUMBER(yahooWeatherResultDict, kYWAHumidity)
		self.temperature = GET_NUMBER(yahooWeatherResultDict, kYWATemperatureInC)
		self.windSpeed = GET_NUMBER(yahooWeatherResultDict, kYWAWindSpeedInKMPH)
		if let _yWeatherCondition = GET_STRING(yahooWeatherResultDict, kYWACondition) {
			if (self.yWeatherConditions == nil) {
				self.yWeatherConditions = []
			}
			self.yWeatherConditions?.append(_yWeatherCondition)
		}
		if let _yWeatherConditionCode = GET_NUMBER(yahooWeatherResultDict, kYWAConditionNumber) {
			if (self.yWeatherConditionCodes == nil) {
				self.yWeatherConditionCodes = []
			}
			self.yWeatherConditionCodes?.append(_yWeatherConditionCode)
		}
	}
	
	func addTodaysForcast(yahooWeatherResultDict: [NSObject: AnyObject]) {
		self.dayMaxTemperature = GET_NUMBER(yahooWeatherResultDict, kYWAHighTemperatureForDay)
		self.dayMinTemperature = GET_NUMBER(yahooWeatherResultDict, kYWALowTemperatureForDay)
	}
	
	// MARK: - Set (Collection)
	
	func resetValues() {
		self.dayMinTemperature = nil
		self.dayMaxTemperature = nil
		self.visibility = nil
		self.isDaylight = nil
		self.humidity = nil
		self.temperature = nil
		self.windSpeed = nil
		self.yWeatherConditions = nil
		self.yWeatherConditionCodes = nil
	}
	
	
	func initArrays() {
		self.yWeatherConditions = []
		self.yWeatherConditionCodes = []
	}
	
	func addWeatherContexts(weatherContexts: [BSCWeatherContext]) {
		// Reset and prepare variables
		self.resetValues()
		self.initArrays()

		if (weatherContexts.count > 0) {
			for weatherContext in weatherContexts {
				// Add all values together
				self.dayMaxTemperature = self.dayMaxTemperature + weatherContext.dayMaxTemperature
				self.dayMinTemperature = self.dayMinTemperature + weatherContext.dayMinTemperature
				self.visibility = self.visibility + weatherContext.visibility
				self.isDaylight = self.isDaylight + weatherContext.isDaylight
				self.humidity = self.humidity + weatherContext.humidity
				self.temperature = self.temperature + weatherContext.temperature
				self.windSpeed = self.windSpeed + weatherContext.windSpeed
				if let _yWeatherCondition = weatherContext.yWeatherConditions?.first {
					self.yWeatherConditions?.append(_yWeatherCondition)
				}
				if let _yWeatherConditionCode = weatherContext.yWeatherConditionCodes?.first {
					self.yWeatherConditionCodes?.append(_yWeatherConditionCode)
				}
			}
			// Calculate the average
			let nubmerOfContextes = NSNumber(integer: weatherContexts.count)
			self.dayMaxTemperature = self.dayMaxTemperature / nubmerOfContextes
			self.dayMinTemperature = self.dayMinTemperature / nubmerOfContextes
			self.visibility = self.visibility / nubmerOfContextes
			self.isDaylight = self.isDaylight / nubmerOfContextes
			self.humidity = self.humidity / nubmerOfContextes
			self.temperature = self.temperature / nubmerOfContextes
			self.windSpeed = self.windSpeed / nubmerOfContextes
		}
	}
	
	// MARK: - Displayable Strings
	
	// MARK: - Displayable Strings
	
	func displayableDayMaxTemperatureString() -> String? {
		return BSCHelper.displayableString(number: self.dayMaxTemperature, decimalPlaces: 0, symbol: L("symbol.degrees"))
	}
	
	func displayableDayMinTemperatureString() -> String? {
		return BSCHelper.displayableString(number: self.dayMinTemperature, decimalPlaces: 0, symbol: L("symbol.degrees"))
	}
	
	func displayableVisibilityString() -> String? {
		return BSCHelper.displayableString(number: self.visibility, decimalPlaces: 2, symbol: L("symbol.km"))
	}
	
	func displayableIsDaylightString() -> String? {
		if let _isDayLight = self.isDaylight {
			return BSCHelper.displayableString(bool: Bool(_isDayLight))
		}
		return BSCHelper.displayableString(bool: nil)
	}
	
	func displayableHumidityString() -> String? {
		return BSCHelper.displayableString(number: self.humidity, decimalPlaces: 1, symbol: L("%"))
	}
	
	func displayableTemperatureString() -> String? {
		return BSCHelper.displayableString(number: self.temperature, decimalPlaces: 0, symbol: L("symbol.degrees"))
	}
	
	func displayableWindSpeedString() -> String? {
		return BSCHelper.displayableString(number: self.windSpeed, decimalPlaces: 1, symbol: L("symbol.speed"))
	}
	
	func displayableConditionsString() -> String? {
		return BSCHelper.displayableString(strings: self.yWeatherConditions)
	}
	
	// MARK: - Helper
	
	private func isDaylight(conditionsDict: [NSObject: AnyObject]) -> Bool {
		let currentDatecomponents = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate:  NSDate())
		if let
			_sunrise = conditionsDict[kYWASunriseInLocalTime] as? NSDateComponents,
			_sunset = conditionsDict[kYWASunsetInLocalTime] as? NSDateComponents {
				if (currentDatecomponents.hour >= _sunrise.hour
					&& ((currentDatecomponents.hour == _sunrise.hour && currentDatecomponents.minute >= _sunrise.minute)
						|| (currentDatecomponents.hour > _sunrise.hour))
					&& ((currentDatecomponents.hour == _sunset.hour && currentDatecomponents.minute <= _sunset.minute)
						|| (currentDatecomponents.hour < _sunset.hour))) {
							return true
				} else {
					return false
				}
		} else {
			return false
		}
	}
}
