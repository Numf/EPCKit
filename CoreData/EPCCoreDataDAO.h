//
//  EPCCoreDataDAO.h
//
//  Created by Everton Cunha on 18/10/12.
//

/*
 You should override:
- (NSString*)databaseFileName {
	return @"mydb.sqlite";
}
 
- (NSString*)databaseModelName {
	return @"mydbmodel";
}
 */

#import <Foundation/Foundation.h>

@interface EPCCoreDataDAO : NSObject

/*
 Override this. The db file name, like 'mydb.sqlite'.
 */
- (NSString*)databaseFileName;

/*
 Override this. The db model name, like 'mydbmodel', without extension.
 */
- (NSString*)databaseModelName;

/*
 Method for fetching.
 */
- (NSArray*)fetchWithEntity:(NSString*)entity orderBy:(NSString*)order predicate:(NSPredicate*)predicate;
@end
