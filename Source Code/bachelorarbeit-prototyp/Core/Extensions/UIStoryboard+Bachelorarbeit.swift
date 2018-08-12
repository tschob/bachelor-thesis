//
//  UIStoryboard+Bachelorarbeit.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 13.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit

extension UIStoryboard {

	// MARK: - Storyboard

	private class func player() -> UIStoryboard {
		return UIStoryboard(name: "Player", bundle: nil)
	}
	
	// MARK: - Controller
	
	class func instantiatedPlayerViewController() -> BSCPlayerViewController? {
		if let _playerViewController = self.player().instantiateViewControllerWithIdentifier("BSCPlayerViewController") as? BSCPlayerViewController {
			return _playerViewController
		}
		return nil
	}
}
