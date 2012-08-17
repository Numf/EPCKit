//
//  EPCCoreDataCategories.m
//
//  Created by Everton Cunha on 13/08/12.
//

#import "EPCCoreDataCategories.h"

@implementation NSManagedObjectContext (EPCCoreDataCategories)
- (NSSet *)fetchObjectsForEntityName:(NSString *)newEntityName
					   withPredicate:(id)stringOrPredicate, ... {
	if (stringOrPredicate)
    {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]])
        {
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate
											   arguments:variadicArguments];
            va_end(variadicArguments);
        }
        else
        {
            NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
					  @"Second parameter passed to %s is of unexpected class %@",
					  sel_getName(_cmd), NSStringFromClass([stringOrPredicate class]));
            predicate = (NSPredicate *)stringOrPredicate;
        }
		stringOrPredicate = predicate;
    }
	
	NSArray *array = [self fetchObjectsForEntityName:newEntityName sortDescriptors:nil withPredicate:stringOrPredicate];
	if (array)
		return [NSSet setWithArray:array];
	return nil;
}
- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
					 sortDescriptors:(NSArray*)sortDescriptors
					   withPredicate:(id)stringOrPredicate, ...
{
    NSEntityDescription *entity = [NSEntityDescription
								   entityForName:newEntityName inManagedObjectContext:self];
	
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entity];
	if (sortDescriptors)
		[request setSortDescriptors:sortDescriptors];
	
    if (stringOrPredicate)
    {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]])
        {
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate
											   arguments:variadicArguments];
            va_end(variadicArguments);
        }
        else
        {
            NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
					  @"Second parameter passed to %s is of unexpected class %@",
					  sel_getName(_cmd), NSStringFromClass([stringOrPredicate class]));
            predicate = (NSPredicate *)stringOrPredicate;
        }
        [request setPredicate:predicate];
    }
	
    NSError *error = nil;
    NSArray *results = [self executeFetchRequest:request error:&error];
    if (error != nil)
    {
        [NSException raise:NSGenericException format:@"%@",[error description]];
    }
	
	if ([results count] > 0)
		return results;
	return nil;
}

- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
							   orderBy:(NSString*)orderBy
							 ascending:(BOOL)ascending
						 withPredicate:(id)stringOrPredicate, ... {
	
	if (stringOrPredicate)
    {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]])
        {
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate
											   arguments:variadicArguments];
            va_end(variadicArguments);
        }
        else
        {
            NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
					  @"Second parameter passed to %s is of unexpected class %@",
					  sel_getName(_cmd), NSStringFromClass([stringOrPredicate class]));
            predicate = (NSPredicate *)stringOrPredicate;
        }
		stringOrPredicate = predicate;
    }
	
	if (orderBy)
		return [self fetchObjectsForEntityName:newEntityName sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:orderBy ascending:ascending]] withPredicate:stringOrPredicate];
	return [self fetchObjectsForEntityName:newEntityName sortDescriptors:nil withPredicate:stringOrPredicate];
}
@end
