//
//  BSCWeatherContext+CoreDataProperties.swift
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

extension BSCWeatherContext {

    @NSManaged var dayMaxTemperature: NSNumber?
    @NSManaged var dayMinTemperature: NSNumber?
    @NSManaged var humidity: NSNumber?
    @NSManaged var isDaylight: NSNumber?
    @NSManaged var temperature: NSNumber?
    @NSManaged var visibility: NSNumber?
    @NSManaged var windSpeed: NSNumber?
    @NSManaged var context: BSCContext?
	@NSManaged var yWeatherConditions: [String]?
	@NSManaged var yWeatherConditionCodes: [NSNumber]?

}
