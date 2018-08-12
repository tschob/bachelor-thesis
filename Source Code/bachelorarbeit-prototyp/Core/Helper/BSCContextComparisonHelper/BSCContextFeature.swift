//
//  BSCContextFeature.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 15.01.16.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

enum BSCContextFeature: Int {
	case HourOfDay							= 0
	case DayOfTheWeek
	case MonthOfTheYear
	case LocationDistance
	case Accuracy
	case Country
	case WifiSSID
	case DayMaxTemperature
	case DayMinTemperature
	case Visibility
	case IsDaylight
	case Humidity
	case Temperature
	case WindSpeed
	case YWeatherConditionCode
	case MotionCar
	case MotionCycling
	case MotionRunning
	case MotionStationary
	case MotionUnknown
	case MotionWalking
	case ReachableViaWWAN
	case ReachableViaWiFi
	case AvAudioSessionOutputPort
	case ApplicationIsInForeground
	case DeviceLocked
	case Volume
	case ScreenBrightness
	case TotalDistance
	case Similarity
	
	static func allCases(recommendationType: BSCRecommendation.RecommendationType) -> [BSCContextFeature] {
		switch recommendationType {
		case .Complete:		return self.allCases
		case .Daytime:		return [.HourOfDay]
		case .Weekday:		return [.DayOfTheWeek]
		case .Location:		return [.LocationDistance, .Accuracy, .Country, .WifiSSID]
		case .Weather:		return [.DayMaxTemperature, .DayMinTemperature, .Visibility, .IsDaylight, .Humidity, .Temperature, WindSpeed, .YWeatherConditionCode]
		}
	}
	
	func weight(recommendationType: BSCRecommendation.RecommendationType) -> Float {
		// Get the number of features
		var numberOfFeatures = 1
		if (recommendationType == .Complete) {
			numberOfFeatures = 28
		} else {
			numberOfFeatures = self.dynamicType.allCases(recommendationType).count
		}
		// Get the human readable weight
		var weight = Float(0)
		switch self {
		case HourOfDay:						weight = (recommendationType == .Complete ? 3 : 1)
		case DayOfTheWeek:					weight = (recommendationType == .Complete ? 3 : 1)
		case MonthOfTheYear:				weight = 3
			
		case LocationDistance:				weight = (recommendationType == .Complete ? 3.1 : 2.1)
		case Accuracy:						weight = (recommendationType == .Complete ? 0.1 : 0.1)
		case Country:						weight = (recommendationType == .Complete ? 2.9 : 0.8)
		case WifiSSID:						weight = (recommendationType == .Complete ? 2 : 1.0)
			
		case DayMaxTemperature:				weight = (recommendationType == .Complete ? 3 : 2.0)
		case DayMinTemperature:				weight = (recommendationType == .Complete ? 0.1 : 0.4)
		case Visibility:					weight = (recommendationType == .Complete ? 0.1 : 0.4)
		case IsDaylight:					weight = (recommendationType == .Complete ? 3 : 2.0)
		case Humidity:						weight = (recommendationType == .Complete ? 0.1 : 0.4)
		case Temperature:					weight = (recommendationType == .Complete ? 3 : 2.0)
		case WindSpeed:						weight = (recommendationType == .Complete ? 0.1 : 0.4)
		case YWeatherConditionCode:			weight = (recommendationType == .Complete ? 0.1 : 0.4)
		case MotionCar, MotionCycling, MotionRunning, MotionStationary, MotionUnknown, MotionWalking:
			weight = (recommendationType == .Complete ? 0.1 : 1.0)
		case ReachableViaWWAN:				weight = 0.1
		case ReachableViaWiFi:				weight = 0.1
		case AvAudioSessionOutputPort:		weight = 0.1
		case ApplicationIsInForeground:		weight = 0.1
		case DeviceLocked:					weight = 0.1
		case Volume:						weight = 0.2
		case ScreenBrightness:				weight = 0.1
		case TotalDistance:					weight = 0
		case Similarity:					weight = 0
		}
		// Calculate the usable weight
		return weight / Float(numberOfFeatures)
	}
	
	func range(contextA: BSCContext?, contextB: BSCContext?) -> (min: Float, max: Float, cyclicMaxValue: Float?) {
		switch self {
		case HourOfDay:						return (min: 1, max: 3, cyclicMaxValue: 24)
		case DayOfTheWeek:					return (min: 0, max: 2, cyclicMaxValue: 7)
		case MonthOfTheYear:				return (min: 1, max: 3, cyclicMaxValue: 12)
		case LocationDistance:
			var averageAccuracy = 0.0
			if let
				_locationsA = contextA?.locations,
				_locationsB = contextB?.locations where _locationsA.count > 0 && _locationsB.count > 0 {
					var totalAccuracy = 0.0
					for locationA in _locationsA {
						totalAccuracy += locationA.horizontalAccuracy
						
					}
					for locationB in _locationsB {
						totalAccuracy += locationB.horizontalAccuracy
					}
					averageAccuracy = totalAccuracy / Double(_locationsA.count + _locationsB.count)
			}
			return (min: Float(200 + averageAccuracy / 2), max: Float(200 + averageAccuracy / 2), cyclicMaxValue: nil)
		case Accuracy:						return (min: 50, max: 500, cyclicMaxValue: nil)
		case Country:						return (min: BSCContextComparisonHelper.RangeDefaultValues.False, max: BSCContextComparisonHelper.RangeDefaultValues.True, cyclicMaxValue: nil)
		case WifiSSID:						return (min: BSCContextComparisonHelper.RangeDefaultValues.False, max: BSCContextComparisonHelper.RangeDefaultValues.True, cyclicMaxValue: nil)
		case DayMaxTemperature:				return (min: 2, max: 10, cyclicMaxValue: nil)
		case DayMinTemperature:				return (min: 2, max: 10, cyclicMaxValue: nil)
		case Visibility:					return (min: 1.0, max: 3.0, cyclicMaxValue: nil)
		case IsDaylight:					return (min: BSCContextComparisonHelper.RangeDefaultValues.False, max: BSCContextComparisonHelper.RangeDefaultValues.True, cyclicMaxValue: nil)
		case Humidity:						return (min: 10, max: 30, cyclicMaxValue: nil)
		case Temperature:					return (min: 2, max: 5, cyclicMaxValue: nil)
		case WindSpeed:						return (min: 5, max: 10, cyclicMaxValue: nil)
		case YWeatherConditionCode:			return (min: BSCContextComparisonHelper.RangeDefaultValues.False, max: BSCContextComparisonHelper.RangeDefaultValues.True, cyclicMaxValue: nil)
		case MotionCar:						return (min: 0.1, max: 0.3, cyclicMaxValue: nil)
		case MotionCycling:					return (min: 0.1, max: 0.3, cyclicMaxValue: nil)
		case MotionRunning:					return (min: 0.1, max: 0.3, cyclicMaxValue: nil)
		case MotionStationary:				return (min: 0.1, max: 0.3, cyclicMaxValue: nil)
		case MotionUnknown:					return (min: 0.1, max: 0.3, cyclicMaxValue: nil)
		case MotionWalking:					return (min: 0.1, max: 0.3, cyclicMaxValue: nil)
		case ReachableViaWWAN:				return (min: BSCContextComparisonHelper.RangeDefaultValues.False, max: BSCContextComparisonHelper.RangeDefaultValues.True, cyclicMaxValue: nil)
		case ReachableViaWiFi:				return (min: BSCContextComparisonHelper.RangeDefaultValues.False, max: BSCContextComparisonHelper.RangeDefaultValues.True, cyclicMaxValue: nil)
		case AvAudioSessionOutputPort:		return (min: BSCContextComparisonHelper.RangeDefaultValues.False, max: BSCContextComparisonHelper.RangeDefaultValues.True, cyclicMaxValue: nil)
		case ApplicationIsInForeground:		return (min: BSCContextComparisonHelper.RangeDefaultValues.False, max: BSCContextComparisonHelper.RangeDefaultValues.True, cyclicMaxValue: nil)
		case DeviceLocked:					return (min: BSCContextComparisonHelper.RangeDefaultValues.False, max: BSCContextComparisonHelper.RangeDefaultValues.True, cyclicMaxValue: nil)
		case Volume:						return (min: 0.1, max: 0.3, cyclicMaxValue: nil)
		case ScreenBrightness:				return (min: 0.1, max: 0.3, cyclicMaxValue: nil)
		case TotalDistance:					return (min: 0, max: 1, cyclicMaxValue: nil)
		case Similarity:					return (min: 0, max: 1, cyclicMaxValue: nil)
		}
	}
}


// MARK: - Value -

extension BSCContextFeature {
	
	func value(context: BSCContext) -> AnyObject? {
		switch self {
		case HourOfDay:						return context.hoursOfTheDays()
		case DayOfTheWeek:					return context.daysOfTheWeek()
		case MonthOfTheYear:				return context.monthsOfTheYear()
		case LocationDistance:				return context.locations
		case Accuracy:						return context.locationAccuracies()
		case Country:						return context.countries
		case WifiSSID:						return context.wifiSSIDs
		case DayMaxTemperature:				return context.weatherContext?.dayMaxTemperature
		case DayMinTemperature:				return context.weatherContext?.dayMinTemperature
		case Visibility:					return context.weatherContext?.visibility
		case IsDaylight:					return context.weatherContext?.isDaylight
		case Humidity:						return context.weatherContext?.humidity
		case Temperature:					return context.weatherContext?.temperature
		case WindSpeed:						return context.weatherContext?.windSpeed
		case YWeatherConditionCode:			return context.weatherContext?.yWeatherConditionCodes
		case MotionCar:						return self.dynamicType.floatValue(context.motionContext?.car?.floatValue ?? BSCContextComparisonHelper.RangeDefaultValues.Unknown)
		case MotionCycling:					return self.dynamicType.floatValue(context.motionContext?.cycling?.floatValue ?? BSCContextComparisonHelper.RangeDefaultValues.Unknown)
		case MotionRunning:					return self.dynamicType.floatValue(context.motionContext?.running?.floatValue ?? BSCContextComparisonHelper.RangeDefaultValues.Unknown)
		case MotionStationary:				return self.dynamicType.floatValue(context.motionContext?.stationary?.floatValue ?? BSCContextComparisonHelper.RangeDefaultValues.Unknown)
		case MotionUnknown:					return self.dynamicType.floatValue(context.motionContext?.unknown?.floatValue ?? BSCContextComparisonHelper.RangeDefaultValues.Unknown)
		case MotionWalking:					return self.dynamicType.floatValue(context.motionContext?.walking?.floatValue ?? BSCContextComparisonHelper.RangeDefaultValues.Unknown)
		case ReachableViaWWAN:				return self.dynamicType.floatValue(context.reachableViaWWAN?.floatValue ?? BSCContextComparisonHelper.RangeDefaultValues.Unknown)
		case ApplicationIsInForeground:		return self.dynamicType.floatValue(context.applicationIsInForeground?.floatValue ?? BSCContextComparisonHelper.RangeDefaultValues.Unknown)
		case DeviceLocked:					return self.dynamicType.floatValue(context.deviceIsLocked)
		case Volume:						return self.dynamicType.floatValue(context.volume)
		case ScreenBrightness:				return self.dynamicType.floatValue(context.screenBrightness)
		case ReachableViaWiFi:				return ((context.wifiSSIDs != nil && context.wifiSSIDs?.count > 0) ? 1 : 0)
		case AvAudioSessionOutputPort:		return context.avAudioSessionOutputPorts
		case TotalDistance:					return Float(1)
		case Similarity:					return Float(1)
		}
	}
}

// MARK: - Similarity -

extension BSCContextFeature {
	
	func similarity(normalizedDistance: Float) -> Float {
		return 100 - ((normalizedDistance / self.weight(.Complete)) * 100)
	}
	
	func similarityTextColor(distanceVector: BSCContextComparisonHelper.DistanceVector) -> UIColor {
		if let _distance = distanceVector[self] {
			return self.dynamicType.similarityTextColor(self.similarity(_distance.floatValue))
		} else {
			return UIColor.blackColor()
		}
	}
	
	static func similarityTextColor(similarity: Float?) -> UIColor {
		if let _similarity = similarity {
			return UIColor.similarityColor(_similarity / 100)
		} else {
			return UIColor.blackColor()
		}
	}
}

// MARK: - Distance -

extension BSCContextFeature {
	
	func distance(contextA: BSCContext, contextB: BSCContext) -> Float {
		switch self {
		case LocationDistance:
			if let
				_locationsA = self.value(contextA) as? [CLLocation],
				_locationsB = self.value(contextB) as? [CLLocation] {
					var shortestDistance = FLT_MAX
					for _locationA in _locationsA {
						for _locationB in _locationsB {
							let distance = fabsf(Float(_locationB.distanceFromLocation(_locationA)))
							if (distance < shortestDistance) {
								shortestDistance = distance
							}
						}
					}
					return shortestDistance
			}
		case Country:
			if let
				_countriesA = self.value(contextA) as? [String],
				_countriesB = self.value(contextB) as? [String] {
					for _countryA in _countriesA {
						for _countryB in _countriesB where _countryA == _countryB {
							return Float(0)
						}
					}
			}
		case WifiSSID:
			if let
				_wifiSSIDsA = self.value(contextA) as? [String],
				_wifiSSIDsB = self.value(contextB) as? [String] {
					for _wifiSSIDA in _wifiSSIDsA {
						for _wifiSSIDB in _wifiSSIDsB where _wifiSSIDB == _wifiSSIDA {
							if (_wifiSSIDA != "-") {
								return Float(0)
							}
						}
					}
			}
		case YWeatherConditionCode:
			if let
				_yWeatherConditionCodesA = self.value(contextA) as? [NSNumber],
				_yWeatherConditionCodesB = self.value(contextB) as? [NSNumber] {
					for _yWeatherConditionCodeA in _yWeatherConditionCodesA {
						for _yWeatherConditionCodeB in _yWeatherConditionCodesB where _yWeatherConditionCodeB.floatValue == _yWeatherConditionCodeA.floatValue {
							return Float(0)
						}
					}
			}
		case AvAudioSessionOutputPort:
			if let
				_outputPortTypesA = self.value(contextA) as? [String],
				_outputPortTypesB = self.value(contextB) as? [String] {
					for _outputPortTypeA in _outputPortTypesA {
						for _outputPortTypeB in _outputPortTypesB where _outputPortTypeB == _outputPortTypeA {
							return Float(0)
						}
					}
			}
		default:
			if let
				_valuesA = self.value(contextA) as? [Float],
				_valuesB = self.value(contextB) as? [Float] {
					var shortestDistance = FLT_MAX
					for _valueA in _valuesA {
						for _valueB in _valuesB {
							let distance = fabsf(_valueA - _valueB)
							if (shortestDistance > distance) {
								shortestDistance = distance
							}
						}
					}
					return shortestDistance
			} else if let
				_valuesA = self.value(contextA) as? [NSNumber],
				_valuesB = self.value(contextB) as? [NSNumber] {
					var shortestDistance = FLT_MAX
					for _valueA in _valuesA {
						for _valueB in _valuesB {
							let distance = fabsf(_valueA.floatValue - _valueB.floatValue)
							if (shortestDistance > distance) {
								shortestDistance = distance
							}
						}
					}
					return shortestDistance
			} else if let
				_valueA = self.value(contextA) as? Float,
				_valueB = self.value(contextB) as? Float {
					return fabsf(_valueA - _valueB)
			} else if let
				_valueA = self.value(contextA) as? NSNumber,
				_valueB = self.value(contextB) as? NSNumber {
					return fabsf(_valueA.floatValue - _valueB.floatValue)
			}
		}
		if (self.value(contextA) == nil &&  self.value(contextB) == nil) {
			return Float(0)
		} else if (self.value(contextA) == nil ||  self.value(contextB) == nil) {
			return -1
		} else {
			// The values aren't the same or sth. went wrong: return 1 then
			return Float(1)
		}
	}
	
	func normalizedDistance(contextA: BSCContext, contextB: BSCContext) -> Float {
		// Calculate the normal distance
		var distance = self.distance(contextA, contextB: contextB)
		if (distance == -1) {
			return 0.5
		} else {
			// Get the range
			let range = self.range(contextA, contextB: contextB)
			
			if let _cyclicMaxValue = range.cyclicMaxValue {
				// A cyclic max value is declared. This means that the value is looped (eg. the time -> 23, 24, 01, 02...).
				// Example: 19:00 to 02:00 = 17h distance - 24 = 5h distance
				let border = round(_cyclicMaxValue / 2)
				if (distance > border) {
					// Shift if the distance is greater than the border (would be 4 if the shift is 7)
					distance = _cyclicMaxValue - distance
				}
			}
			if (range.min == range.max) {
				if (distance >= range.max) {
					return 1
				} else {
					return 0
				}
			} else {
				// Make sure the distance isn't smaller or greater than the defined min and max values
				if (distance < range.min) {
					distance = range.min
				} else
				if (distance > range.max) {
					distance = range.max
				}
				// Calculate the normalized distance
				let rangeDistance = fabsf(range.max - range.min)
				distance -= range.min
				return distance / rangeDistance
			}
		}
	}
}

// MARK: - Helper -

extension BSCContextFeature {
	
	private static func floatValue(number: NSNumber?) -> Float {
		return number?.floatValue ?? BSCContextComparisonHelper.RangeDefaultValues.Unknown
	}
}