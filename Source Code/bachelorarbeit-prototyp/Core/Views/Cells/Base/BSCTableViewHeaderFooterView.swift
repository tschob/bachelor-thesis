//
//  BSCTableViewHeaderFooterView.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 10.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit

class BSCTableViewHeaderFooterView: UITableViewHeaderFooterView {

	var generation									= 0

	override func prepareForReuse() {
		super.prepareForReuse()
		self.generation += 1
	}

	func updateInMainQueue(completion: () -> Void, generation: Int) {
		self.performBlockInMainThread({
			if (self.generation == generation) {
				completion()
			}
		})
	}
}
