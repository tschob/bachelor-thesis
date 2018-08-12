//
//  BSCPlaylogSong+CoreDataProperties.swift
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

extension BSCPlaylogSong {

    @NSManaged var endDate: NSDate?
    @NSManaged var playedDuration: NSNumber?
    @NSManaged var startDate: NSDate?
    @NSManaged var context: BSCSongContext?
    @NSManaged var session: BSCPlaylogSession?
    @NSManaged var songInfo: BSCSongInfo?

}
