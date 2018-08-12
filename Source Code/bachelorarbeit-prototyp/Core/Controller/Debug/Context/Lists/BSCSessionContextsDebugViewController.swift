//
//  BSCSessionContextsDebugViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 06.01.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import UIKit

class BSCSessionContextsDebugViewController: BSCSongContextsDebugViewController {

	
	// MARK: - View Lifecycle
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
	}
	
	// MARK: - Abstract methods
	
	override func fetchedResultsController() -> NSFetchedResultsController? {
		return BSCSessionContext.MR_fetchAllSortedBy(BSCSessionContext.Key.StartDate, ascending: false, withPredicate: nil, groupBy: nil, delegate: self)
	}
}
