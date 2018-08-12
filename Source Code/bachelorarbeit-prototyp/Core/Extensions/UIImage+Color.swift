//
//  UIImage+Color.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 12.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit

extension UIImage {
	
	class func imageFromColor(color: UIColor, size: CGSize) -> UIImage {
		let rect = CGRectMake(0.0, 0.0, size.width, size.height);
		UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
		let context = UIGraphicsGetCurrentContext()
		color.setFill()
		CGContextFillRect(context, rect);
		let image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		return image;
	}
	
	class func highlightedImageFromColor(color: UIColor, size: CGSize) -> UIImage {
		return UIImage.imageFromColor(color.colorWithAlphaComponent(0.3), size: size)
	}
}
