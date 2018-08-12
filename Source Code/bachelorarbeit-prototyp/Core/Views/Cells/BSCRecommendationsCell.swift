//
//  BSCRecommendationsCell.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 28.01.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import Foundation

class BSCRecommendationsCell: UITableViewCell {
	
	static let preferedHeight									= CGFloat(150)
	
	@IBOutlet weak var view: UIView!
	
	private let collectionViewDataSource						= BSCRecommendationsCollectionViewDataSource()
	
	@IBOutlet weak var similarityLabel							: UILabel!
	
	@IBOutlet weak var detailsButton							: UIButton!
	
	@IBOutlet weak var collectionView							: UICollectionView!
	
	@IBOutlet var typeIconImageViews							: [UIImageView]!
	
	var selectionBlock											: (() -> Void)?
	
	// MARK: - Initialization
	
	private func initShadowView() {
		self.view.layoutIfNeeded()
		
		self.view.layer.shadowOffset = CGSizeMake(0.5, 0.5)
		self.view.layer.shadowColor = UIColor.blackColor().CGColor
		self.view.layer.shadowRadius = 1.0
		self.view.layer.shadowOpacity = 0.6
		self.view.layer.shadowPath = UIBezierPath(rect: self.view.layer.bounds).CGPath
	}
	
	// MARK: - Setter

	func setRecommendation(recommendation: BSCRecommendation) {
		self.initShadowView()
		
		self.collectionViewDataSource.recommendation = recommendation
		self.collectionView.dataSource = self.collectionViewDataSource
		self.collectionView.delegate = self.collectionViewDataSource
		self.collectionView.reloadData()
		
		self.showSimilarTypesIcons(recommendation)
		self.similarityLabel.text = "\(recommendation.displayableSimilarity)"
	}
	
	func showSimilarTypesIcons(recommendation : BSCRecommendation) {
		// Remove old icons
		for typeIconImageView in self.typeIconImageViews {
			typeIconImageView.image = nil
		}
		
		// Iterate thorugh similar types and add the icons
		var index = 0
		for type in recommendation.similarTypes {
			if (type == .Location) {
				self.typeIconImageViews[index].image = UIImage(named: "ic_location")
			} else if (type == .Daytime) {
				self.typeIconImageViews[index].image = UIImage(named: "ic_hour")
			} else if (type == .Weekday) {
				self.typeIconImageViews[index].image = UIImage(named: "ic_caledar")
			} else if (type == .Weather) {
				self.typeIconImageViews[index].image = UIImage(named: "ic_weather")
			}
			index += 1
		}
	}
	
	// MARK: - IBActions

	@IBAction func didPressDetailsButton(sender: AnyObject) {
		self.selectionBlock?()
	}
}