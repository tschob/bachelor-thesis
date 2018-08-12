//
//  BSCExtensions.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 11.01.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import UIKit

// MARK: - NSNumber+Operators

// MARK: Add

func + (left: NSNumber?, right: NSNumber?) -> NSNumber {
	return NSNumber(float: ((left?.floatValue ?? 0) + (right?.floatValue ?? 0)))
}

func += (inout left: NSNumber, right: NSNumber?) {
	left = left + right
}

// MARK: Divide

func / (left: NSNumber?, right: NSNumber?) -> NSNumber? {
	if let _right = right where _right != 0 {
			return NSNumber(float: ((left?.floatValue ?? 0) / _right.floatValue))
	} else {
		return nil
	}
}

// MARK: - Enums

extension RawRepresentable where RawValue == Int {
	 static var allCases: [Self] {
		// Create array to store all found cases
		var cases = [Self]()
		// Use 0 as start index
		var index = 0
		// Try to create a case for every following integer index until no case is created. If no one is created,
		while let _case = self.init(rawValue: index) {
			cases.append(_case)
			index += 1
		}
		return cases
	}
}
