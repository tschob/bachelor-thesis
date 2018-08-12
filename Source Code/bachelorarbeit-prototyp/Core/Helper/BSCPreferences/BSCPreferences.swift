
//
//  BSCPreferences.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 10.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit

class BSCPreferences: NSObject {
	
	static var activeMusicLibraryType : MusicLibraryType {
		get {
			if let
				rawValue = NSUserDefaults.standardUserDefaults().stringForKey(Constants.UserDefaultsKeys.ActiveMusicLibraryType),
				type = MusicLibraryType(rawValue: rawValue) {
					return type
			}
			return MusicLibraryType.Artist
		}
		set (type) {
			NSUserDefaults.standardUserDefaults().setObject(type.rawValue, forKey: Constants.UserDefaultsKeys.ActiveMusicLibraryType)
			NSUserDefaults.standardUserDefaults().synchronize()
		}
	}
	
	static var minRecommendationsSimilarity: Float {
		get {
			if let similarityNumber = NSUserDefaults.standardUserDefaults().objectForKey(Constants.UserDefaultsKeys.MinRecommendationsSimilarity) as? NSNumber {
				return similarityNumber.floatValue
			}
			return BSCRecommendationManager.BSCRecommendationManagerConstants.MinSimilarity(.Complete)
		}
		set (similarity) {
			NSUserDefaults.standardUserDefaults().setObject(NSNumber(float: similarity), forKey: Constants.UserDefaultsKeys.MinRecommendationsSimilarity)
			NSUserDefaults.standardUserDefaults().synchronize()
		}
	}
}
