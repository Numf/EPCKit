//
//  EPCCoreDataCategories.h
//
//  Created by Everton Cunha on 13/08/12.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (EPCCoreDataCategories)
- (NSSet *)fetchObjectsForEntityName:(NSString *)newEntityName
					   withPredicate:(id)stringOrPredicate, ...;

- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
					 sortDescriptors:(NSArray*)sortDescriptors
					   withPredicate:(id)stringOrPredicate, ...;

- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
							   orderBy:(NSString*)orderBy
							 ascending:(BOOL)ascending
						 withPredicate:(id)stringOrPredicate, ...;
@end
