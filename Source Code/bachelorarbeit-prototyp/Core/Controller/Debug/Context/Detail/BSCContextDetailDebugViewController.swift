//
//  BSCContextDetailDebugViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 29.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import Foundation

class BSCContextDetailDebugViewController: UIViewController {
	
	var context										: BSCContext?
	
	@IBOutlet weak private var tableView			: UITableView!

	override func viewDidLoad() {
		super.viewDidLoad()
			
		self.tableView.estimatedRowHeight = 90.0
		self.tableView.rowHeight = UITableViewAutomaticDimension
		
		self.tableView.registerNib(UINib(nibName: "BSCMapTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.CellIdentifier.MapTableViewCell)
		
		if (self.context == nil) {
			MBProgressHUD.showHUDAddedTo(self.view, animated: true)
			BSCContextManager.currentContext(self, update: { (context) -> Void in
				self.context = context
				self.tableView.reloadData()
				}, completion: { (context) -> Void in
					MBProgressHUD.hideHUDForView(self.view, animated: true)
					self.context = context
					self.tableView.reloadData()
			})
		} else {
			self.title = self.context?.displayableTitleString()
			self.tableView.reloadData()
		}
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		BSCContextManager.removeCallback(self)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		BSCHelper.fixTableViewInset(self, tableView: self.tableView)
	}
	
	// MARK: - IBActions
	
	@IBAction func didPressDebugButton(sender: AnyObject) {
		self.showDebugActionSheet()
	}
	
	// MARK: - Helper
	
	func showDebugActionSheet() {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
		// Rename context
		let renameContextAction = UIAlertAction(title: L("word.rename").capitalizedString, style: .Default, handler: {
			(alert: UIAlertAction!) -> Void in
			BSCHelper.renameContext(self.context, viewController: self, success: {
				self.title = self.context?.displayableTitleString()
			})
		})
		// Cancel action sheet
		let cancelSheetAction = UIAlertAction(title: L("word.cancel").capitalizedString, style: .Cancel, handler: {
			(alert: UIAlertAction!) -> Void in
			self.dismissViewControllerAnimated(true, completion: nil)
		})
		
		alertController.addAction(renameContextAction)
		alertController.addAction(cancelSheetAction)
		
		self.presentViewController(alertController, animated: true, completion: nil)
	}
}

// MARK: - UITableViewDelegate

extension BSCContextDetailDebugViewController : UITableViewDataSource, UITableViewDelegate {
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return BSCContextDetailSections(rawValue: section)?.numberOfRows() ?? 0
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return BSCContextDetailSections.allCases(self.context)
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return BSCContextDetailSections(rawValue: section)?.titleOfSection()
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if BSCContextDetailSections(rawValue: section)?.shouldShowSectionHeader() == false {
			return 0
		} else {
			return 20
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if let row = BSCContextDetailSections.rowForIndexPath(indexPath) {
			if (indexPath.section == BSCContextDetailSections.Location.rawValue && indexPath.row == BSCContextTableViewLocationSectionRowType.LocationMap.rawValue) {
				let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier.MapTableViewCell, forIndexPath: indexPath)
				if let
					_cell = cell as? BSCMapTableViewCell {
						if let _locations = self.context?.locations {
							_cell.mapView.showLocations(_locations)
						} else {
							_cell.mapView.resetLocations()
						}
				}
				return cell
			} else if let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier.CurrentContextDebugCell, forIndexPath: indexPath) as? BSCContextDetailTableViewCell {
					cell.titleLabel?.text = row.title
					if let _context = self.context {
						cell.detailLabel?.text = row.detailString(_context)
					} else {
						cell.detailLabel?.text = nil
					}
				return cell
			}
		}
		return UITableViewCell()
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if let height = BSCContextDetailSections.rowForIndexPath(indexPath)?.heightForRow {
			return height
		} else {
			return 0
		}
	}
}
