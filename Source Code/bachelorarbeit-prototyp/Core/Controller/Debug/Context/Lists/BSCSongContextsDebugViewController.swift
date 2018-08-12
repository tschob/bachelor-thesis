//
//  BSCSongContextsDebugViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 06.01.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import UIKit

class BSCSongContextsDebugViewController: BSCContextsDebugViewController {

	// MARK: - Abstract methods
	
	override func fetchedResultsController() -> NSFetchedResultsController? {
		return BSCSongContext.MR_fetchAllSortedBy(BSCSongContext.Key.StartDate, ascending: false, withPredicate: nil, groupBy: nil, delegate: self)
	}
}
