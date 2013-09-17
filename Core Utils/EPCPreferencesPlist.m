//
//  EPCPreferencesPlist.m
//
//  Created by Everton Cunha on 17/09/13.
//

#import "EPCPreferencesPlist.h"

@implementation EPCPreferencesPlist


+ (id)sharedInstance {
	static id obj = nil;
	if (!obj) {
		obj = [[[self class] alloc] init];
	}
	return obj;
}

- (id)objectForKey:(id)key {
	NSMutableDictionary *prefs = [self preferencesDictionary];
	
	id obj = [prefs objectForKey:key];
	
	return obj;
}

- (void)setObject:(id)object forKey:(id)key {
	if (object && key) {
		NSMutableDictionary *prefs = [self preferencesDictionary];
		
		if (self.trackChanges) {
			if (!_beforeChangesPreferences) {
				_beforeChangesPreferences = [[NSDictionary alloc] initWithDictionary:prefs copyItems:YES];
			}
		}
		
		[prefs setObject:object forKey:key];
		
		if (self.trackChanges) {
			[self updateChangesWithObject:object forKey:key];
		}
	}
}

- (void)updateChangesWithObject:(id)object forKey:(id)key {
	_changes += [self changedObject:object forKey:key];
}

- (BOOL)changedObject:(id)object forKey:(id)key {
	id before = [_beforeChangesPreferences objectForKey:key];
	if (before) {
		if ([self object:before isTheSameAs:object]) {
			return 1;
		}
		else {
			return -1;
		}
	}
	return 1;
}

- (BOOL)object:(id)obj1 isTheSameAs:(id)obj2 {
	NSAssert(NO, @"Override me %s", __PRETTY_FUNCTION__);
/*
	[obj1 isEqualToString:obj2];
*/
	return NO;
}

- (BOOL)changedPreferences {
	return _changes > 0;
}

#pragma mark - PRIVATE

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
		
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoSave) name:UIApplicationWillTerminateNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoSave) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (void)autoSave {
	if (self == [[self class] sharedInstance]) {
		[self save];
	}
}



- (NSMutableDictionary*)preferencesDictionary {
	
	if (!_preferences) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		NSString *path = [[self class] preferencesPath];
		
		NSMutableDictionary *prefs = nil;
		
		if ([fileManager fileExistsAtPath: path])
		{
			prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
		}
		
		if (!prefs) {
			prefs = [[NSMutableDictionary alloc] init];
		}
		
		_preferences = prefs;
	}
	
	return _preferences;
}

- (void)save {
	
	if (_preferences) {
		if ([self changedPreferences]) {
			
			_changes = 0;
			
			[self willChangeValueForKey:@"preferences"];
			
			[_preferences writeToFile:[[self class] preferencesPath] atomically:YES];
			
			[self didChangeValueForKey:@"preferences"];
			
			
			EPCPreferencesPlist *shared = [[self class] sharedInstance];
			
			if (self != shared) {
				shared->_changes = 0;
				[shared willChangeValueForKey:@"preferences"];
				shared->_preferences = [NSMutableDictionary dictionaryWithDictionary:_preferences];
				[shared didChangeValueForKey:@"preferences"];
			}
			
			
		}
		
	}
}

+ (NSString*)preferencesPath {
	NSAssert(NO, @"Override me %s", __PRETTY_FUNCTION__);
/*
	static id path = nil;
	if (!path) {
		NSString *documentsDirectory = [UIApplication documentsDirectoryPath];
		path = [[documentsDirectory stringByAppendingPathComponent:@"filter.plist"] copy];
	}
	return path;
 */
	return nil;
}

- (id)copy {
	NSAssert(NO, @"Override me %s", __PRETTY_FUNCTION__);
/*
	FilterPreferences *new = [[FilterPreferences alloc] init];
	new->_preferences = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
	new.trackChanges = self.trackChanges;
*/
	return nil;
}


- (NSDictionary *)preferences {
	return [[NSDictionary alloc] initWithDictionary:_preferences copyItems:YES];
}

@end
