//
//  BSCLocationCoordinates+CoreDataProperties.swift
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

extension BSCLocationCoordinates {

    @NSManaged var accuracy: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var context: BSCContext?

}
