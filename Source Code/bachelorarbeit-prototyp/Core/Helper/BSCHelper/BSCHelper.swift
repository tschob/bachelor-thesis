//
//  BSCHelper.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 10.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import CoreLocation

class BSCHelper: NSObject {
	
	struct BSCHelperConstants {
		static let DefaultStringPlaceholder				= "-"
		static let StringSeperatorNewLine				= "\n"
		static let StringSeperatorComma					= ", "
		static let DefaultDecimalPlaces					= 0
	}
	
	// MARK: - App Version
	
	class func showDebugFeatures() -> Bool {
		#if INTERNAL
			return true
		#else
			return false
		#endif
	}
	
	// MARK: - Highlightes String
	
	class func highlightedString(original: NSString, hightlightedTerm: String?, fontSize: CGFloat)->NSAttributedString{
		if let _hightlightedTerm = hightlightedTerm {
			// Create attributed string
			let attributedString = NSMutableAttributedString(string: original as String, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(fontSize, weight: -0.5)])
			// Create bold attribute
			let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFontOfSize(fontSize)]
			// Part of string to be bold
			attributedString.addAttributes(boldFontAttribute, range: original.rangeOfString(_hightlightedTerm, options: .CaseInsensitiveSearch))
			return attributedString
		}
		return NSAttributedString(string: original as String)
	}
	
	// MARK: - Displayable Strings
	
	// MARK: NSTimeInterval
	
	class func displayableStringFromTimeInterval(timeInterval: NSTimeInterval) -> String {
		let dateComponentsFormatter : NSDateComponentsFormatter = NSDateComponentsFormatter()
		dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehavior.Pad
		if (timeInterval >= 60 * 60) {
			dateComponentsFormatter.allowedUnits = [.Hour, .Minute, .Second]
		} else {
			dateComponentsFormatter.allowedUnits = [.Minute, .Second]
		}
		return dateComponentsFormatter.stringFromTimeInterval(timeInterval) ?? "0:00"
	}
	
	// MARK: NSTimeInterval
	
	class func displayableString(bool bool: Bool?) -> String {
		var string : String?
		if let _bool = bool {
			string = ((_bool == true) ? L("word.yes") : L("word.no"))
		}
		return self.displayableString(string: string)
	}
	
	// MARK: NSTimeInterval
	
	class func displayableString(int int: Int?) -> String {
		var number : NSNumber?
		if let _int = int {
			number = NSNumber(integer: _int)
		}
		return self.displayableString(number: number, decimalPlaces: 0, symbol: nil)
	}
	
	// MARK: CLLocation
	
	class func displayableString(locations locations: [CLLocation]?, decimalPlaces: Int?) -> String {
		var string = ""
		if let _locations = locations {
			for location in _locations {
				if (string.characters.count > 0) {
					string += "\n"
				}
				string += self.displayableString(location: location, decimalPlaces: decimalPlaces)
			}
			return string
		}
		return BSCHelperConstants.DefaultStringPlaceholder
	}
	
	class func displayableString(location location: CLLocation?, decimalPlaces: Int?) -> String {
		let _decimalPlaces = decimalPlaces ?? BSCHelperConstants.DefaultDecimalPlaces
		if let
			_latitude = location?.coordinate.latitude,
			_longitude = location?.coordinate.longitude {
				return NSString(format: "%.\(_decimalPlaces)f, %.\(_decimalPlaces)f", _latitude, _longitude) as String
		} else {
			return BSCHelperConstants.DefaultStringPlaceholder
		}
	}
	
	// MARK: Double
	
	class func displayableString(double double: Double?, decimalPlaces: Int?, symbol: String?) -> String {
		var number : NSNumber?
		if let _double = double {
			number = NSNumber(double: _double)
		}
		return self.displayableString(number: number, decimalPlaces: decimalPlaces, symbol: symbol)
	}
	
	// MARK: Float
	
	class func displayableString(float float: Float?, decimalPlaces: Int?, symbol: String?) -> String {
		var number : NSNumber?
		if let _float = float {
			number = NSNumber(float: _float)
		}
		return self.displayableString(number: number, decimalPlaces: decimalPlaces, symbol: symbol)
	}
	
	// MARK: NSNumber
	
	class func displayableString(number number: NSNumber?, decimalPlaces: Int?, symbol: String?) -> String {
		if let _number = number {
			let _symbol = symbol ?? ""
			if let _decimalPlaces = decimalPlaces {
				return self.displayableString(string: String(format: "%.\(_decimalPlaces)f%@", _number.floatValue, _symbol))
			} else {
				return self.displayableString(string: String(format: "%.\(BSCHelperConstants.DefaultDecimalPlaces)f%@", _number.floatValue, _symbol))
			}
		}
		return BSCHelperConstants.DefaultStringPlaceholder
	}
	
	class func displayableRangeString(minNnumber minNumber: NSNumber, maxNnumber maxNumber: NSNumber, decimalPlaces: Int?, symbol: String?) -> String {
		let _symbol = symbol ?? ""
		if let _decimalPlaces = decimalPlaces {
			return self.displayableString(string: String(format: "%.\(_decimalPlaces)f - %.\(_decimalPlaces)f%@", minNumber.floatValue, maxNumber.floatValue, _symbol))
		} else {
			return self.displayableString(string: String(format: "%.\(BSCHelperConstants.DefaultDecimalPlaces)f - %.\(BSCHelperConstants.DefaultDecimalPlaces)f%@", minNumber.floatValue, maxNumber.floatValue, _symbol))
		}
	}
	
	class func displayableString(numbers allNumbers: [NSNumber]?, decimalPlaces: Int?, symbol: String?) -> String {
		return self.displayableString(numbers: allNumbers, decimalPlaces: decimalPlaces, symbol: symbol, seperator: BSCHelperConstants.StringSeperatorNewLine, placeholder: BSCHelperConstants.DefaultStringPlaceholder)
	}
	
	class func displayableString(numbers allNumbers: [NSNumber]?, decimalPlaces: Int?, symbol: String?, seperator: String, placeholder: String) -> String {
		if let _allNumbers = allNumbers {
			var string = ""
			if (_allNumbers.count > 0) {
				string = self.displayableString(number: _allNumbers[0], decimalPlaces: decimalPlaces, symbol: symbol)
			}
			for var index = 1; index < _allNumbers.count; index++ {
				string += "\(seperator)\(self.displayableString(number: _allNumbers[index], decimalPlaces: decimalPlaces, symbol: symbol))"
			}
			return string
		} else {
			return placeholder
		}
	}
	
	class func displayableRangeString(numbers allNumbers: [NSNumber]?, decimalPlaces: Int?, symbol: String?) -> String {
		if let _allNumbers = allNumbers {
			var string = ""
			if (_allNumbers.count == 1) {
				string = self.displayableString(number: _allNumbers[0], decimalPlaces: decimalPlaces, symbol: symbol)
			} else if (_allNumbers.count > 1) {
				var min = _allNumbers[0]
				var max = _allNumbers[0]
				for var index = 1; index < _allNumbers.count; index++ {
					if (_allNumbers[index].floatValue < min.floatValue) {
						min = _allNumbers[index]
					} else if (_allNumbers[index].floatValue > max.floatValue) {
						max = _allNumbers[index]
					}
				}
				if (min.floatValue == max.floatValue) {
					return self.displayableString(number: min, decimalPlaces: decimalPlaces, symbol: symbol)
				} else {
					return self.displayableRangeString(minNnumber: min, maxNnumber: max, decimalPlaces: decimalPlaces, symbol: symbol)
				}
			} else {
				return "-"
			}
			
			return string
		} else {
			return "-"
		}
	}
	
	// MARK: String
	
	class func displayableString(string string: String?) -> String {
		if let _string = self.displayableString(string: string, placeholder: BSCHelperConstants.DefaultStringPlaceholder) {
			return _string
		}
		return BSCHelperConstants.DefaultStringPlaceholder
	}
	
	class func displayableString(string string: String?, placeholder: String?) -> String? {
		if let _string = string {
			return _string
		}
		return placeholder
	}
	
	class func displayableString(strings allStrings: [String]?) -> String {
		return self.displayableString(strings: allStrings, seperator: BSCHelperConstants.StringSeperatorNewLine, placeholder: BSCHelperConstants.DefaultStringPlaceholder)
	}
	
	class func displayableString(strings allStrings: [String]?, seperator: String, placeholder: String) -> String {
		if let _allStrings = allStrings {
			var duplicatedFreeString = [String]()
			for string in _allStrings where duplicatedFreeString.contains(string) == false {
				duplicatedFreeString.append(string)
			}
			var string = ""
			if (duplicatedFreeString.count > 0) {
				string = duplicatedFreeString[0]
			}
			for var index = 1; index < duplicatedFreeString.count; index++ {
				string += "\(seperator)\(duplicatedFreeString[index])"
			}
			return string
		} else {
			return placeholder
		}
	}
	
	// MARK: - LNPopupController TableView Fix
	
	class func fixTableViewInset(viewController: UIViewController, tableView: UITableView?) {
		let insets = UIEdgeInsetsMake(viewController.topLayoutGuide.length, 0, viewController.bottomLayoutGuide.length, 0)
		tableView?.contentInset = insets
		tableView?.scrollIndicatorInsets = insets
	}
	
	// MARK: - Alert
	
	class func showErrorAlert(viewController: UIViewController, message: String) {
		self.showAlert(viewController, title: L("word.error").capitalizedString, message: message)
	}
	
	class func showAlert(viewController: UIViewController, title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: L("word.ok").capitalizedString, style: UIAlertActionStyle.Cancel, handler: nil))
		viewController.presentViewController(alert, animated: true, completion: nil)
	}
	
	class func renameContext(context: BSCContext?, viewController: UIViewController, success: (() -> Void)?) {
		let currentLabel = context?.label ?? ""
		let alertController = UIAlertController(title: L("word.rename").capitalizedString, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
		alertController.addAction(UIAlertAction(title: L("word.cancel"), style: UIAlertActionStyle.Cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: L("word.rename"), style: UIAlertActionStyle.Default, handler: {
			(alert: UIAlertAction!) -> Void in
			if let textField = alertController.textFields?.first {
				context?.label = textField.text
				NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
				success?()
			}
		}))
		alertController.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
			textField.placeholder = "Enter text:"
			textField.text = currentLabel
		})
		viewController.presentViewController(alertController, animated: true, completion: nil)
	}
	
	// MARK: - NSDate
	
	class func displayableWeekdayString(date: NSDate?) -> String {
		if let _date = date {
			return NSString(fromDate: _date, format: "eeee") as String
		}
		return BSCHelperConstants.DefaultStringPlaceholder
	}
	
	// MARK: - Similarity
	
	class func displayableString(similarity: Float?) -> String {
		if let _similarity = similarity {
			return self.displayableString(float: (_similarity * Float(100)), decimalPlaces: 1, symbol: "%")
		} else {
			return "-"
		}
	}
	
	// MARK: - Image size
	
	class func imageSizeForView(view: UIView?) -> CGSize {
		return CGSizeMake((view?.frame.width ?? 0) * 2, (view?.frame.width ?? 0) * 2)
	}
	
	// MARK: - Im- Export
	class func activityController(dataToExport: NSData, filename: String, completion: ((activityController: UIActivityViewController) -> Void)) {
		self.activityController([dataToExport], filenames: [filename], completion: completion)
	}
	
	class func activityController(dataToExport: [NSData], filenames: [String], completion: ((activityController: UIActivityViewController) -> Void)) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
			if let path = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first {
				var paths = [NSURL]()
				for var index = 0; index < dataToExport.count; index++ {
					let currentPath = path.URLByAppendingPathComponent(filenames[index])
					paths.append(currentPath)
					dataToExport[index].writeToURL(currentPath, atomically: true)
				}
				
				dispatch_async(dispatch_get_main_queue(),{
					completion(activityController: UIActivityViewController(activityItems: paths, applicationActivities: nil))
				})
			}
		}
	}
	
	class func presentDcumentPickerViewController(viewController: UIViewController, delegate: UIDocumentPickerDelegate?) -> Void {
		let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.json"], inMode: UIDocumentPickerMode.Import)
		documentPicker.delegate = delegate
		documentPicker.modalPresentationStyle =  UIModalPresentationStyle.FormSheet
		viewController.presentViewController(documentPicker, animated: true, completion: nil)
	}
	
	class func jsonDictArray(documentPicker: UIDocumentPickerViewController, url: NSURL, completion: ((jsonDictArray: [AnyObject]?) -> Void)) {
		if (documentPicker.documentPickerMode == UIDocumentPickerMode.Import) {
			var error : NSError?
			let fileCoordinator = NSFileCoordinator()
			fileCoordinator.coordinateReadingItemAtURL(url, options: .WithoutChanges, error: &error, byAccessor: { (url2: NSURL) -> Void in
				if let jsonData = NSData(contentsOfURL: url2) {
					do {
						if let jsonDictArray = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments) as? [AnyObject] {
							completion(jsonDictArray: jsonDictArray)
							return
						}
					} catch {
						BSCLog(Verbose.Error, "Error: can't parse the contents of the imported file.")
					}
				}
				completion(jsonDictArray: nil)
			})
		}
	}
}
