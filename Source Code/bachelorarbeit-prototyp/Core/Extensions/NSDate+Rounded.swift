//
//  NSDate+Rounded.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 11.02.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import Foundation

extension NSDate {
	
	func roundedHour() -> Int {
		var hour = self.hour()
		// Check if we are in the first or the second half of the hour
		if (self.minute() > 30) {
			// Use the next hour as hour as it is nearer than the current one.
			hour += 1
			// Check if the next hour is on the next day, choose 0 then.
			if (hour >= 24) {
				hour = 0
			}
		}
		return hour
	}
}
