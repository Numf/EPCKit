//
//  EPCCoreDataCategories.h
//
//  Created by Everton Cunha on 13/08/12.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (EPCCoreDataCategories)
- (NSSet *)fetchObjectsForEntityName:(NSString *)newEntityName
					   withPredicate:(id)stringOrPredicate, ...;
@end
