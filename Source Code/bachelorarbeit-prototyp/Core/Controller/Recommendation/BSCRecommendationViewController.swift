//
//  BSCRecommendationViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 29.01.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import Foundation
import MediaPlayer

class BSCRecommendationViewController: BSCSongsViewController {
	
	
	@IBOutlet weak private var headerTableView						: UITableView!
	@IBOutlet weak private var headerTableViewHeightConstraint		: NSLayoutConstraint!

	
	@IBOutlet weak private var comparisonButton						: UIBarButtonItem?
	
	private var headerDataSource									= BSCRecommendationHeaderTableViewDataSource()
	
	var recommendation : BSCRecommendation? {
		didSet {
			// Create the media items if the recommendation is set and add them as data source
			if let _recommendation = self.recommendation {
				var mediaItems = [MPMediaItem]()
				// Iterate through each song and create the corresponding media item
				for song in _recommendation.allPlaylogSongs {
					if let
						_persistentID = song.songInfo?.persistentID,
						_mediaItem = BSCMusicLibraryManager.songWithPersitentID(_persistentID) {
							mediaItems.append(_mediaItem)
					}
				}
				// Set the media items as data source
				self.sectionsData = [(title: "", sectionData: mediaItems)]
				self.comparisonButton?.enabled = true
			} else {
				self.comparisonButton?.enabled = false
			}
		}
	}
	
	// MARK: View Lifecycle
	
	override func viewDidLoad() {
		self.isFirstLevelController = false
		super.viewDidLoad()
		
		self.navigationItem.title = self.recommendation?.displayableSimilarity
		
		if (BSCHelper.showDebugFeatures() == false) {
			self.navigationItem.rightBarButtonItem = nil
		}
		
		if let _recommendation = self.recommendation {
			self.headerDataSource.setRecommendation(_recommendation, completion: {
				// Update headerView tableView height
				self.headerTableViewHeightConstraint.constant = CGFloat(self.headerDataSource.height() + 10)
				self.headerTableView.layoutIfNeeded()
				self.headerTableView.reloadData()
				// Update headerView height
				self.tableView.tableHeaderView?.frameHeight = self.headerTableViewHeightConstraint.constant + 1
				self.tableView.tableHeaderView = self.tableView.tableHeaderView;
			})
		}
		
		self.headerTableView.registerNib(UINib(nibName: "BSCMapTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.CellIdentifier.MapTableViewCell)
		
		self.headerTableView.dataSource = self.headerDataSource
		self.headerTableView.delegate = self.headerDataSource
	}
	
	// MARK: Abstract Methods Implementation
	
	override func titleForFooter() -> (singular: String, plural: String) {
		return (L("word.song"), L("word.songs"))
	}
	
	@IBAction func didPressDebugButton(sender: AnyObject) {
		self.showDebugActionSheet()
	}
	
	// MARK: - Helper
	
	func showDebugActionSheet() {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
		// Show context comparison
		let showContextComparisonAction = UIAlertAction(title: L("recommendation.debug.action.showContextComparison"), style: .Default, handler: {
			(alert: UIAlertAction!) -> Void in
			self.showContextComparison()
		})
		// Cancel action sheet
		let cancelSheetAction = UIAlertAction(title: L("word.cancel").capitalizedString, style: .Cancel, handler: {
			(alert: UIAlertAction!) -> Void in
			self.dismissViewControllerAnimated(true, completion: nil)
		})
		
		alertController.addAction(showContextComparisonAction)
		alertController.addAction(cancelSheetAction)
		
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
	func showContextComparison() {
		if let _recommendation = self.recommendation {
			if (_recommendation.allSessionContexts.count > 1) {
				self.performSegueWithIdentifier(Constants.Segue.ShowContextComparisonsList, sender: nil)
			} else if (_recommendation.allSessionContexts.count == 1) {
				self.performSegueWithIdentifier(Constants.Segue.ShowContextComparison, sender: nil)
			}
		}
	}
	
	// MARK: - Navigation
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == Constants.Segue.ShowContextComparison) {
			if let comparisonViewController = segue.destinationViewController as? BSCContextComparisonDebugViewController {
				if let _recommendation = self.recommendation where _recommendation.allSessionContexts.count == 1 {
					comparisonViewController.contextA = _recommendation.sourceContext
					comparisonViewController.contextB = _recommendation.allSessionContexts[0]
				}
			}
		} else if (segue.identifier == Constants.Segue.ShowContextComparisonsList) {
			if let similarSessionContextsViewController = segue.destinationViewController as? BSCSimilarSessionContextsDebugViewController {
				if let _recommendation = self.recommendation {
					similarSessionContextsViewController.sourceContext = _recommendation.sourceContext
					similarSessionContextsViewController.contextsToCompare = _recommendation.allSessionContexts
				}
			}
		}
	}
}


