//  https://gist.github.com/advantis/7642084
//  Copyright © 2013 Yuri Kotov
//

#import "NSManagedObject+ADVCopying.h"

@implementation NSManagedObject (ADVCopying)

- (instancetype) adv_copyInContext:(NSManagedObjectContext *)context
{
    return [self adv_copyInContext:context withCache:[NSMutableDictionary new]];
}

- (instancetype) adv_copyInContext:(NSManagedObjectContext *)context withCache:(NSMutableDictionary *)cache
{
    NSManagedObject *copy;

    copy = cache[self.objectID];
    if (copy) return copy;

    copy = [[NSManagedObject alloc] initWithEntity:self.entity insertIntoManagedObjectContext:context];
    cache[self.objectID] = copy;

    // Attributes
    NSArray *keys = [[self.entity attributesByName] allKeys];
    NSDictionary *attributes = [self dictionaryWithValuesForKeys:keys];
    [copy setValuesForKeysWithDictionary:attributes];

    // Relationships
    NSDictionary *relationships = [self.entity relationshipsByName];
    if (0 == relationships.count) return copy;
    id enumerator = ^(NSString *key, NSRelationshipDescription *relationship, BOOL *stop)
    {
        if ([relationship isToMany])
        {
            // TODO: Add support for ordered relationships
            NSMutableSet *sourceSet = [self mutableSetValueForKey:key];
            NSMutableSet *targetSet = [copy mutableSetValueForKey:key];
            for (NSManagedObject *value in sourceSet)
            {
                [targetSet addObject:[value adv_copyInContext:context withCache:cache]];
            }
        }
        else
        {
            NSManagedObject *value = [self valueForKey:key];
            value = [value adv_copyInContext:context withCache:cache];
            [copy setValue:value forKey:key];
        }
    };
    [relationships enumerateKeysAndObjectsUsingBlock:enumerator];

    return copy;
}

@end