//
//  BSCMotionContext.swift
//  
//
//  Created by Hans Seiffert on 29.12.15.
//
//

import Foundation
import CoreData
import CoreMotion

@objc(BSCMotionContext)
class BSCMotionContext: NSManagedObject {
	
	// MARK: - Key
	
	struct Key {
		static let Car			= "car"
		static let Cycling		= "cycling"
		static let Running		= "running"
		static let Stationary	= "stationary"
		static let Unknown		= "unknown"
		static let Walking		= "walking"
	}
	
	// MARK: - Set
	
	func setMotionActivities(motionActivities: [CMMotionActivity]) {
		self.resetValues()
		if (motionActivities.count > 0) {
			self.addMotionActivitiesToExistingValues(motionActivities)
			self.divideValues(Float(motionActivities.count))
		}
	}
	
	func resetValues() {
		self.car = NSNumber(integer: 0)
		self.cycling = NSNumber(integer: 0)
		self.running = NSNumber(integer: 0)
		self.stationary = NSNumber(integer: 0)
		self.unknown = NSNumber(integer: 0)
		self.walking = NSNumber(integer: 0)
	}
	
	func resetWithMotionContexts(motionContexts: [BSCMotionContext]) {
		// Reset and prepare variables
		self.resetValues()
		
		if (motionContexts.count > 0) {
			for motionContext in motionContexts {
				// Add all values together
				self.car = self.car + motionContext.car
				self.cycling = self.cycling + motionContext.cycling
				self.running = self.running + motionContext.running
				self.stationary = self.stationary + motionContext.stationary
				self.unknown = self.unknown + motionContext.unknown
				self.walking = self.walking + motionContext.walking
			}
			// Calculate the average
			let nubmerOfContextes = NSNumber(integer: motionContexts.count)
			self.car = self.car / nubmerOfContextes
			self.cycling = self.cycling / nubmerOfContextes
			self.running = self.running / nubmerOfContextes
			self.stationary = self.stationary / nubmerOfContextes
			self.unknown = self.unknown / nubmerOfContextes
			self.walking = self.walking / nubmerOfContextes
		}
	}
	
	// MARK: - Displayable Strings
	
	func displayableCarString() -> String {
		return BSCHelper.displayableString(number: self.car, decimalPlaces: 2, symbol: nil)
	}
	
	func displayableCyclingString() -> String {
		return BSCHelper.displayableString(number: self.cycling, decimalPlaces: 2, symbol: nil)
	}
	
	func displayableRunningString() -> String {
		return BSCHelper.displayableString(number: self.running, decimalPlaces: 2, symbol: nil)
	}
	
	func displayableStationaryString() -> String {
		return BSCHelper.displayableString(number: self.stationary, decimalPlaces: 2, symbol: nil)
	}
	
	func displayableUnknownString() -> String {
		return BSCHelper.displayableString(number: self.unknown, decimalPlaces: 2, symbol: nil)
	}
	
	func displayableWalkingString() -> String {
		return BSCHelper.displayableString(number: self.walking, decimalPlaces: 2, symbol: nil)
	}
	
	// MARK: - Private helper
	
	private func addMotionActivitiesToExistingValues(motionActivities: [CMMotionActivity]) {
		for motionActivity in motionActivities {
			self.car = NSNumber(float: (self.car?.floatValue ?? 0) + Float(motionActivity.automotive))
			self.cycling = NSNumber(float: (self.cycling?.floatValue ?? 0) + Float(motionActivity.cycling))
			self.running = NSNumber(float: (self.running?.floatValue ?? 0) + Float(motionActivity.running))
			self.stationary = NSNumber(float: (self.stationary?.floatValue ?? 0) + Float(motionActivity.stationary))
			self.unknown = NSNumber(float: (self.unknown?.floatValue ?? 0) + Float(motionActivity.unknown))
			self.walking = NSNumber(float: (self.walking?.floatValue ?? 0) + Float(motionActivity.walking))
		}
	}
	
	private func divideValues(divisor: Float) {
		self.car = NSNumber(float: (self.car?.floatValue ?? 0) / divisor)
		self.cycling = NSNumber(float: (self.cycling?.floatValue ?? 0) / divisor)
		self.running = NSNumber(float: (self.running?.floatValue ?? 0) / divisor)
		self.stationary = NSNumber(float: (self.stationary?.floatValue ?? 0) / divisor)
		self.unknown = NSNumber(float: (self.unknown?.floatValue ?? 0) / divisor)
		self.walking = NSNumber(float: (self.walking?.floatValue ?? 0) / divisor)
	}
}
