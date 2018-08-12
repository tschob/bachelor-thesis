//
//  BSCSongTimeSlider.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 14.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import CoreMedia

class BSCSongTimeSlider: UIView {

	@IBOutlet weak private var progressBar			: UIProgressView!
	@IBOutlet weak private var slider				: UISlider!
	
	var value										= Float (0) {
		didSet {
			self.slider.value = value
			
			if (value > 0) {
				self.progressBar.progress = value / self.slider.maximumValue
			} else {
				self.progressBar.progress = 0
			}
			
			// Prevent the progress bar from jumping right to the ~0.01 position. There is a bug or feature that it jumps right to this visual point if the value is smaller than ~0.01. As the thumb image cover some pixels, we can take the half of 0.01.
			if (self.progressBar.progress <= 0.005) {
				self.progressBar.progress = 0
			}
		}
	}
	var minimumValue								= Float (0) {
		didSet {
			self.slider.minimumValue = minimumValue
		}
	}
	var maximumValue								= Float (0) {
		didSet {
			self.slider.maximumValue = maximumValue
		}
	}
	
	// MARK: - Factory method
	
	class func loadFromNib() -> BSCSongTimeSlider? {
		if let _view = self.loadFromNib("BSCSongTimeSlider") {
			_view.slider.setThumbImage(UIImage(named: "progress_slider_thumb"), forState: .Normal)

			return _view
		}
		return nil
	}
	
	// MARK: - IBAction

	@IBAction func didChangeValueOfProgressSlider(sender: AnyObject) {
		self.value = self.slider.value
		
		let time = CMTimeMakeWithSeconds(Float64(self.value), 1)
		BSCMusicPlayer.sharedInstance.seekToTime(time)
	}
}
