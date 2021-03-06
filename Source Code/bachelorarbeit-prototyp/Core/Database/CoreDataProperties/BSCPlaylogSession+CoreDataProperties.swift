//
//  BSCPlaylogSession+CoreDataProperties.swift
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

extension BSCPlaylogSession {

    @NSManaged var endDate: NSDate?
    @NSManaged var startDate: NSDate?
    @NSManaged var sessionContext: BSCSessionContext?
    @NSManaged var playlogSongs: NSSet?

}
