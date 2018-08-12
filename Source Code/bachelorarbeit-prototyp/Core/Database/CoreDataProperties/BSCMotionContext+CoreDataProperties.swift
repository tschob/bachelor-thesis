//
//  BSCMotionContext+CoreDataProperties.swift
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

extension BSCMotionContext {

    @NSManaged var car: NSNumber?
    @NSManaged var cycling: NSNumber?
    @NSManaged var running: NSNumber?
    @NSManaged var stationary: NSNumber?
    @NSManaged var unknown: NSNumber?
    @NSManaged var walking: NSNumber?
    @NSManaged var context: BSCContext?

}
