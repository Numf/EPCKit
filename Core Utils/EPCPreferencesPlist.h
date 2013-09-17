//
//  EPCPreferencesPlist.h
//
//  Created by Everton Cunha on 17/09/13.
//

#import <Foundation/Foundation.h>

@interface EPCPreferencesPlist : NSObject {
	NSMutableDictionary *_preferences;
	NSDictionary *_beforeChangesPreferences;
	int _changes;
}

@property (readwrite,nonatomic) BOOL trackChanges;

+ (id)sharedInstance;

- (NSDictionary*)preferences;

- (void)save;

- (void)setObject:(id)object forKey:(id)key;

- (id)objectForKey:(id)key;

/*
 MUST OVERRIDE:
 */
- (BOOL)object:(id)obj1 isTheSameAs:(id)obj2;

+ (NSString*)preferencesPath;

@end
