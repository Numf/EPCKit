//
//  EPCCoreDataDAO.m
//
//  Created by Everton Cunha on 18/10/12.
//

#import "EPCCoreDataDAO.h"
#import "EPCCategories.h"
#import <CoreData/CoreData.h>
#import "EPCCoreDataCategories.h"

#define DB_FOLDER @"Databases"

@interface EPCCoreDataDAO() {
	NSManagedObjectContext *__managedObjectContext;
	NSPersistentStoreCoordinator *__persistentStoreCoordinator;
	NSManagedObjectModel *__managedObjectModel;
}
@end

@implementation EPCCoreDataDAO

- (BOOL)databaseExists {
	NSString *path = [[UIApplication documentsDirectoryPath] stringByAppendingFormat:@"%@/%@", DB_FOLDER, [self databaseFileName]];
	return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (NSManagedObjectContext *)managedObjectContext
{
	assert([[NSThread currentThread] isMainThread]);
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
	NSPersistentStoreCoordinator *persistentStore = [self persistentStoreCoordinator];
	if (!persistentStore) // error
		return nil;
	
    NSPersistentStoreCoordinator *coordinator = persistentStore;
	
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
	assert([[NSThread currentThread] isMainThread]);
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:[self databaseModelName] withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectoryURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", DB_FOLDER, [self databaseFileName]]];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
#ifdef DEBUG
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
        return nil;
    }
    
    return __persistentStoreCoordinator;
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectoryURL
{
	return [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] copy];
}

#pragma mark - Fetching

- (NSArray*)fetchWithEntity:(NSString*)entity orderBy:(NSString*)order predicate:(NSPredicate*)predicate {
	NSManagedObjectContext *context =[self managedObjectContext];
	if (context) {
		NSArray *array = nil;
		@try {
			array = [context fetchObjectsForEntityName:entity orderBy:order ascending:YES withPredicate:predicate];
		}
		@catch (NSException *exception) {
			array = nil;
			DLog([exception description]);
		}
		return array;
	}
	return nil;
}

#pragma mark - Override

- (NSString*)databaseFileName {
	assert(NO);
	return nil;
}

- (NSString*)databaseModelName {
	assert(NO);
	return nil;
}

@end
