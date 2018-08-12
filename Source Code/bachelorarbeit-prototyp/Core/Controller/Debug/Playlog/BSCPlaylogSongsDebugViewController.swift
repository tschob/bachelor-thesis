//
//  BSCPlaylogSongsDebugViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 26.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import Foundation


class BSCPlaylogSongsDebugViewController : BSCFetchedResultsTableViewController {

	
	@IBOutlet weak private var debugButton		: UIBarButtonItem!
	
	var session									: BSCPlaylogSession?
	
	// MARK: - Abstract methods
	
	override func fetchedResultsController() -> NSFetchedResultsController? {
		var predicate : NSPredicate?
		if let _session = self.session {
			predicate = NSPredicate(format: "\(BSCPlaylogSong.Keys.Session) == %@", _session)
		}
		return BSCPlaylogSong.MR_fetchAllSortedBy(BSCPlaylogSong.Keys.StartDate, ascending: false, withPredicate: predicate, groupBy: nil, delegate: self)
	}
	
	// MARK: - IBActions
	
	@IBAction func didPressDebugButton(sender: AnyObject) {
		self.showDebugActionSheet()
	}
	
	// MARK: - Helper
	
	func showDebugActionSheet() {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
		// Show session context
		let showSessionContextAction = UIAlertAction(title: L("debug.session.action.showSessionContext"), style: .Default, handler: {
			(alert: UIAlertAction!) -> Void in
			self.showSessionContext()
		})
		// Cancel action sheet
		let cancelSheetAction = UIAlertAction(title: L("word.cancel").capitalizedString, style: .Cancel, handler: {
			(alert: UIAlertAction!) -> Void in
			self.dismissViewControllerAnimated(true, completion: nil)
		})
		
		alertController.addAction(showSessionContextAction)
		alertController.addAction(cancelSheetAction)
		
		self.presentViewController(alertController, animated: true, completion: nil)
	}

	func showSessionContext() {
		self.performSegueWithIdentifier(Constants.Segue.PushSessionContext, sender: self.session?.sessionContext)
	}
	
	// MARK: - Navigation
	
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == Constants.Segue.PushContext) {
			if let _context = sender as? BSCContext {
				if let viewController = segue.destinationViewController as? BSCContextDetailDebugViewController {
					viewController.context = _context
				}
			}
		} else if (segue.identifier == Constants.Segue.PushSessionContext),
			let _context = sender as? BSCContext,
			let _contextViewController = segue.destinationViewController as? BSCContextDetailDebugViewController {
				_contextViewController.context = _context
		}
	}
}

// MARK: - UITableView delegates

extension BSCPlaylogSongsDebugViewController {
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier.PlaylogSongsDebugCell, forIndexPath: indexPath)
		if let _playlogSong = self.mFetchedResultsController?.objectAtIndexPath(indexPath) as? BSCPlaylogSong {
			var songTitle = "-"
			if let _songTitle = _playlogSong.songInfo?.title {
				songTitle = _songTitle
			}
			cell.textLabel?.text = "\(_playlogSong.displayableDateString()): \(songTitle)"
			if let _playedDuration = _playlogSong.playedDuration {
				cell.detailTextLabel?.text = "Dauer: \(BSCHelper.displayableStringFromTimeInterval(_playedDuration.doubleValue))"
			} else {
				cell.detailTextLabel?.text = nil
			}
			if let _ = _playlogSong.context {
				cell.accessoryType = .DisclosureIndicator
				cell.selectionStyle = .Gray
			} else {
				cell.accessoryType = .None
				cell.selectionStyle = .None
			}
		} else {
			cell.textLabel?.text = nil
		}
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		if let _playlogSong = self.mFetchedResultsController?.objectAtIndexPath(indexPath) as? BSCPlaylogSong {
			if let _context = _playlogSong.context {
				self.performSegueWithIdentifier(Constants.Segue.PushContext, sender: _context)
			}

		}
	}
}