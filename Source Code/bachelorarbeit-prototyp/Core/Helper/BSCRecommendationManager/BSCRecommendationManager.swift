//
//  BSCRecommendationManager.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 27.01.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import Foundation

class BSCRecommendationManager: NSObject {
	
	struct BSCRecommendationManagerConstants {
		
		static func MinSimilarity(recommendationType: BSCRecommendation.RecommendationType) -> Float {
			switch recommendationType {
			case .Complete:		return Float(0.7)
			case .Location:		return Float(0.25)
			case .Daytime:		return Float(0.01)
			case .Weekday:		return Float(0.01)
			case .Weather:		return Float(0.8)
			}
		}
		
		static let RecommendationsCountLimit		= 3
	}
	
	// MARK: - Private variables -
	
	static let sharedInstance					= BSCMotionActivityManager()
	
	// MARK: -
	
	class func currentRecommendations(recommendationType: BSCRecommendation.RecommendationType, completion: (recommendations: [BSCRecommendation]) -> (Void)) {
		BSCContextManager.currentContext(self.sharedInstance, update: nil) { (currentContext) -> Void in
			self.recommendations(currentContext, recommendationType: recommendationType, completion: completion)
		}
	}
	
	class func recommendations(sourceContext: BSCContext, recommendationType: BSCRecommendation.RecommendationType, completion: (recommendations: [BSCRecommendation]) -> (Void)) {
		if let allSessionContexts = BSCSessionContext.MR_findAllSortedBy(BSCContext.Key.StartDate, ascending: true) as? [BSCSessionContext] {
			// Array which will contain all recommendations
			var allRecommendations = [BSCRecommendation]()
			var recommendation = BSCRecommendation()
			var subRecommendationContexts = [(context: BSCSessionContext, distanceVector: [BSCContextFeature: NSNumber])]()
			for sessionContext in allSessionContexts {
				// Get the distance vector and store it in the sessionContext
				let distanceVector = sourceContext.distanceVector(recommendationType, otherContext: sessionContext)
				var minSimilatiry = BSCRecommendationManagerConstants.MinSimilarity(recommendationType)
				if (recommendationType == .Complete) {
					minSimilatiry = BSCPreferences.minRecommendationsSimilarity
				}
				if ((distanceVector[.Similarity]?.floatValue ?? 0) >= minSimilatiry) {
					if (recommendationType.isCollection == false) {
						// The recommendation isn't a collection, use new recommendation then.
						recommendation = BSCRecommendation()
						recommendation.addSessionContext(sessionContext)
						recommendation.distanceVectors.append(distanceVector)
					} else {
						subRecommendationContexts.append((context: sessionContext, distanceVector: distanceVector))
					}
					
					// Set the recommendation content
					recommendation.sourceContext = sourceContext
					recommendation.type = recommendationType

					// Set the recommendations type
					if (recommendationType == .Complete) {
						self.addSimilarTypes(recommendation, sourceContext: sourceContext, sessionContext: sessionContext)
					} else {
						recommendation.similarTypes = [recommendationType]
					}
					
					// Store the recommendations
					if (recommendationType.isCollection == true) {
						// Set the collect sub-context recommendation as the arrays content.
						allRecommendations = [recommendation]
					} else {
						// Add the complete recommendation to the array
						allRecommendations.append(recommendation)
					}
				}
			}
			// Sort the contexts after their Similarity and limit the number of receommendations
			if (recommendationType == .Complete) {
				allRecommendations = allRecommendations.sort({ (o1: BSCRecommendation, o2: BSCRecommendation) -> Bool in
					return o1.distanceVectors.first?[.Similarity]?.floatValue > o2.distanceVectors.first?[.Similarity]?.floatValue
				})
				// Limit the number of recommendations
				if (allRecommendations.count > BSCRecommendationManagerConstants.RecommendationsCountLimit) {
					var limitedRecommendations = [BSCRecommendation]()
					var index = 0
					for recommendation in allRecommendations where index <= BSCRecommendationManagerConstants.RecommendationsCountLimit {
						limitedRecommendations.append(recommendation)
						index += 1
					}
					allRecommendations = limitedRecommendations
				}
			} else {
				subRecommendationContexts = subRecommendationContexts.sort({ (o1: (context: BSCSessionContext, distanceVector: [BSCContextFeature: NSNumber]?), o2: (context: BSCSessionContext, distanceVector: [BSCContextFeature: NSNumber]?)) -> Bool in
					return o1.distanceVector?[.Similarity]?.floatValue > o2.distanceVector?[.Similarity]?.floatValue
				})
				for var index = 0; index < BSCRecommendationManagerConstants.RecommendationsCountLimit; index++ {
					if (index < subRecommendationContexts.count) {
						recommendation.addSessionContext(subRecommendationContexts[index].context)
						recommendation.distanceVectors.append(subRecommendationContexts[index].distanceVector)
					}
				}
				if (recommendation.distanceVectors.count > 0) {
					allRecommendations = [recommendation]
				} else {
					allRecommendations = []
				}
			}
			
			completion(recommendations: allRecommendations)
		} else {
			completion(recommendations: [])
		}
	}
	
	// MARK: - Helper
	
	
	class private func addSimilarTypes(recommendation: BSCRecommendation, sourceContext: BSCContext,  sessionContext: BSCSessionContext) {
		self.addSimilarType(recommendation, sourceContext: sourceContext, sessionContext: sessionContext, recommendationType: .Location)
		self.addSimilarType(recommendation, sourceContext: sourceContext, sessionContext: sessionContext, recommendationType: .Daytime)
		self.addSimilarType(recommendation, sourceContext: sourceContext, sessionContext: sessionContext, recommendationType: .Weekday)
		self.addSimilarType(recommendation, sourceContext: sourceContext, sessionContext: sessionContext, recommendationType: .Weather)
	}
	
	class private func addSimilarType(recommendation: BSCRecommendation, sourceContext: BSCContext,  sessionContext: BSCSessionContext, recommendationType: BSCRecommendation.RecommendationType) {
		var minSimilatiry = BSCRecommendationManagerConstants.MinSimilarity(recommendationType)
		if (recommendationType == .Complete) {
			minSimilatiry = BSCPreferences.minRecommendationsSimilarity
		}
		if let _distance = sourceContext.distanceVector(recommendationType, otherContext: sessionContext)[.Similarity]?.floatValue where _distance >= minSimilatiry {
			recommendation.similarTypes.append(recommendationType)
		}
	}
}
