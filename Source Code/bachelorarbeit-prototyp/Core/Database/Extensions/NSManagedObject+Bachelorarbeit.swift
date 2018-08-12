//
//  BSC.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 29.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {

	/**
	Create an object which isn't inserted to any managed object context.
	
	- returns: The Object with a nil context.
	*/
	class func unpersistedEntity() -> Self {
		if let entityDescription = self.MR_entityDescription() {
			return self.init(entity: entityDescription, insertIntoManagedObjectContext: nil)
		} else {
			fatalError("Unpersisted entity can't be created")
		}
	}
	
	
	/**
	Create an peristed copy from the unpersited object. The copy will only be created if a nil managedObjectContext is the current one.
	
	- returns: The copied and inserted Object.
	*/
	func persistedEntity(managedObjectContext: NSManagedObjectContext) -> Self? {
		if (self.managedObjectContext == nil) {
			return self.adv_copyInContext(managedObjectContext)
		} else {
			BSCLog(Verbose.Error, "Error: \(self) has already an managed object context: \(self.managedObjectContext)")
			return nil
		}
	}
	
	// Im- / Export
	
	class func createEntitiesFromDictionaryArray(allDicts: [AnyObject]) {
		let context = NSManagedObjectContext.MR_context()
		for dict in allDicts {
			if let _dict = dict as? [NSObject: AnyObject] {
				self.createManagedObjectFromDictionary(_dict, inContext: context)
			}
		}
		context.MR_saveToPersistentStoreAndWait()
	}
	
	class func jsonExport() -> NSData? {
		if let allObjects = self.MR_findAll() {
			// Collect the dictionaries for all objects
			var allDictionaries = [[NSObject: AnyObject]]()
			for object in allObjects {
				let json = object.toDictionary()
				allDictionaries.append(json)
			}
			// Convert the array to json data
			do {
				let jsonData = try NSJSONSerialization.dataWithJSONObject(allDictionaries, options: NSJSONWritingOptions.PrettyPrinted)
				return jsonData
			} catch {
				return nil
			}
		}
		return nil
	}
}