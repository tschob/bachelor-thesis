//
//  BSCSimilarSessionContextsDebugViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 21.01.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import UIKit

class BSCSimilarSessionContextsDebugViewController: BSCSimilarContextsDebugViewController {
	
	override func allContexts() -> [BSCContext]? {
		return BSCSessionContext.MR_findAllSortedBy(BSCContext.Key.StartDate, ascending: true) as? [BSCSessionContext]
	}
}