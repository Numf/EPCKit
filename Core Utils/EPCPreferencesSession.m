//
//  EPCPreferencesSession.m
//  Aqui-Imoveis-iOS
//
//  Created by Everton Cunha on 19/09/13.
//  Copyright (c) 2013 Ring. All rights reserved.
//

#import "EPCPreferencesSession.h"

@implementation EPCPreferencesSession


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
	[self willChangeValueForKey:@"hasChanges"];
	_changes += [self changedObject:object forKey:key];
	[self didChangeValueForKey:@"hasChanges"];
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

- (BOOL)hasChanges {
	return _changes > 0;
}

- (BOOL)object:(id)obj1 isTheSameAs:(id)obj2 {
	NSAssert(NO, @"Override me %s", __PRETTY_FUNCTION__);
	/*
	 [obj1 isEqualToString:obj2];
	 */
	return NO;
}

#pragma mark - PRIVATE

- (NSMutableDictionary*)preferencesDictionary {
	if (!_preferences) {
		_preferences = [[NSMutableDictionary alloc] init];
	}
	return _preferences;
}

- (void)save {
	
	if (_preferences) {
		if ([self hasChanges]) {
			
			_changes = 0;
			_beforeChangesPreferences = nil;
			
			EPCPreferencesSession *shared = [[self class] sharedInstance];
			
			if (self != shared) {
				shared->_changes = 0;
				shared->_beforeChangesPreferences = nil;
				[shared willChangeValueForKey:@"preferences"];
				shared->_preferences = [NSMutableDictionary dictionaryWithDictionary:_preferences];
				[shared didChangeValueForKey:@"preferences"];
			}
			
			
		}
		
	}
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

- (void)clearSession {
	_changes = 0;
	_beforeChangesPreferences = nil;
	_preferences = nil;
}
@end