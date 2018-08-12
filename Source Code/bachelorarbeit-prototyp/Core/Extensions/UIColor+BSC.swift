//
//  UIColor+BSC.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 17.02.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import Foundation

extension UIColor {
	
	class func buttonTintColor() -> UIColor {
		return UIColor.init(fromHexString: "007AFF") ?? UIColor.blueColor()
	}
	
	class func contextATintColorHex() -> String {
		return "EAA427"
	}
	
	class func contextATintColor() -> UIColor {
		return UIColor.init(fromHexString: self.contextATintColorHex()) ?? UIColor.blackColor()
	}
	
	class func contextBTintColorHex() -> String {
		return "6C63C1"
	}
	
	class func contextBTintColor() -> UIColor {
		return UIColor.init(fromHexString: self.contextBTintColorHex()) ?? UIColor.blackColor()
	}
	
	class func similarityColor(similarity: Float) -> UIColor {
		return UIColor.fadeFromBaseColor(UIColor(fromHexString: "EE3233")!, toColor: UIColor(fromHexString: "00CC00")!, withPercentage: CGFloat(similarity))
	}
}