#import "NSManagedObject+Serialization.h"
#import <CoreLocation/CoreLocation.h>
#import <DKHelper/DKHelper.h>

@implementation NSManagedObject (Serialization)

#define DATE_ATTR_PREFIX @"dAtEaTtr:"
#define RELATIONSHIP_ATTR_PREFIX @"rElAtInShIp:"

#pragma mark -
#pragma mark Dictionary conversion methods

- (NSDictionary*) toDictionaryWithTraversalHistory:(NSMutableArray*)traversalHistory {
	NSArray* attributes = [[[self entity] attributesByName] allKeys];
	NSArray* relationships = [[[self entity] relationshipsByName] allKeys];
	NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:
								 [attributes count] + [relationships count] + 1];
	
	NSMutableArray *localTraversalHistory = nil;
	
	if (traversalHistory == nil) {
		localTraversalHistory = [NSMutableArray arrayWithCapacity:[attributes count] + [relationships count] + 1];
	} else {
		localTraversalHistory = traversalHistory;
	}
	
	[localTraversalHistory addObject:self];
	
	[dict setObject:[[self class] description] forKey:@"class"];
	
	for (NSString* attr in attributes) {
		NSObject* value = [self valueForKey:attr];
		
		if (value != nil) {
			if ([value isKindOfClass:[NSDate class]]) {
				NSDate *date = (NSDate*) value;
				NSString *dateAttr = [NSString stringWithFormat:@"%@%@", DATE_ATTR_PREFIX, attr];
				[dict setObject:[date ISO8601StringValue] forKey:dateAttr];
			} else {
				[dict setObject:value forKey:attr];
			}
		}
	}
	
	for (NSString* relationship in relationships) {
		NSObject* value = [self valueForKey:relationship];
		
		NSString *relationshipKey = [NSString stringWithFormat:@"%@%@", RELATIONSHIP_ATTR_PREFIX, relationship];

		if ([value isKindOfClass:[NSSet class]]) {
			// To-many relationship
			
			// The core data set holds a collection of managed objects
			NSSet* relatedObjects = (NSSet*) value;
			
			// Our set holds a collection of dictionaries
			NSMutableArray* dictSet = [NSMutableArray arrayWithCapacity:[relatedObjects count]];
			
			for (NSManagedObject* relatedObject in relatedObjects) {
				if ([localTraversalHistory containsObject:relatedObject] == NO) {
					[dictSet addObject:[relatedObject toDictionaryWithTraversalHistory:localTraversalHistory]];
				}
			}
			
			[dict setObject:[NSArray arrayWithArray:dictSet] forKey:relationshipKey];
		}
		else if ([value isKindOfClass:[NSManagedObject class]]) {
			// To-one relationship
			
			NSManagedObject* relatedObject = (NSManagedObject*) value;
			
			if ([localTraversalHistory containsObject:relatedObject] == NO) {
				// Call toDictionary on the referenced object and put the result back into our dictionary.
				[dict setObject:[relatedObject toDictionaryWithTraversalHistory:localTraversalHistory] forKey:relationshipKey];
			}
		}
	}
	
	if (traversalHistory == nil) {
		[localTraversalHistory removeAllObjects];
	}
	
	return dict;
}

- (NSDictionary*) toDictionary {
	return [self toDictionaryWithTraversalHistory:nil];
}

+ (id) decodedValueFrom:(id)codedValue forKey:(NSString*)key {
	if ([key hasPrefix:DATE_ATTR_PREFIX] == YES) {
		return [NSDate dateFromISOString:codedValue];
	} else {
		// This is an attribute
		return codedValue;
	}
}

- (void) populateFromDictionary:(NSDictionary*)dict
{
	NSManagedObjectContext* context = [self managedObjectContext];
	
	for (NSString* key in dict) {
		if ([key isEqualToString:@"class"]) {
			continue;
		}
		
		NSObject* value = [dict objectForKey:key];
		
		if ([key containsString:RELATIONSHIP_ATTR_PREFIX] == YES) {
			// This is a relationship
			NSString *newKey = [key stringByReplacingOccurrencesOfString:RELATIONSHIP_ATTR_PREFIX withString:@""];
			if ([value isKindOfClass:[NSDictionary class]]) {
				// This is a to-one relationship
				NSManagedObject* relatedObject =
				[NSManagedObject createManagedObjectFromDictionary:(NSDictionary*)value
														 inContext:context];
				
				newKey = [newKey stringByReplacingOccurrencesOfString:DATE_ATTR_PREFIX withString:@""];
				[self setValue:relatedObject forKey:newKey];
			} else if ([value isKindOfClass:[NSArray class]]) {
				// This is a to-many relationship
				NSArray* relatedObjectDictionaries = (NSArray*) value;
				
				// Get a proxy set that represents the relationship, and add related objects to it.
				// (Note: this is provided by Core Data)
				NSMutableSet* relatedObjects = [self mutableSetValueForKey:newKey];
				
				for (NSDictionary* relatedObjectDict in relatedObjectDictionaries) {
					NSManagedObject* relatedObject =
					[NSManagedObject createManagedObjectFromDictionary:relatedObjectDict
															 inContext:context];
					[relatedObjects addObject:relatedObject];
				}
			}
		} else if (value != nil) {
			NSString *newKey = [key stringByReplacingOccurrencesOfString:DATE_ATTR_PREFIX withString:@""];
			newKey = [newKey stringByReplacingOccurrencesOfString:RELATIONSHIP_ATTR_PREFIX withString:@""];
			[self setValue:[NSManagedObject decodedValueFrom:value forKey:key] forKey:newKey];
		}
	}
}

+ (NSManagedObject*) createManagedObjectFromDictionary:(NSDictionary*)dict
											 inContext:(NSManagedObjectContext*)context
{
	NSString* class = [dict objectForKey:@"class"];
	
	NSManagedObject* newObject =
	(NSManagedObject*)[NSEntityDescription insertNewObjectForEntityForName:class
													inManagedObjectContext:context];
	
	[newObject populateFromDictionary:dict];
	
	return newObject;
}

@end
