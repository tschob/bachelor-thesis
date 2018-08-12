//
//  BSCButton.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 12.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit

class BSCButton : UIButton {

	func applyBackgroundColorScheme(colorScheme: LEColorScheme?) {
		if let _colorScheme = colorScheme {
			self.setBackgroundImage(UIImage.imageFromColor(_colorScheme.backgroundColor, size: self.frameSize), forState: .Normal)
			self.setBackgroundImage(UIImage.highlightedImageFromColor(_colorScheme.secondaryTextColor, size: self.frameSize), forState: .Highlighted)
			self.setBackgroundImage(UIImage.highlightedImageFromColor(_colorScheme.secondaryTextColor, size: self.frameSize), forState: .Highlighted)
			self.setBackgroundImage(UIImage.highlightedImageFromColor(_colorScheme.secondaryTextColor, size: self.frameSize), forState: .Highlighted)
		}
	}
}