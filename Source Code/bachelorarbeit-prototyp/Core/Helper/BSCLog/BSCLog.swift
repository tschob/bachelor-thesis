//
//  BSCLog.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 17.01.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import UIKit

// MARK: BSCLog

struct BSCLogSettings {
	static var DetailedLog		= false
}

func BSCLog(verbose: Bool, _ message: AnyObject = "", file: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
	#if DEBUG
		if (verbose == true) {
			if (BSCLogSettings.DetailedLog == true),
				let className = NSURL(string: file)?.lastPathComponent?.componentsSeparatedByString(".").first {
					let log = "\(NSDate()) - [\(className)].\(function)[\(line)]: \(message)"
					print(log)
			} else {
				print(message)
			}
		}
	#endif
}