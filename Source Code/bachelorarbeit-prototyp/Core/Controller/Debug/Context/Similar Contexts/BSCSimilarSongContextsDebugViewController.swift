//
//  BSCSimilarSongContextsDebugViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 21.01.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import UIKit

class BSCSimilarSongContextsDebugViewController: BSCSimilarContextsDebugViewController {
	
	override func allContexts() -> [BSCContext]? {
		return BSCSongContext.MR_findAll() as? [BSCContext]
	}
}