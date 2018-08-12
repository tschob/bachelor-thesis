//
//  BSCMotionActivityManager.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 31.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import CoreMotion

class BSCMotionActivityManager: NSObject {

	private struct BSCMotionActivityManagerConstants {
		static let ObservationDuration					= Double(5)
	}
	
	// MARK: - Private variables -
	
	static let sharedInstance							= BSCMotionActivityManager()
	
	private let cmMotionActivityManager					= CMMotionActivityManager()
	
	private var motionContextCompletionCallbacks		= Dictionary<String,[((motionContext: BSCMotionContext?) -> (Void))]>()

	private var motionActivities						= [CMMotionActivity]()
	
	// MARK: - Public methods -

	class func currentMotionContext(sender: AnyObject, completion: (motionContext: BSCMotionContext?) -> (Void)) {
		self.sharedInstance.currentMotionContext(sender, completion: completion)
	}
	
	func currentMotionContext(sender: AnyObject, completion: (motionContext: BSCMotionContext?) -> (Void)) {
		self.addMotionActivityCompletionCallback(sender, callback: completion)
		if (CMMotionActivityManager.isActivityAvailable() == true) {
			self.cmMotionActivityManager.startActivityUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (activity: CMMotionActivity?) -> Void in
				if let _activity = activity {
					self.motionActivities.append(_activity)
				}
			})
			self.performBlockAfterDelay(BSCMotionActivityManagerConstants.ObservationDuration, block: { () -> Void in
				self.cmMotionActivityManager.stopActivityUpdates()
				if (self.motionActivities.count > 0) {
					self.callMotionActivityCompletionCallbacks()
				} else {
					self.cancelMotionActivityCompletionCallbacks()
				}
			})
		} else {
			self.cancelMotionActivityCompletionCallbacks()
		}
	}
	
	// MARK: - Location completion callback
	
	func addMotionActivityCompletionCallback(sender: AnyObject, callback: (location: BSCMotionContext?) -> Void) {
		let uid = "\(unsafeAddressOf(sender))"
		if var _callbacks = self.motionContextCompletionCallbacks[uid] {
			_callbacks.append(callback)
		} else {
			self.motionContextCompletionCallbacks[uid] = [callback]
		}
	}
	
	func removeMotionActivityCompletionCallback(sender: AnyObject) {
		let uid = "\(unsafeAddressOf(sender))"
		self.motionContextCompletionCallbacks.removeValueForKey(uid)
	}
	
	// MARK: - Private methods
	
	// MARK: - BSCMotionContext completion callbacks
	
	private func callMotionActivityCompletionCallbacks() {
		self.callMotionActivityCompletionCallbacks(self.currentMotionContext())
	}
	
	private func callMotionActivityCompletionCallbacks(motionContext: BSCMotionContext?) {
		var calledCompletionCallbacks = [String]()
		for sender in self.motionContextCompletionCallbacks.keys {
			if let _callbacks = self.motionContextCompletionCallbacks[sender] {
				for callback in _callbacks {
					BSCLog(Verbose.BSCMotionActivityManager, "Perform motion context completion callback for \(sender)")
					callback(motionContext: motionContext)
				}
			}
			calledCompletionCallbacks.append(sender)
		}
		for key in calledCompletionCallbacks {
			BSCLog(Verbose.BSCMotionActivityManager, "Remove motion context completion callbacks for sender (\(key)) as it has been called")
			self.motionContextCompletionCallbacks.removeValueForKey(key)
		}
	}
	
	private func cancelMotionActivityCompletionCallbacks() {
		BSCLog(Verbose.BSCMotionActivityManager, "canceling motion context completion callbacks")
		self.callMotionActivityCompletionCallbacks(nil)
	}
	
	// MARK: - Helper
	
	private func currentMotionContext() -> BSCMotionContext? {
		if (self.motionActivities.count > 0) {
			let motionContext = BSCMotionContext.unpersistedEntity()
			motionContext.setMotionActivities(self.motionActivities)
			return motionContext
		}
		return nil
	}
}
