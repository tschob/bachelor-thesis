//
//  BSCSongInfo+CoreDataProperties.swift
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

extension BSCSongInfo {

    @NSManaged var albumTitle: String?
    @NSManaged var artistName: String?
    @NSManaged var duration: NSNumber?
    @NSManaged var genre: String?
    @NSManaged var persistentID: NSNumber?
    @NSManaged var title: String?
    @NSManaged var playlogSongs: NSSet?

}
