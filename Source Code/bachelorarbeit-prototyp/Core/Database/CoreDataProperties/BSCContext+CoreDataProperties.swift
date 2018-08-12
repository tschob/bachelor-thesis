//
//  BSCContext+CoreDataProperties.swift
//  
//
//  Created by Hans Seiffert on 15.02.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension BSCContext {

    @NSManaged var avAudioSessionOutputPorts: [String]?
    @NSManaged var countries: [String]?
    @NSManaged var endDate: NSDate?
	@NSManaged var label: String?
    @NSManaged var startDate: NSDate?
    @NSManaged var wifiSSIDs: [String]?
    @NSManaged var applicationIsInForeground: NSNumber?
    @NSManaged var deviceIsLocked: NSNumber?
    @NSManaged var reachableViaWWAN: NSNumber?
    @NSManaged var screenBrightness: NSNumber?
    @NSManaged var volume: NSNumber?
    @NSManaged var locationCoordinates: NSSet?
    @NSManaged var weatherContext: BSCWeatherContext?
    @NSManaged var motionContext: BSCMotionContext?

}
