//
//  BSCRecommendation.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 27.01.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import Foundation
import MediaPlayer
import CoreLocation

class BSCRecommendation: NSObject {
	
	enum RecommendationType: Int {
		case Complete	= 0
		case Location
		case Daytime
		case Weekday
		case Weather
		
		var displayableRecommendationType: String {
			switch self {
			case Complete:			return "Komplett"
			case Location:			return "Ort"
			case Daytime:			return "Stunde"
			case Weekday:			return "Tag"
			case Weather:			return "Wetter"
			}
		}
		
		var isCollection: Bool {
			switch self {
			case Complete:			return false
			default:				return true
			}
		}
	}
	
	var distanceVectors				: [[BSCContextFeature: NSNumber]] = []
	
	var distances: [NSNumber] {
		var allDistances = [NSNumber]()
		for _distanceVector in self.distanceVectors {
			if let _distance = _distanceVector[.TotalDistance] {
				allDistances.append(_distance)
			}
		}
		return allDistances
	}
	
	var displayableDistances: String {
		return BSCHelper.displayableString(numbers: self.distances, decimalPlaces: 3, symbol: nil)
	}
	
	var similarities: [NSNumber] {
		var allSimilaritiess = [NSNumber]()
		for _distanceVector in self.distanceVectors {
			if let _similarity = _distanceVector[.Similarity] {
				allSimilaritiess.append(_similarity)
			}
		}
		return allSimilaritiess
	}
	
	var displayableSimilarity: String {
		var allSimilarities = [NSNumber]()
		for similarity in self.similarities {
			allSimilarities.append(NSNumber(float: similarity.floatValue * 100))
		}
		return BSCHelper.displayableString(numbers: allSimilarities, decimalPlaces: 1, symbol: "%")
	}

	var sourceContext		: BSCContext?
	
	var allSessionContexts	= [BSCSessionContext]()
	
	var type				= RecommendationType.Complete
	
	var similarTypes		= [RecommendationType]()
	
	var allPlaylogSongs		= [BSCPlaylogSong]()
	
	var allMediaItems		= [MPMediaItem]()
	
	// MARK: - Initialization
	
	func initPlaylogSongs() {
		// Iterate through all songs from all sessions and add them to a duplicate free dictionary
		var playlogSongsDict = [NSNumber: (count: Int, song: BSCPlaylogSong)]()
		for _sessionContext in self.allSessionContexts {
			if let _playlogSongs = _sessionContext.playlogSession?.playlogSongs?.allObjects as? [BSCPlaylogSong] {
				for playlogSong in _playlogSongs {
					if let _persistentID = playlogSong.songInfo?.persistentID {
						if let _playlogSongCount = playlogSongsDict[_persistentID]?.count {
							playlogSongsDict[_persistentID] = (count: _playlogSongCount + 1, song: playlogSong)
						} else {
							playlogSongsDict[_persistentID] = (count: 1, song: playlogSong)
						}
					}
				}
			}
		}
		// Sort the dictionary after the song count
		let sortedPlaylogSongsTuple = playlogSongsDict.values.sort({
			return $0.count > $1.count
		})
		// Create the array which containts all songs sorted after their count
		var allPlaylogSongs = [BSCPlaylogSong]()
		var allMediaItems = [MPMediaItem]()
		for tuple in sortedPlaylogSongsTuple {
			allPlaylogSongs.append(tuple.song)
			if let
				_persistentID = tuple.song.songInfo?.persistentID,
				_mediaItem = BSCMusicLibraryManager.songWithPersitentID(_persistentID){
					allMediaItems.append(_mediaItem)
			}
		}
		// Update the class variable
		self.allPlaylogSongs = allPlaylogSongs
		self.allMediaItems = allMediaItems
	}
	
	// MARK: - Setter
	
	func addSessionContext(sessionContext: BSCSessionContext) {
		self.allSessionContexts.append(sessionContext)
		self.initPlaylogSongs()
	}
	
	func addSessionContexts(sessionContexts: [BSCSessionContext]) {
		self.allSessionContexts.appendContentsOf(sessionContexts)
		self.initPlaylogSongs()
	}
	
	// MARK: - Helper
	
	func mediaItemPosition(mediaItem: MPMediaItem) -> Int? {
		var index = 0
		for currentMediaItem in self.allMediaItems {
			if (currentMediaItem.persistentID == mediaItem.persistentID) {
				return index
			}
			index += 1
		}
		return nil
	}
	
	// MARK: - Description Strings
	
	func displayableTitle(completion: (title: String?) -> Void) {
		
		self.displayableTitles({ (titles) -> Void in
			if (titles.count > 1) {
				var completeTitle = titles[0].description
				for var index = 1; index < titles.count; index++ {
					completeTitle = self.addSeparatorIfNecessary(completeTitle)
					completeTitle += titles[index].description
				}
				completion(title: completeTitle)
			} else if (titles.count > 0) {
				completion(title: titles[0].description)
			} else {
				completion(title: nil)
			}
			}, withEmptyLocation: false)
	}
	
	func displayableTitles(completion: [(similarType: BSCRecommendation.RecommendationType, description: String)] -> Void, withEmptyLocation: Bool) {
		switch self.type  {
		case .Complete:
			self.displayableLocationString({ (string) -> Void in
				var titles: [(similarType: BSCRecommendation.RecommendationType, description: String)] = []
				// Location
				if let
					_locationString = string where withEmptyLocation == false {
						titles.append((similarType: .Location, description: _locationString))

				} else {
					titles.append((similarType: .Location, description: ""))
				}
				// Hour
				if (self.similarTypes.contains(.Daytime)) {
					titles.append((similarType: .Daytime, description: self.displayableHourString()))
				}
				// Day
				if (self.similarTypes.contains(.Weekday)) {
					titles.append((similarType: .Weekday, description: self.displayableDayString()))
				}
				// Weather
				if (self.similarTypes.contains(.Weather)) {
					titles.append((similarType: .Weather, description: self.displayableWeatherSring()))
				}
				// Callback
				completion(titles)
				}, withEmptyLocation: withEmptyLocation)
		case .Location: return self.displayableLocationString({ (string) -> Void in
			if let _locationString = string {
				completion([(similarType: .Complete, description: _locationString)])
			} else {
				completion([])
			}
			}, withEmptyLocation: withEmptyLocation)
		case .Daytime: return completion([(similarType: .Daytime, description: self.displayableHourString())])
		case .Weekday: return completion([(similarType: .Weekday, description: self.displayableDayString())])
		case .Weather: return completion([(similarType: .Weather, description: self.displayableWeatherSring())])
		}
	}
	
	private func addSeparatorIfNecessary(currentString: String) -> String{
		var newString = currentString
		if (newString.characters.count > 0) {
			newString += " | "
		}
		return newString
	}
	
	private func displayableLocationString(completion: (string: String?) -> Void, withEmptyLocation: Bool) {
		if let _firstLocation = self.allSessionContexts.first?.locations?.first where withEmptyLocation == false {
			CLGeocoder().reverseGeocodeLocation(_firstLocation) { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
				if let
					_placemarks = placemarks,
					_placemark = _placemarks.first {
						var string = ""
						if let _locality = _placemark.locality {
							string = _locality
						}
						if let _street = _placemark.thoroughfare {
							if string.characters.count > 0 {
								string += ", "
							} else {
								string = ""
							}
							string += _street
						}
						completion(string: string)
				} else {
					completion(string: nil)
				}
			}
		} else {
			completion(string: "")
		}
	}
	
	private func displayableHourString() -> String {
		var allHours = [NSNumber]()
		for _sessionContext in self.allSessionContexts {
			for _hour in _sessionContext.hoursOfTheDays() {
				allHours.append(NSNumber(integer: _hour))
			}
		}
		return BSCHelper.displayableRangeString(numbers: allHours, decimalPlaces: 0, symbol: " Uhr")
	}
	
	private func displayableDayString() -> String {
		// Collect all days without duplicates
		var allDays = [Int: String]()
		for _sessionContext in self.allSessionContexts {
			if let _startDate = _sessionContext.startDate {
				allDays[_startDate.day()] = _startDate.dayName()
			}
		}
		// Add all dates to the string
		var string = ""
		for dayName in allDays.values {
			string += dayName + "s, "
		}
		if (string.characters.count > 2) {
			string = String(string.characters.dropLast(2))
		}
		return string
	}
	
	private func displayableWeatherSring() -> String {
		return "Akt.: \(self.displayableTemperatureString()), Max: \(self.displayableDayMaxTemperatureString()), \(displayableDaylightString())"
	}
	
	private func displayableTemperatureString() -> String {
		var allTemperatures = [NSNumber]()
		for _sessionContext in self.allSessionContexts {
			if let _temperature = _sessionContext.weatherContext?.temperature {
				allTemperatures.append(_temperature)
			}
		}
		
		return BSCHelper.displayableRangeString(numbers: allTemperatures, decimalPlaces: 1, symbol:  L("symbol.degrees"))
	}
	
	private func displayableDayMaxTemperatureString() -> String {
		var allDayMaxTemperatures = [NSNumber]()
		for _sessionContext in self.allSessionContexts {
			if let _dayMaxTemperature = _sessionContext.weatherContext?.dayMaxTemperature {
				allDayMaxTemperatures.append(_dayMaxTemperature)
			}
		}
		return BSCHelper.displayableRangeString(numbers: allDayMaxTemperatures, decimalPlaces: 1, symbol:  L("symbol.degrees"))
	}
	
	private func displayableDaylightString() -> String {
		var isDayLight = Float(0)
		var count = 0
		for _sessionContext in self.allSessionContexts {
			if let _isDaylight = _sessionContext.weatherContext?.isDaylight?.floatValue {
				isDayLight += _isDaylight
				count += 1
			}
		}
		isDayLight = isDayLight / Float(count)
		return (isDayLight > 0.5 ? "Tageslicht" : "Kein Tageslicht")
	}
}