//
//  BSCContextDetailSections.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 12.01.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import UIKit

enum BSCContextDetailSections: Int {
	
	case Location = 0
	case Date
	case Device
	case Motion
	case Weather
	
	static func allCases(context: BSCContext?) -> Int {
		return 5
	}
	
	func numberOfRows() -> Int {
		return self.dynamicType.rowTypeForSection(self.rawValue)?.numberOfRows ?? 0
	}
	
	static func rowForIndexPath(indexPath: NSIndexPath) -> BSCContextTableViewCellRowType? {
		return self.rowTypeForSection(indexPath.section)?.init(rawValue: indexPath.row)
	}
	
	static func rowTypeForSection(section: Int) -> BSCContextTableViewCellRowType.Type? {
		if let sectionType = BSCContextDetailSections(rawValue: section) {
			switch sectionType {
			case .Location:					return BSCContextTableViewLocationSectionRowType.self
			case .Date:						return BSCContextTableViewDateSectionRowType.self
			case .Device:					return BSCContextTableViewDeviceSectionRowType.self
			case .Motion:					return BSCContextTableViewMotionSectionRowType.self
			case .Weather:					return BSCContextTableViewWeatherSectionRowType.self
			}
		} else {
			return nil
		}
	}
	
	func titleOfSection() -> String? {
		switch self {
		case .Location:					return L("context.detail.location.section.title")
		case .Date:						return L("context.detail.date.section.title")
		case .Device:					return L("context.detail.device.section.title")
		case .Motion:					return L("context.detail.motion.section.title")
		case .Weather:					return L("context.detail.weather.section.title")
		}
	}
	
	static func percentageFromTotalWeight(section: Int) -> Float {
		return self.rowTypeForSection(section)?.percentageFromTotalWeight() ?? Float(0)
	}
	
	func shouldShowSectionHeader() -> Bool {
		switch self {
		case .Location:			return false
		default:				return true
		}
	}
}