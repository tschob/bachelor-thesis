//
//  BSCWifiHelper.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 30.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork

class BSCWifiHelper: NSObject {
	
	class func currentWifiSSID() -> String? {
		let interfaces:CFArray! = CNCopySupportedInterfaces()
		for index in 0..<CFArrayGetCount(interfaces){
			let interfaceName: UnsafePointer<Void> = CFArrayGetValueAtIndex(interfaces, index)
			let rec = unsafeBitCast(interfaceName, AnyObject.self)
			if let
				_unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)"),
				_interfaceData = _unsafeInterfaceData as Dictionary?,
				_ssid = _interfaceData["SSID"] as? String {
				return _ssid
			}
		}
		return nil
	}
}