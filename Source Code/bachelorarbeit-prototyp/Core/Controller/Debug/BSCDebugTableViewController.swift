//
//  BSCDebugTableViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 02.02.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import Foundation

class BSCDebugTableViewController: UITableViewController {
	
	@IBOutlet weak var minRecommendationsSimilaritySlider: UISlider!
	@IBOutlet weak var minRecommendationsSimilarityLabel: UILabel!
	
	// MARK: - View Lifecylce
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.minRecommendationsSimilaritySlider.setThumbImage(UIImage(named: "slider_thumb"), forState: .Normal)
		self.minRecommendationsSimilaritySlider.value = BSCPreferences.minRecommendationsSimilarity
		self.updateCurrentMinRecommendationsSimilarityLabel()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		BSCHelper.fixTableViewInset(self, tableView: self.tableView)
	}
	
	// MARK: - IBActions
	
	@IBAction func didChangeMinRecommendationsSimilaritySliderValue(sender: AnyObject) {
		BSCPreferences.minRecommendationsSimilarity = self.minRecommendationsSimilaritySlider.value
		self.updateCurrentMinRecommendationsSimilarityLabel()
	}
	
	@IBAction func didPressResetPlaylogButton(sender: AnyObject) {
		self.showResetPlaylogActionController()
	}
	
	@IBAction func didPressImportPlaylogButton(sender: AnyObject) {
		BSCHelper.presentDcumentPickerViewController(self, delegate: self)
	}
	
	@IBAction func didPressExportButton(sender: AnyObject) {
		self.exportPlaylog()
	}
	
	// MARK: - Helper
	
	func updateCurrentMinRecommendationsSimilarityLabel() {
		self.minRecommendationsSimilarityLabel.text = BSCHelper.displayableString(float: (BSCPreferences.minRecommendationsSimilarity * 100), decimalPlaces: 1, symbol: "%")
	}
	
	func showResetPlaylogActionController() {
		let alertController = UIAlertController(title: title, message: L("debug.action.resetPlaylog.message"), preferredStyle: UIAlertControllerStyle.Alert)
		alertController.addAction(UIAlertAction(title: L("debug.action.resetPlaylog.yes").capitalizedString, style: UIAlertActionStyle.Destructive, handler:  {
			(alert: UIAlertAction!) -> Void in
			self.resetPlaylog()
//			self.dismissViewControllerAnimated(true, completion: nil)
		}))
		alertController.addAction(UIAlertAction(title: L("debug.action.resetPlaylog.no").capitalizedString, style: UIAlertActionStyle.Cancel, handler: nil))
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
	func resetPlaylog() {
		BSCPlaylogManager.resetPlaylog()
	}
	
	func exportPlaylog() {
		MBProgressHUD.showHUDAddedTo(self.view, animated: true)

		self.performBlockInBackground { [weak self] () -> Void in
			if let _jsonData = BSCPlaylogSession.jsonExport() {
				let dateString = NSString(fromDate: NSDate(), format: "dd.MM.yy'-'HH:mm")
				let filename = "BSC_Export-\(dateString).json"
				BSCHelper.activityController(_jsonData, filename: filename, completion: { (activityController) -> Void in
					self?.performBlockInMainThread({ () -> Void in
						self?.navigationController?.presentViewController(activityController, animated: true) {
							if let _view = self?.view {
								MBProgressHUD.hideHUDForView(_view, animated: true)
							}
						}
					})
				})
			}
		}
	}
}

// MARK : UIDocumentPicker delegate

extension BSCDebugTableViewController: UIDocumentPickerDelegate {
	
	func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
		BSCHelper.jsonDictArray(controller, url: url) { (jsonDictArray) -> Void in
			if let jsonDictArray = jsonDictArray {
				BSCPlaylogSession.createEntitiesFromDictionaryArray(jsonDictArray)
			}
		}
	}
}