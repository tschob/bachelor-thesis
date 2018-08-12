//
//  BSCContextComparisonDebugViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 20.01.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import UIKit

class BSCContextComparisonDebugViewController: UIViewController {

	@IBOutlet private weak var tableView					: UITableView!
	
	@IBOutlet private weak var contextALabel				: MarqueeLabel?
	@IBOutlet private weak var contextBLabel				: MarqueeLabel?
	@IBOutlet private weak var contextDistanceLabel			: MarqueeLabel?

	@IBOutlet private weak var chooseContextAButton			: UIButton!
	@IBOutlet private weak var chooseContextBButton			: UIButton!
	
	private var distanceVector								: BSCContextComparisonHelper.DistanceVector?

	var contextA											: BSCContext? {
		didSet {
			self.updateContextAButton()
		}
	}
	
	var contextB											: BSCContext? {
		didSet {
			self.updateContextBButton()
		}
	}

	
	override func viewDidLoad() {
        super.viewDidLoad()

		self.tableView.registerNib(UINib(nibName: "BSCMapTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.CellIdentifier.MapTableViewCell)
		
		self.tableView.estimatedRowHeight = 90.0
		self.tableView.rowHeight = UITableViewAutomaticDimension
		
		if let
			_ = self.contextA,
			_ = self.contextB {
				self.updateContextAButton()
				self.updateContextBButton()
				self.didPressComparisonButton(self)
		}
    }
	
	// MARK: - Button Labels
	
	func updateCompareButton() {
		if let _similarity = self.distanceVector?[BSCContextFeature.Similarity] {
				self.contextDistanceLabel?.text = BSCHelper.displayableString(float: (_similarity.floatValue * 100), decimalPlaces: 1, symbol: "%")
				self.contextDistanceLabel?.textColor = BSCContextFeature.similarityTextColor((_similarity.floatValue * 100))
		} else {
			self.contextDistanceLabel?.text = L("word.compare").capitalizedString
			self.contextDistanceLabel?.textColor = UIColor.buttonTintColor()
		}
	}
	
	func updateContextAButton() {
		self.updateContextButton(self.contextA, contextButtonLabel: self.contextALabel, color: UIColor.contextATintColor())

	}
	
	func updateContextBButton() {
		self.updateContextButton(self.contextB, contextButtonLabel: self.contextBLabel, color: UIColor.contextBTintColor())
	}
	
	func updateContextButton(context: BSCContext?, contextButtonLabel: UILabel?, color: UIColor) {
		if let _context = context {
			contextButtonLabel?.textColor = color
			contextButtonLabel?.text = _context.displayableTitleString()
		} else {
			contextButtonLabel?.textColor = color
			contextButtonLabel?.text = L("word.choose").capitalizedString
		}
	}

    // MARK: - IBActions
	
	@IBAction func didPressComparisonButton(sender: AnyObject) {

		if let
			_contextA = self.contextA,
			_contextB = self.contextB {
				self.distanceVector = _contextA.distanceVector(.Complete, otherContext: _contextB)
				self.updateCompareButton()
		}

		self.tableView.reloadData()
	}
	
	// MARK: - Navigation
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == Constants.Segue.ModalContextPicker),
			let _viewController = segue.destinationViewController as? BSCContextPickerDebugViewController {
				_viewController.completion = { [weak self] (context: BSCContext) -> Void in
					if (sender === self?.chooseContextAButton) {
						self?.contextA = context
					} else if (sender === self?.chooseContextBButton) {
						self?.contextB = context
					}
					self?.distanceVector = nil
					self?.updateCompareButton()
					self?.tableView.reloadData()
				}
		}
	}
}

// MARK: - UITableViewDelegate

extension BSCContextComparisonDebugViewController : UITableViewDataSource, UITableViewDelegate {
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return BSCContextDetailSections(rawValue: section)?.numberOfRows() ?? 0
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return BSCContextDetailSections.allCases(nil)
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let titleNameString = BSCContextDetailSections(rawValue: section)?.titleOfSection() ?? ""
		let percentageString = " [\(L("word.part")): \(BSCHelper.displayableString(float: (BSCContextDetailSections.percentageFromTotalWeight(section) * 100), decimalPlaces: 1, symbol: "%"))]"
		return titleNameString + percentageString
	}
		
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if let row = BSCContextDetailSections.rowForIndexPath(indexPath) {
			if (indexPath.section == BSCContextDetailSections.Location.rawValue && indexPath.row == BSCContextTableViewLocationSectionRowType.LocationMap.rawValue) {
				let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier.MapTableViewCell, forIndexPath: indexPath)
				if let
					_cell = cell as? BSCMapTableViewCell {
						_cell.mapView.resetLocations()
						if let
							_contextA = self.contextA,
							_contextB = self.contextB,
							_locationsA = _contextA.locations,
							_locationsB = _contextB.locations {
								_cell.mapView.addLocations(_locationsA, colorHex: UIColor.contextATintColorHex())
								_cell.mapView.addLocations(_locationsB, colorHex: UIColor.contextBTintColorHex())
						}
				}
				return cell
			} else {
				var cell : BSCContextComparisonTableViewCell?
				if let _cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier.ContextComparisonCell) as? BSCContextComparisonTableViewCell {
					cell = _cell
				} else {
					cell = BSCContextComparisonTableViewCell()
				}
				let titleNameString = row.title ?? ""
				let percentageString = " [\(L("word.part")): \(BSCHelper.displayableString(float: row.percentageFromTotalWeight(), decimalPlaces: 3, symbol: "%"))]"
				let title = NSMutableAttributedString(string: titleNameString + percentageString)
				title.addAttribute(NSFontAttributeName, value: UIFont(name :".SFUIText-Semibold", size :13)!, range: NSMakeRange(0,titleNameString.characters.count))
				title.addAttribute(NSFontAttributeName, value: UIFont(name :".SFUIText-Regular", size :11)!, range: NSMakeRange(titleNameString.characters.count, percentageString.characters.count))

				cell?.titleLabel?.attributedText = title
				if let _contextA = self.contextA {
					cell?.contextALabel.text = row.detailString(_contextA)
				} else {
					cell?.contextALabel.text = "-"
				}
				if let _contextB = self.contextB {
					cell?.contextBLabel.text = row.detailString(_contextB)
				} else {
					cell?.contextBLabel.text = "-"
				}
				if let _distanceVector = self.distanceVector {
						cell?.distanceLabel.textColor = row.feature()?.similarityTextColor(_distanceVector)
						cell?.distanceLabel.text = row.similarityString(row.feature(), distanceVector: _distanceVector)
				} else {
					cell?.distanceLabel.text = "-"
					cell?.distanceLabel.textColor = UIColor.blackColor()
				}
				if let _cell = cell {
					return _cell
				}
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
	
	
	func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
}
