// https://gist.github.com/pkclsoft/4958148

#import <CoreData/CoreData.h>

@interface NSManagedObject (Serialization)

- (NSDictionary*) toDictionary;

- (void) populateFromDictionary:(NSDictionary*)dict;

+ (NSManagedObject*) createManagedObjectFromDictionary:(NSDictionary*)dict
                                             inContext:(NSManagedObjectContext*)context;

@end