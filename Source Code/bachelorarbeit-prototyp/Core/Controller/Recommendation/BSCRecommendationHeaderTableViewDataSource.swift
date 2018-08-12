//
//  BSCRecommendationHeaderTableViewDataSource.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 08.02.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import Foundation

class BSCRecommendationHeaderTableViewDataSource: NSObject {
	
	struct BSCRecommendationHeaderTableViewDataSourceConstants {
		static let DefaultCellHeight		= Float(35)
		static let MapCellHeight			= Float(80)
	}
	
	private var recommendation			: BSCRecommendation?

	var recommendationReasons			: [(similarType: BSCRecommendation.RecommendationType, description: String)] = []
	
	func setRecommendation(recommendation: BSCRecommendation, completion: () -> Void) {
		self.recommendation = recommendation
		
		recommendation.displayableTitles({ (titles) -> Void in
			self.recommendationReasons = titles
			completion()
		}, withEmptyLocation: true)
	}
	
	func height() -> Float {
		var height = Float(0)
		for titles in self.recommendationReasons {
			if (titles.description == "") {
				height += BSCRecommendationHeaderTableViewDataSourceConstants.MapCellHeight
			} else {
				height += BSCRecommendationHeaderTableViewDataSourceConstants.DefaultCellHeight
			}
		}
		return height
	}
}

extension BSCRecommendationHeaderTableViewDataSource: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if (self.recommendationReasons[indexPath.row].description == "") {
			let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier.MapTableViewCell, forIndexPath: indexPath)
			if let
				_cell = cell as? BSCMapTableViewCell {
					_cell.mapView.resetLocations()
					if let _allSessionContexts = self.recommendation?.allSessionContexts {
						for _sessionContext in _allSessionContexts {
							_cell.mapView.addLocations(_sessionContext.locations, colorHex: "FF0000")
						}
					}
			}
			return cell
		} else if let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier.RecommendationHeaderCell, forIndexPath: indexPath) as? BSCRecommendationHeaderCell {
			if (self.recommendationReasons[indexPath.row].similarType == .Location) {
				cell.symbolImageView?.image = UIImage(named: "ic_location")
			} else if (self.recommendationReasons[indexPath.row].similarType == .Daytime) {
				cell.symbolImageView?.image = UIImage(named: "ic_hour")
			} else if (self.recommendationReasons[indexPath.row].similarType == .Weekday) {
				cell.symbolImageView?.image = UIImage(named: "ic_caledar")
			} else if (self.recommendationReasons[indexPath.row].similarType == .Weather) {
				cell.symbolImageView?.image = UIImage(named: "ic_weather")
			}
			cell.descriptionLabel?.text = self.recommendationReasons[indexPath.row].description
			return cell
		}
		return UITableViewCell()
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.recommendationReasons.count
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if (self.recommendationReasons[indexPath.row].description == "") {
			return CGFloat(BSCRecommendationHeaderTableViewDataSourceConstants.MapCellHeight)
		} else {
			return CGFloat(BSCRecommendationHeaderTableViewDataSourceConstants.DefaultCellHeight)
		}
	}
}