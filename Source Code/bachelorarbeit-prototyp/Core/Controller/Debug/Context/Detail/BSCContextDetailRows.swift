//
//  BSCContextDetailRows.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 12.01.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import UIKit

protocol BSCContextTableViewCellRowType {
	init?(rawValue: Int)
	static var numberOfRows: Int { get }
	var title: String? { get }
	func detailString(context: BSCContext) -> String?
	var heightForRow: CGFloat { get }
	func percentageFromTotalWeight() -> Float?
	static func percentageFromTotalWeight() -> Float?
	func feature() -> BSCContextFeature?
	func similarityString(feature: BSCContextFeature?, distanceVector: BSCContextComparisonHelper.DistanceVector) -> String?
}

extension BSCContextTableViewCellRowType {
	
	func similarityString(feature: BSCContextFeature?, distanceVector: BSCContextComparisonHelper.DistanceVector) -> String? {
		if let
			_feature = feature,
			_distance = distanceVector[_feature] {
				return (BSCHelper.displayableString(float: _feature.similarity(_distance.floatValue), decimalPlaces: 1, symbol: "%"))
		}
		return nil
	}
	
	func percentageFromTotalWeight() -> Float? {
		return self.feature()?.weight(.Complete)
	}
	
	var heightForRow: CGFloat {
		return UITableViewAutomaticDimension
	}
}

// MARK: - 	BSCContextTableViewLocationSectionRowType

enum BSCContextTableViewLocationSectionRowType: Int, BSCContextTableViewCellRowType {
	
	case LocationMap = 0
	case LocationDistance
	case LocationAccuracy
	case Country
	case WiFiSSID
	
	static var numberOfRows: Int {
		return self.allCases.count
	}
	
	static func percentageFromTotalWeight() -> Float? {
		var percentageFromTotalWeight = Float(0)
		for row in self.allCases {
			percentageFromTotalWeight += (row.percentageFromTotalWeight() ?? Float(0))
		}
		return percentageFromTotalWeight
	}
	
	var title: String? {
		switch self {
		case .LocationMap:				return nil
		case .LocationDistance:			return L("word.context.location")
		case .LocationAccuracy:			return L("word.context.location.accuracy")
		case .Country:					return L("word.context.Country")
		case .WiFiSSID:					return L("word.context.wifiSSID")
		}
	}
	
	func detailString(context: BSCContext) -> String? {
		switch self {
		case .LocationMap:				return nil
		case .LocationDistance:			return BSCHelper.displayableString(locations: context.locations, decimalPlaces: 4)
		case .LocationAccuracy:			return context.displayableLocationAccuraciesString()
		case .Country:					return BSCHelper.displayableString(strings: context.countries)
		case .WiFiSSID:					return BSCHelper.displayableString(strings: context.wifiSSIDs)
		}
	}
	
	func feature() -> BSCContextFeature? {
		switch self {
		case .LocationDistance:			return BSCContextFeature.LocationDistance
		case .LocationAccuracy:			return BSCContextFeature.Accuracy
		case .Country:					return BSCContextFeature.Country
		case .WiFiSSID:					return BSCContextFeature.WifiSSID
		default:						return nil
		}
	}
	
	var heightForRow: CGFloat {
		switch self {
		case .LocationMap:	return 160
		default:			return UITableViewAutomaticDimension
		}
	}
}

// MARK: - 	BSCContextTableViewDateSectionRowType

enum BSCContextTableViewDateSectionRowType: Int, BSCContextTableViewCellRowType {
	
	case Time = 0
	case Day
	case Month
	
	static var numberOfRows: Int {
		return self.allCases.count
	}
	
	static func percentageFromTotalWeight() -> Float? {
		var percentageFromTotalWeight = Float(0)
		for row in self.allCases {
			percentageFromTotalWeight += (row.percentageFromTotalWeight() ?? Float(0))
		}
		return percentageFromTotalWeight
	}
	
	var title: String? {
		switch self {
		case .Time:						return L("word.context.date.time")
		case .Day:						return L("word.context.date.weekDay")
		case .Month:					return L("word.context.date.month")
		}
	}
	
	func detailString(context: BSCContext) -> String? {
		switch self {
		case .Time:						return context.displayableHoursString()
		case .Day:						return context.displayableWeekdaysString()
		case .Month:					return context.displayableMonthsString()
		}
	}
	
	func feature() -> BSCContextFeature? {
		switch self {
		case .Time:						return BSCContextFeature.HourOfDay
		case .Day:						return BSCContextFeature.DayOfTheWeek
		case .Month:					return BSCContextFeature.MonthOfTheYear
		}
	}
}

// MARK: - 	BSCContextTableViewDeviceSectionRowType

enum BSCContextTableViewDeviceSectionRowType: Int, BSCContextTableViewCellRowType {
	
	case MusicOutputType = 0
	case ApplicationState
	case DeviceIsLocked
	case ReachableViaWWAN
	case ReachableViaWiFi
	case ScreenBrightness
	case Volume
	
	static var numberOfRows: Int {
		return self.allCases.count
	}
	
	static func percentageFromTotalWeight() -> Float? {
		var percentageFromTotalWeight = Float(0)
		for row in self.allCases {
			percentageFromTotalWeight += (row.percentageFromTotalWeight() ?? Float(0))
		}
		return percentageFromTotalWeight
	}
	
	var title: String? {
		switch self {
		case .MusicOutputType:			return L("word.context.musicOutputType")
		case .ApplicationState:			return L("word.context.applicationState")
		case .DeviceIsLocked:			return L("word.context.deviceLocked")
		case .ReachableViaWWAN:			return L("word.context.reachableViaWWAN")
		case .ReachableViaWiFi:			return L("word.context.reachableViaWIFI")
		case .ScreenBrightness:			return L("word.context.screenBrightness")
		case .Volume:					return L("word.context.volume")
		}
	}
	
	func detailString(context: BSCContext) -> String? {
		switch self {
		case .ApplicationState:			return BSCHelper.displayableString(bool: context.applicationIsInForeground?.boolValue)
		case .DeviceIsLocked:			return BSCHelper.displayableString(bool: context.deviceIsLocked?.boolValue)
		case .ScreenBrightness:			return context.screenBrightness?.stringValue
		case .Volume:					return context.volume?.stringValue
		case .MusicOutputType:			return BSCHelper.displayableString(strings: context.avAudioSessionOutputPorts)
		case .ReachableViaWWAN:			return BSCHelper.displayableString(bool: context.reachableViaWWAN?.boolValue)
		case .ReachableViaWiFi:			return BSCHelper.displayableString(bool: context.wifiSSIDs == nil || context.wifiSSIDs!.count == 0)
		}
	}
	
	func feature() -> BSCContextFeature? {
		switch self {
		case .ApplicationState:			return BSCContextFeature.ApplicationIsInForeground
		case .DeviceIsLocked:			return BSCContextFeature.DeviceLocked
		case .ScreenBrightness:			return BSCContextFeature.ScreenBrightness
		case .Volume:					return BSCContextFeature.Volume
		case .MusicOutputType:			return BSCContextFeature.AvAudioSessionOutputPort
		case .ReachableViaWWAN:			return BSCContextFeature.ReachableViaWWAN
		case .ReachableViaWiFi:			return BSCContextFeature.ReachableViaWiFi
		}
	}
}

// MARK: - 	BSCContextTableViewMotionSectionRowType

enum BSCContextTableViewMotionSectionRowType: Int, BSCContextTableViewCellRowType {
	
	case MotionStationary = 0
	case MotionWalking
	case MotionRunning
	case MotionCar
	case MotionCycling
	case MotionUnknown
	
	static var numberOfRows: Int {
		return self.allCases.count
	}
	
	static func percentageFromTotalWeight() -> Float? {
		var percentageFromTotalWeight = Float(0)
		for row in self.allCases {
			percentageFromTotalWeight += (row.percentageFromTotalWeight() ?? Float(0))
		}
		return percentageFromTotalWeight
	}
	
	var title: String? {
		switch self {
		case .MotionStationary:			return L("word.context.motion.stationary")
		case .MotionWalking:			return L("word.context.motion.walking")
		case .MotionRunning:			return L("word.context.motion.running")
		case .MotionCar:				return L("word.context.motion.car")
		case .MotionCycling:			return L("word.context.motion.cycling")
		case .MotionUnknown:			return L("word.context.motion.unknown")
		}
	}
	
	func detailString(context: BSCContext) -> String? {
		switch self {
		case .MotionStationary:			return context.motionContext?.displayableStationaryString()
		case .MotionWalking:			return context.motionContext?.displayableWalkingString()
		case .MotionRunning:			return context.motionContext?.displayableRunningString()
		case .MotionCar:				return context.motionContext?.displayableCarString()
		case .MotionCycling:			return context.motionContext?.displayableCyclingString()
		case .MotionUnknown:			return context.motionContext?.displayableUnknownString()
		}
	}
	
	func feature() -> BSCContextFeature? {
		switch self {
		case .MotionStationary:			return BSCContextFeature.MotionStationary
		case .MotionWalking:			return BSCContextFeature.MotionWalking
		case .MotionRunning:			return BSCContextFeature.MotionRunning
		case .MotionCar:				return BSCContextFeature.MotionCar
		case .MotionCycling:			return BSCContextFeature.MotionCycling
		case .MotionUnknown:			return BSCContextFeature.MotionUnknown
		}
	}
}

// MARK: - 	BSCContextTableViewWeatherSectionRowType

enum BSCContextTableViewWeatherSectionRowType: Int, BSCContextTableViewCellRowType {
	
	case Temperature = 0
	case DayMaxTemperatre
	case DayMinTemperature
	case WindSpeed
	case Humidity
	case Visibility
	case IsDayLight
	case YWeatherCondition
	
	static var numberOfRows: Int {
		return self.allCases.count
	}
	
	static func percentageFromTotalWeight() -> Float? {
		var percentageFromTotalWeight = Float(0)
		for row in self.allCases {
			percentageFromTotalWeight += (row.percentageFromTotalWeight() ?? Float(0))
		}
		return percentageFromTotalWeight
	}
	
	var title: String? {
		switch self {
		case .Temperature:				return L("word.context.weather.temperature")
		case .IsDayLight:				return L("word.context.weather.isDayLight")
		case .WindSpeed:				return L("word.context.weather.windSpeed")
		case .Humidity:					return L("word.context.weather.humidity")
		case .Visibility:				return L("word.context.weather.visibility")
		case .DayMinTemperature:		return L("word.context.weather.dayMinTemeprature")
		case .DayMaxTemperatre:			return L("word.context.weather.dayMaxTemperature")
		case .YWeatherCondition:		return L("word.context.weather.yWeatherCondition")
		}
	}
	
	func detailString(context: BSCContext) -> String? {
		switch self {
		case .Temperature:				return context.weatherContext?.displayableTemperatureString()
		case .IsDayLight:				return context.weatherContext?.displayableIsDaylightString()
		case .WindSpeed:				return context.weatherContext?.displayableWindSpeedString()
		case .Humidity:					return context.weatherContext?.displayableHumidityString()
		case .Visibility:				return context.weatherContext?.displayableVisibilityString()
		case .DayMinTemperature:		return context.weatherContext?.displayableDayMinTemperatureString()
		case .DayMaxTemperatre:			return context.weatherContext?.displayableDayMaxTemperatureString()
		case .YWeatherCondition:		return context.weatherContext?.displayableConditionsString()
		}
	}
	
	func feature() -> BSCContextFeature? {
		switch self {
		case .Temperature:				return BSCContextFeature.Temperature
		case .IsDayLight:				return BSCContextFeature.IsDaylight
		case .WindSpeed:				return BSCContextFeature.WindSpeed
		case .Humidity:					return BSCContextFeature.Humidity
		case .Visibility:				return BSCContextFeature.Visibility
		case .DayMinTemperature:		return BSCContextFeature.DayMinTemperature
		case .DayMaxTemperatre:			return BSCContextFeature.DayMaxTemperature
		case .YWeatherCondition:		return BSCContextFeature.YWeatherConditionCode
		}
	}
}
