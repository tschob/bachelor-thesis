//  https://gist.github.com/advantis/7642084
//  Copyright © 2013 Yuri Kotov
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (ADVCopying)

- (instancetype) adv_copyInContext:(NSManagedObjectContext *)context;

@end