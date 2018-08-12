//
//  BSCContextsDebugViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 06.01.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import UIKit

class BSCContextsDebugViewController: BSCFetchedResultsTableViewController {


	// MARK: - Abstract methods
	
	override func fetchedResultsController() -> NSFetchedResultsController? {
		return BSCContext.MR_fetchAllSortedBy(BSCContext.Key.StartDate, ascending: false, withPredicate: nil, groupBy: nil, delegate: self)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == Constants.Segue.PushContext) {
			if let _context = sender as? BSCContext {
				if let viewController = segue.destinationViewController as? BSCContextDetailDebugViewController {
					viewController.context = _context
				}
			}
		}
	}
}

// MARK: - UITableView delegates

extension BSCContextsDebugViewController {
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier.ContextsDebugCell, forIndexPath: indexPath)
		if let _context = self.mFetchedResultsController?.objectAtIndexPath(indexPath) as? BSCContext {
			cell.textLabel?.text = _context.displayableTitleString()
			if (_context.label != nil) {
				cell.detailTextLabel?.text = _context.displayableSubtitleString()				
			}
		} else {
			cell.textLabel?.text = nil
			cell.detailTextLabel?.text = nil
		}
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		if let _context = self.mFetchedResultsController?.objectAtIndexPath(indexPath) as? BSCContext {
			self.performSegueWithIdentifier(Constants.Segue.PushContext, sender: _context)
		}
	}
}
