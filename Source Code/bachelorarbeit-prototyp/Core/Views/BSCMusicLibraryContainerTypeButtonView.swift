//
//  BSCMusicLibraryContainerTypeButtonView.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 07.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit

class BSCMusicLibraryContainerTypeButtonView: UIView {

	var buttonPressedHandler		: (() -> Void)?
	
	@IBOutlet weak private var titleButton: UIButton!
	
	class func initFromNib() -> BSCMusicLibraryContainerTypeButtonView {
		if let button = BSCMusicLibraryContainerTypeButtonView.loadFromNib("BSCMusicLibraryContainerTypeButtonView") {
			return button
		} else {
			let button = BSCMusicLibraryContainerTypeButtonView()
			return button
		}
	}
	
	func setTitle(title: String) {
		self.titleButton.semanticContentAttribute = .ForceRightToLeft
		// Set the title and add a space after the title to keep the space netween the title and the image
		self.titleButton.setTitle("\(title) ", forState: .Normal)
	}
	
	// MARK: IBActions
	
	@IBAction private func didPressButton(sender: AnyObject) {
		if let _buttonPressedHandler = self.buttonPressedHandler {
			_buttonPressedHandler()
		}
	}
}
