//
//  BSCSimilarContextsDebugViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 21.01.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import UIKit

class BSCSimilarContextsDebugViewController: BSCViewController {

	@IBOutlet weak private var tableView		: UITableView!

	private var data							= [(context: BSCContext, distance: Float)]()
	
	var sourceContext						: BSCContext?
	
	var contextsToCompare					: [BSCContext]?

	// MARK: - View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()

		MBProgressHUD.showHUDAddedTo(self.view, animated: true)

		if let
			_ = self.sourceContext,
			_contextsToCompare = self.contextsToCompare {
				for context in _contextsToCompare {
					self.data.append((context: context, distance: -1))
				}
				self.compare()
		} else {
			if let _allContexts = self.allContexts() {
				for context in _allContexts {
					self.data.append((context: context, distance: -1))
				}
			}
			
			BSCContextManager.currentContext(self, update: nil) { [weak self] (context) -> Void in
				if let strongSelf = self {
					strongSelf.sourceContext = context
					strongSelf.compare()
				}
			}
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		BSCHelper.fixTableViewInset(self, tableView: self.tableView)
	}
	
	func compare() {
		if let _sourceContext = self.sourceContext {
			// Add the distanceVectores for each context
			for contextData in self.data {
				contextData.context.distanceVector = contextData.context.distanceVector(.Complete, otherContext: _sourceContext)
			}
			// Sort the contexts, show the nearest ones first
			self.data = self.data.sort({ (o1: (context: BSCContext, distance: Float), o2: (context: BSCContext, distance: Float)) -> Bool in
				return o1.context.distanceVector?[.TotalDistance]?.floatValue < o2.context.distanceVector?[.TotalDistance]?.floatValue
			})
			// Reload the UI
			self.tableView.reloadData()
			MBProgressHUD.hideHUDForView(self.view, animated: true)
		}
	}
	
	// MARK: -
	
	func allContexts() -> [BSCContext]? {
		return BSCContext.MR_findAll() as? [BSCContext]
	}
	
	// MARK: - Navigation
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == Constants.Segue.ShowContextComparison) {
			if let
				_sourceContext = self.sourceContext,
				_contextB = sender as? BSCContext {
				if let viewController = segue.destinationViewController as? BSCContextComparisonDebugViewController {
					viewController.contextA = _sourceContext
					viewController.contextB = _contextB
				}
			}
		}
	}
}

// MARK: - UITableView delegates

extension BSCSimilarContextsDebugViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier.SimilarContextsCell, forIndexPath: indexPath)
		
		if (indexPath.row < self.data.count) {
			cell.textLabel?.text = self.data[indexPath.row].context.displayableTitleString()
			if let
				_distanceVector = self.data[indexPath.row].context.distanceVector,
				_similarity = _distanceVector[.Similarity]?.floatValue {
					cell.detailTextLabel?.textColor = BSCContextFeature.similarityTextColor(_similarity * 100)
					cell.detailTextLabel?.text = "\(BSCHelper.displayableString(float:  (_similarity * 100), decimalPlaces: 1, symbol: "%"))"
			} else {
				cell.detailTextLabel?.textColor = UIColor.blackColor()
				cell.detailTextLabel?.text = nil
			}
		} else {
			cell.textLabel?.text = nil
		}
		
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)

		if (indexPath.row < self.data.count) {
			self.performSegueWithIdentifier(Constants.Segue.ShowContextComparison, sender: self.data[indexPath.row].context)
		}
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.data.count
	}
}