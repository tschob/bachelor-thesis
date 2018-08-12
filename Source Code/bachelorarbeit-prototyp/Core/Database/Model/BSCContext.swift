//
//  BSCContext.swift
//  
//
//  Created by Hans Seiffert on 29.12.15.
//
//

import Foundation
import CoreData
import CoreLocation

@objc(BSCContext)
class BSCContext: NSManagedObject {

	/**
	Use this variable if you want to store a distanceVector on the fly. Keep in mind that the context might be used in another place too. So eg. don't use this property for the BSCRecommendatoion creation!
	*/
	var distanceVector			: BSCContextComparisonHelper.DistanceVector?
	
	// MARK: - Keys
	
	struct Key {
		static let ApplicationIsInForeground		= "applicationIsInForeground"
		static let AvAudioSessionOutputPorts		= "avAudioSessionOutputPorts"
		static let Countries						= "countries"
		static let DeviceLocked						= "deviceLocked"
		static let EndDate							= "endDate"
		static let ScreenBrightness					= "screenBrightness"
		static let StartDate						= "startDate"
		static let Volume							= "volume"
		static let WifiSSIDs						= "wifiSSIDs"
		static let LocationCoordinates				= "locationCoordinates"
		static let MotionContext					= "motionContext"
	}
	
	// MARK: -
	
	func resetValues() {
		self.applicationIsInForeground = nil
		self.deviceIsLocked = nil
		self.screenBrightness = nil
		self.volume = nil
		self.avAudioSessionOutputPorts = nil
		self.countries = nil
		self.endDate = nil
		self.locationCoordinates = nil
		self.startDate = nil
		self.wifiSSIDs = nil
	}
	
	func initArrays() {
		self.avAudioSessionOutputPorts = [String]()
		self.countries = [String]()
		self.wifiSSIDs = [String]()
	}
	
	func resetWithContexts(allChildContexts: [BSCContext]) {
		// Reset and prepare variables
		self.resetValues()
		self.initArrays()
		
		var allWeatherContexts = [BSCWeatherContext]()
		var allMotionContexts = [BSCMotionContext]()
		
		if (allChildContexts.count > 0) {
			for childContext in allChildContexts {
				// Collect all motion and weather subcontexts.
				if let _weatherContext = childContext.weatherContext {
					allWeatherContexts.append(_weatherContext)
				}
				if let _motionContext = childContext.motionContext {
					allMotionContexts.append(_motionContext)
				}
				
				if let _avAudioSessionOutputPort = childContext.avAudioSessionOutputPorts?.first {
					self.avAudioSessionOutputPorts?.append(_avAudioSessionOutputPort)
				}
				if let _country = childContext.countries?.first {
					self.countries?.append(_country)
				}
				if let _wifiSSID = childContext.wifiSSIDs?.first {
					self.wifiSSIDs?.append(_wifiSSID)
				}
				if let _date = childContext.startDate {
					if let _startDate = self.startDate where _date.compare(_startDate) == .OrderedDescending {
						// The current startDate is older, keep it
						self.startDate = _startDate
					} else {
						// The current startDate is newer or nil, use the new date
						self.startDate = _date
					}
					if let _endDate = self.endDate where _date.compare(_endDate) == .OrderedAscending {
						// The current endDate is newer, keep it
						self.endDate = _endDate
					} else {
						// The current endDate is older or nil, use the new date
						self.endDate = _date
					}
				}
				self.applicationIsInForeground = NSNumber(float: ((childContext.applicationIsInForeground?.floatValue ?? 0) + (self.applicationIsInForeground?.floatValue ?? 0)))
				self.deviceIsLocked = NSNumber(float: ((childContext.deviceIsLocked?.floatValue ?? 0) + (self.deviceIsLocked?.floatValue ?? 0)))
				self.reachableViaWWAN = NSNumber(float: ((childContext.reachableViaWWAN?.floatValue ?? 0) + (self.reachableViaWWAN?.floatValue ?? 0)))
				self.screenBrightness = NSNumber(float: ((childContext.screenBrightness?.floatValue ?? 0) + (self.screenBrightness?.floatValue ?? 0)))
				self.volume = NSNumber(float: ((childContext.volume?.floatValue ?? 0) + (self.volume?.floatValue ?? 0)))
				
				if let locationCoordinates = (self.managedObjectContext != nil) ? BSCLocationCoordinates.MR_createEntityInContext(self.managedObjectContext!) : BSCLocationCoordinates.unpersistedEntity() {
					if let _locationCoordiantes = childContext.locationCoordinates?.allObjects as? [BSCLocationCoordinates] {
						locationCoordinates.longitude = _locationCoordiantes.first?.longitude
						locationCoordinates.latitude = _locationCoordiantes.first?.latitude
						locationCoordinates.accuracy = _locationCoordiantes.first?.accuracy
					}
					self.addLocationCoordinates(locationCoordinates)
				}
			}
			
			self.applicationIsInForeground = NSNumber(float: ((self.applicationIsInForeground?.floatValue ?? 0) / Float(allChildContexts.count)))
			self.deviceIsLocked = NSNumber(float: ((self.deviceIsLocked?.floatValue ?? 0) / Float(allChildContexts.count)))
			self.reachableViaWWAN = NSNumber(float: ((self.reachableViaWWAN?.floatValue ?? 0) / Float(allChildContexts.count)))
			self.screenBrightness = NSNumber(float: ((self.screenBrightness?.floatValue ?? 0) / Float(allChildContexts.count)))
			self.volume = NSNumber(float: ((self.volume?.floatValue ?? 0) / Float(allChildContexts.count)))
		}
		
		if let weatherContext = (self.managedObjectContext != nil) ? BSCWeatherContext.MR_createEntityInContext(self.managedObjectContext!) : BSCWeatherContext.unpersistedEntity() {
			weatherContext.addWeatherContexts(allWeatherContexts)
			self.addWeatherContext(weatherContext)
		}
		
		if let motionContext = (self.managedObjectContext != nil) ? BSCMotionContext.MR_createEntityInContext(self.managedObjectContext!) : BSCMotionContext.unpersistedEntity() {
			motionContext.resetWithMotionContexts(allMotionContexts)
			self.addMotionContext(motionContext)
		}
	}
	
	// MARK: - Context comparison
	
	func distanceVector(recommendationType: BSCRecommendation.RecommendationType, otherContext: BSCContext) -> BSCContextComparisonHelper.DistanceVector {
		return BSCContextComparisonHelper.distanceVector(recommendationType, contextA: self, contextB: otherContext)
	}
	
	// MARK: - Displayable Strings
	
	func displayableTitleString() -> String {
		var title = self.displayableSubtitleString()
		if let _label = self.label {
			title = "\(_label)"
		}
		return title
	}
	
	func displayableSubtitleString() -> String {
		var title = ""
		if let _startDate = self.startDate {
			title += NSString(fromDate: _startDate, format: "dd.MM.yy': 'eee', 'HH:mm") as String
			if let _endDate = self.endDate where _startDate != _endDate {
				title += NSString(fromDate: _endDate, format: "' - 'HH:mm") as String
			} else if (self.endDate == nil) {
				title += " - ..."
			}
		}
		return title
	}
	
	// MARK: Location

	func displayableLocationAccuraciesString() -> String {
		var accurayStrings = [String]()
		if let _locationCoordinates = self.locationCoordinates?.allObjects as? [BSCLocationCoordinates] {
			for locationCoordinate in _locationCoordinates {
				if let _accuracy = locationCoordinate.accuracy?.stringValue {
					accurayStrings.append(_accuracy)
				}
			}
		}
		return BSCHelper.displayableString(strings: accurayStrings)
	}
	
	// MARK: Date

	func displayableHoursString() -> String {
		var allStrings = [String]()
		for hour in self.hoursOfTheDays() {
			allStrings.append("\(hour)")
		}
		return BSCHelper.displayableString(strings: allStrings)
	}
	
	func displayableWeekdaysString() -> String {
		var allStrings = [String]()
		for weekday in self.daysOfTheWeek() {
			allStrings.append(L("word.weekday.\(weekday)"))
		}
		return BSCHelper.displayableString(strings: allStrings)	}
	
	func displayableMonthsString() -> String {
		var allStrings = [String]()
		for month in self.monthsOfTheYear() {
			allStrings.append(L("word.month.\(month)"))
		}
		return BSCHelper.displayableString(strings: allStrings)	}
	
	// MARK: Distance

	func displayableStringFromDistance(distance: Double?) -> String {
		return BSCHelper.displayableString(double: distance, decimalPlaces: 0, symbol: "m")
	}
	
	func displayableStringFromDistanceRange(startDistance: Double?, endDistance: Double?) -> String {
		return (BSCHelper.displayableString(double: startDistance, decimalPlaces: 0, symbol: nil) + " - " + BSCHelper.displayableString(double: endDistance, decimalPlaces: 0, symbol: "m"))
	}
	
	// MARK: - Date
	
	func hoursOfTheDays() -> [Int] {
		return self.allCyclicValues(self.startDate?.roundedHour(), endValue: self.endDate?.roundedHour(), feature: .HourOfDay)
	}
	
	func daysOfTheWeek() -> [Int] {
		return self.allCyclicValues(self.dayOfTheWeek(self.startDate), endValue: self.dayOfTheWeek(self.endDate), feature: .DayOfTheWeek)
	}
	
	func monthsOfTheYear() -> [Int] {
		return self.allCyclicValues(self.startDate?.month(), endValue: self.endDate?.month(), feature: .MonthOfTheYear)
	}
	
	func dayOfTheWeek(date: NSDate?) -> Int {
		if let _date = date {
			return NSString(fromDate: _date, format: "e").integerValue
		}
		return -1
	}
	
	// MARK: - Helper
	
	func allCyclicValues(startValue: Int?, endValue: Int?, feature: BSCContextFeature) -> [Int] {
		var allValues = [Int]()
		if let _startValue = startValue {
			// Add start hour
			allValues.append(_startValue)
			// Add every hour until the end hour is reached
			let cyclicMaxValue = Int(BSCContextFeature.HourOfDay.range(nil, contextB: nil).cyclicMaxValue ?? 0)
			if let _endValue = endValue where _endValue > _startValue {
				var value = _startValue
				while value != _endValue {
					if (value <  cyclicMaxValue) {
						// The cyclic max number isn't rechead, go to the next value
						value += 1
					} else {
						// The cyclic max number is reached, start with 0 again
						value = 0
					}
					// Add the hour
					allValues.append(value)
				}
			}
		}
		return allValues
	}
	
	// MARK: - Location Helper

	var locations: [CLLocation]? {
		if let _locationCoordinates = self.locationCoordinates?.allObjects as? [BSCLocationCoordinates] {
			var allLocations = [CLLocation]()
			for locationCoordinate in _locationCoordinates {
				if let
					_longitude = locationCoordinate.longitude,
					_latitude = locationCoordinate.latitude,
					_accuracy = locationCoordinate.accuracy {
						allLocations.append(CLLocation.init(coordinate: CLLocationCoordinate2DMake(_latitude.doubleValue, _longitude.doubleValue), altitude: 0, horizontalAccuracy: _accuracy.doubleValue, verticalAccuracy: 0, timestamp: NSDate()))
				}
			}
			return allLocations
		}
		return nil
	}
	
	
	func locationAccuracies() -> [Float] {
		var allValues = [Float]()
		if let _locationCoordinates = self.locationCoordinates?.allObjects as? [BSCLocationCoordinates] {
			for locationCoordinate in _locationCoordinates {
				if let _accuracy = locationCoordinate.accuracy {
					allValues.append(_accuracy.floatValue)
				}
			}
		}
		return allValues
	}
	
	// MARK: - Relationships -
	
	func addWeatherContext(weatherContext: BSCWeatherContext) {
		weatherContext.context = self
		self.weatherContext = weatherContext
	}
	
	func addLocationCoordinates(locationCoordinates: BSCLocationCoordinates) {
		let locationCoordinatesSet = self.mutableSetValueForKey(Key.LocationCoordinates)
		locationCoordinatesSet.addObject(locationCoordinates)
		self.locationCoordinates = locationCoordinatesSet
		locationCoordinates.context = self
	}
	
	
	func addMotionContext(motionContext: BSCMotionContext) {
		motionContext.context = self
		self.motionContext = motionContext
	}
}
