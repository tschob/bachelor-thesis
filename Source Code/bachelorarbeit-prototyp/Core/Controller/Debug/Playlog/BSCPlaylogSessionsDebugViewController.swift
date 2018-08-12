//
//  BSCPlaylogSessionsDebugViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 26.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit

class BSCPlaylogSessionsDebugViewController: BSCFetchedResultsTableViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	// MARK: - Abstract methods
	
	override func fetchedResultsController() -> NSFetchedResultsController? {
		return BSCPlaylogSession.MR_fetchAllSortedBy(BSCPlaylogSession.Keys.StartDate, ascending: false, withPredicate: nil, groupBy: nil, delegate: self)
	}
	
	// MARK: - Navigation
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == Constants.Segue.PushPlaylogSongsDebug) {
			if let _destinationViewController = segue.destinationViewController as? BSCPlaylogSongsDebugViewController {
					if let _session = sender as? BSCPlaylogSession {
						_destinationViewController.session = _session
						_destinationViewController.title = _session.displayableTitleString()
					}
			}
		}
	}
}

// MARK: - UITableView delegates

extension BSCPlaylogSessionsDebugViewController {
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return super.numberOfSectionsInTableView(tableView)
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let section = self.mFetchedResultsController?.sections?[section] {
			return section.numberOfObjects
		}
		return 0
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier.PlaylogSessionsDebugCell, forIndexPath: indexPath)
		// Clear the text label from the old entries
		cell.textLabel?.text = nil
		if let _session = self.mFetchedResultsController?.objectAtIndexPath(indexPath) as? BSCPlaylogSession {
			cell.textLabel?.text = _session.displayableTitleString()
		}
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		if let _playlogSession = self.fetchedResultsController()?.objectAtIndexPath(indexPath) as? BSCPlaylogSession {
			self.performSegueWithIdentifier(Constants.Segue.PushPlaylogSongsDebug, sender: _playlogSession)
		}
	}
}