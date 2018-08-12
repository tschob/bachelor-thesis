//
//  BSCContextComparisonHelper.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 15.01.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import UIKit
import CoreLocation

class BSCContextComparisonHelper: NSObject {
	
	typealias DistanceVector				= [BSCContextFeature: NSNumber]

	struct RangeDefaultValues {
		static let Temperature				: Float = 15
		static let False					: Float = 0
		static let True						: Float = 1
		static let Unknown					: Float = 0.5
	}
	
	// MARK: - Context comparison
	
	class func distanceVector(recommendationType: BSCRecommendation.RecommendationType, contextA: BSCContext, contextB: BSCContext) -> DistanceVector {
		BSCLog(Verbose.BSCContextComparisonHelper, "Will create \(recommendationType) distanceVector between contextA: \(contextA) and contextB: \(contextB)")
		// Variables to store the vector and the total distance
		var distanceVector = DistanceVector()
		var totalDistance = Float(0)
		
		// Iterate through every feature and calcualte the normalized distance
		for feature in BSCContextFeature.allCases(recommendationType) {
			// Calculate the normalized distance
			let normalizedDistance = feature.normalizedDistance(contextA, contextB: contextB)
			// Get the weighted distance
			let weightedDistance = feature.weight(recommendationType) * normalizedDistance
			// Set the distance for this feature
			distanceVector[feature] = weightedDistance
			// Add the distance to the totalDistance
			totalDistance += weightedDistance
			BSCLog(Verbose.BSCContextComparisonHelper, " - \(feature): normalizedDistance: \(normalizedDistance), weightedDistance: \(weightedDistance)")
		}
		
		// Set the total distance
		distanceVector[.TotalDistance] = totalDistance
		// Get the total similarity (which is 1 - distance (percentage)).
		distanceVector[.Similarity] = 1 - totalDistance
		BSCLog(Verbose.BSCContextComparisonHelper, "Finished with totalDistance: \(totalDistance) and similarity: \(distanceVector[.Similarity]!)")
		return distanceVector
	}
}
