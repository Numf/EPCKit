//
//  EPCUniqueIdentifier.m
//  ecobeneficios
//
//  Created by Everton Cunha on 21/01/13.
//
//

#import "EPCUniqueIdentifier.h"
#import "KeychainItemWrapper.h"

#define kUUID @"kUUID"

@implementation EPCUniqueIdentifier

+ (NSString *)uniqueIdentifier {
	static id obj = nil;
	if (!obj) {
		obj = [self grabUniqueIdentifier];
	}
	return obj;
}

+ (NSString*)grabUniqueIdentifier {
	NSString *uid = [self uniqueIdentifierStoredOnKeyChain];
	if(!uid) {
		uid = [self generateNewUniqueIdentifier];
		[self storeUniqueIdentifierOnKeyChain:uid];
	}
	return uid;
}

+ (NSString*)generateNewUniqueIdentifier {
	// Create universally unique identifier (object)
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    // Get the string representation of CFUUID object.
    NSString *uuidStr = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
    CFRelease(uuidObject);
	return uuidStr;
}

+ (NSString*)uniqueIdentifierStoredOnKeyChain {
	KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:kUUID accessGroup:nil];
	NSString *uuid = [[keychainItem objectForKey:(id)kUUID] copy];
	[keychainItem release];
	return uuid;
}

+(void)storeUniqueIdentifierOnKeyChain:(NSString*)uuid {
	KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:kUUID accessGroup:nil];
	[keychainItem setObject:uuid forKey:(id)kUUID];
	[keychainItem release];
}

@end
