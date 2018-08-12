//
//  BSCRecommendationsViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 28.01.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import Foundation

class BSCRecommendationsViewController: BSCViewController {
	
	@IBOutlet private weak var tableView					: UITableView!

	@IBOutlet weak var progressBackgroundView				: UIView!
	@IBOutlet weak var progressBackgroundLabel				: UILabel!
	
	@IBOutlet weak var emptyRecommendationsBackgroundView	: UIView!
	
	private var sourceContext								: BSCContext?
	
	private var recommendations								= [BSCRecommendation]()

	@IBOutlet weak private var debugButton					: UIBarButtonItem?
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		
		self.showEmptyRecommendationsView(false)
		self.showDataLoadigView()
		self.progressBackgroundLabel.text = L("recommendations.progress.collecting")

		BSCContextManager.currentContext(self, update: nil) { [weak self] (currentContext) -> Void in
			// Check if the source context is nil. This isn't the case if another context was chosen manually in between.
			if (self?.sourceContext == nil) {
				self?.progressBackgroundLabel.text = L("recommendations.progress.analyzing")
				self?.sourceContext = currentContext
				self?.generateRecommendations()
			} else {
				self?.showEmptyRecommendationsView(true)
			}
		}
		
		if (BSCHelper.showDebugFeatures() == false) {
			self.navigationItem.rightBarButtonItem = nil
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		BSCHelper.fixTableViewInset(self, tableView: self.tableView)
	}
	
	// MARK: - Abtract methods
	
	override func shouldAddDefaultNavigationBarBackground() -> Bool {
		return false
	}
	
	// MARK: - IBActions
	
	@IBAction func didPressDebugButton(sender: AnyObject) {
		self.showDebugActionSheet()
	}
	
	// MARK: - Helper
	
	func generateRecommendations() {
		if let _sourceContext = self.sourceContext {
			self.showEmptyRecommendationsView(false)
			self.showDataLoadigView()
			self.recommendations.removeAll()
			BSCRecommendationManager.recommendations(_sourceContext, recommendationType: .Complete, completion: { (recommendations) -> (Void) in
				self .performBlockInMainThread({ () -> Void in
					for recommendation in recommendations {
						self.recommendations.append(recommendation)
					}
					self.cupdateEmptyRecommendationsViewVisibility()
					self.tableView.reloadData()
				})
			})
			BSCRecommendationManager.recommendations(_sourceContext, recommendationType: .Location, completion: { (recommendations) -> (Void) in
				self.performBlockInMainThread({ () -> Void in
					for recommendation in recommendations {
						self.recommendations.append(recommendation)
					}
					self.cupdateEmptyRecommendationsViewVisibility()
					self.tableView.reloadData()
				})
			})
			BSCRecommendationManager.recommendations(_sourceContext, recommendationType: .Daytime, completion: { (recommendations) -> (Void) in
				self.recommendations.appendContentsOf(recommendations)
				self.cupdateEmptyRecommendationsViewVisibility()
				self.tableView.reloadData()
			})
			BSCRecommendationManager.recommendations(_sourceContext, recommendationType: .Weather, completion: { (recommendations) -> (Void) in
				self.recommendations.appendContentsOf(recommendations)
				self.cupdateEmptyRecommendationsViewVisibility()
				self.tableView.reloadData()
			})
		}
	}
	
	func showDebugActionSheet() {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
		// Refresh the recommendations
		let refreshAction = UIAlertAction(title: L("recommendations.debug.action.refresh"), style: .Default, handler: {
			(alert: UIAlertAction!) -> Void in
				self.refreshRecommendations()
		})
		// See source context details
		let sourceContextDetailsAction = UIAlertAction(title: L("recommendations.debug.action.sourceContextDetails"), style: .Default, handler: {
			(alert: UIAlertAction!) -> Void in
			self.performSegueWithIdentifier(Constants.Segue.PushContext, sender: nil)
		})
		// Choose context as source context
		let chooseSourceContextAction = UIAlertAction(title: L("recommendations.debug.action.chooseSourceContext"), style: .Default, handler: {
			(alert: UIAlertAction!) -> Void in
				self.chooseSourceContext()
		})
		// Cancel action sheet
		let cancelSheetAction = UIAlertAction(title: L("word.cancel").capitalizedString, style: .Cancel, handler: {
			(alert: UIAlertAction!) -> Void in
			self.dismissViewControllerAnimated(true, completion: nil)
		})

		alertController.addAction(refreshAction)
		alertController.addAction(sourceContextDetailsAction)
		alertController.addAction(chooseSourceContextAction)
		alertController.addAction(cancelSheetAction)
		
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
	private func refreshRecommendations() {
		self.recommendations.removeAll()
		self.tableView.reloadData()
		self.generateRecommendations()
	}
	
	private func chooseSourceContext() {
		self.performSegueWithIdentifier(Constants.Segue.ModalChooseContext, sender: nil)
	}
	
	private func recommendation(indexPath: NSIndexPath) -> BSCRecommendation? {
		if (indexPath.row < self.recommendations.count) {
			return self.recommendations[indexPath.row]
		}
		return nil
	}
	
	// MARK: BackgroundView
	
	private func showEmptyRecommendationsView(show: Bool) {
		self.emptyRecommendationsBackgroundView?.hidden = (show == false)
		if (show == true) {
			self.hideDataLoadingView()
		}
		self.tableView.hidden = show
	}
	
	private func cupdateEmptyRecommendationsViewVisibility() {
		if (self.recommendations.count == 0) {
			self.showEmptyRecommendationsView(true)
		} else {
			self.showEmptyRecommendationsView(false)
		}
	}
	
	private func showDataLoadigView() {
		self.progressBackgroundView?.hidden = false
		self.tableView.hidden = true
	}
	
	private func hideDataLoadingView() {
		self.progressBackgroundView?.hidden = true
		self.tableView.hidden = false
	}
	
	// MARK: - Navigation
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == Constants.Segue.PushRecommendation),
			let _songsViewController = segue.destinationViewController as? BSCRecommendationViewController,
			let _recommendation = sender as? BSCRecommendation {
				_songsViewController.recommendation = _recommendation
		} else if (segue.identifier == Constants.Segue.ModalChooseContext),
			let _pickerViewController = segue.destinationViewController as? BSCContextPickerDebugViewController {
				_pickerViewController.completion = { [weak self] (context: BSCContext) -> Void in
					self?.sourceContext = context
					self?.refreshRecommendations()
				}
		} else if (segue.identifier == Constants.Segue.PushContext),
			let _contextViewController = segue.destinationViewController as? BSCContextDetailDebugViewController {
				if let _sourceContext = self.sourceContext {
					_contextViewController.context = _sourceContext
				} else {
					BSCHelper.showErrorAlert(self, message: "Es ist kein Ausgangs-Kontext ausgewählt!")
				}
		}
	}
}

// MARK: - UITableViewDelegate

extension BSCRecommendationsViewController: UITableViewDataSource, UITableViewDelegate {

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.recommendations.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier.RecommendationsCell, forIndexPath: indexPath)
		
		if let
			_cell = cell as? BSCRecommendationsCell,
			_recommendation = self.recommendation(indexPath) {
				_cell.selectionBlock = {
					self.performSegueWithIdentifier(Constants.Segue.PushRecommendation, sender: self.recommendation(indexPath))
				}
				_cell.setRecommendation(_recommendation)
		}
		
		return cell
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return BSCRecommendationsCell.preferedHeight
	}
}