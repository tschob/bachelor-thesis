//
//  BSCViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 24.11.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit

class BSCViewController: UIViewController, UIGestureRecognizerDelegate {

	private var customNavigationBarBackgroundView							: UIView?
	private var customNavigationBarShadowView								: UIView?

	override func viewDidLoad() {
		super.viewDidLoad()
		
		if (self.shouldAddDefaultNavigationBarBackground() == true) {
			self.addDefaultNavigationBarBackground()
		}
	}
	
	// MARK: Custom navigation bar background
	
	func shouldAddDefaultNavigationBarBackground() -> Bool {
		return true
	}
	
	private func addDefaultNavigationBarBackground() {
		// Create background view
		self.customNavigationBarBackgroundView = self.viewForNavigationbarBackground()
		if let _customNavigationBarBackgroundView = self.customNavigationBarBackgroundView {
			// Add blur effect
			let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
			visualEffectView.frame = _customNavigationBarBackgroundView.bounds
			_customNavigationBarBackgroundView.addSubview(visualEffectView)
			// Add it to the view controller
			self.view.addSubview(_customNavigationBarBackgroundView)
		}
		
		// Create shadow view
		let shadowHeight = 1 / UIScreen.mainScreen().scale
		self.customNavigationBarShadowView = UIView(frame: CGRectMake(0, self.customNavigationBarBackgroundView?.frameHeight ?? 0, self.view.frameWidth, shadowHeight))
		if let _customNavigationBarShadowView = self.customNavigationBarShadowView {
			_customNavigationBarShadowView.backgroundColor = UIColor.lightGrayColor()
			// Add it to the view controller
			self.view.addSubview(_customNavigationBarShadowView)
		}
	}
	
	func addNavigationBarWithColorScheme(colorScheme: LEColorScheme?) {
		// Create background view
		if let
			_colorScheme = colorScheme {
				self.customNavigationBarBackgroundView = self.viewForNavigationbarBackground()
				self.customNavigationBarBackgroundView?.backgroundColor = _colorScheme.backgroundColor
				self.view.addSubview(self.customNavigationBarBackgroundView!)
				self.navigationController?.navigationBar.tintColor = _colorScheme.primaryTextColor
				self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : _colorScheme.secondaryTextColor]
		}
	}
	
	private func viewForNavigationbarBackground() -> UIView {
		let backgroundHeight = Constants.normalStatusBarHeight + (self.navigationController?.navigationBar.frameHeight ?? 0)
		return UIView(frame: CGRectMake(0, 0, self.view.frameWidth, backgroundHeight))
	}
}
