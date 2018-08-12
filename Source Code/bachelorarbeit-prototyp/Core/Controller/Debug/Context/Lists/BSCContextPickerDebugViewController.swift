//
//  BSCContextPickerDebugViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 20.01.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import UIKit

class BSCContextPickerDebugViewController: BSCContextsDebugViewController {

	var completion		: ((context: BSCContext) -> Void)?
	
	@IBAction func didPressCancelButton(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	@IBAction func didPressCurrentContextButton(sender: AnyObject) {
		MBProgressHUD.showHUDAddedTo(self.view, animated: true)
		BSCContextManager.currentContext(self, update: nil) { [weak self] (context) -> Void in
			if let _self = self {
				_self.completion?(context: context)
				MBProgressHUD.hideHUDForView(_self.view, animated: true)
				_self.didPressCancelButton(_self)
			}
		}
	}
}

// MARK: - UITableView delegates

extension BSCContextPickerDebugViewController {
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		if let _context = self.mFetchedResultsController?.objectAtIndexPath(indexPath) as? BSCContext {
			if let _completion = self.completion {
				_completion(context: _context)
			}
			self.didPressCancelButton(self)
		}
	}
}