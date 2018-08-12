//
//  BSCFetchedResultsTableViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 26.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit

class BSCFetchedResultsTableViewController: BSCViewController {

	@IBOutlet weak var tableView						: UITableView!
	
	var mFetchedResultsController						: NSFetchedResultsController?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.mFetchedResultsController = self.fetchedResultsController()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		BSCHelper.fixTableViewInset(self, tableView: self.tableView)
	}
	
	// Abstract methods
	
	func fetchedResultsController() -> NSFetchedResultsController? {
		return self.mFetchedResultsController
	}
}

extension BSCFetchedResultsTableViewController : NSFetchedResultsControllerDelegate {
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		// The tableView could be reloaded here.
	}
}

extension BSCFetchedResultsTableViewController : UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if let sections = self.mFetchedResultsController?.sections {
			return sections.count
		}
		return 0
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let section = self.mFetchedResultsController?.sections?[section] {
			return section.numberOfObjects
		}
		return 0
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		fatalError("This is an abstract method and should be overridden")
	}
}