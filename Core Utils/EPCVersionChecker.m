//
//  EPCVersionChecker.m
//  Renner
//
//  Created by Everton Cunha on 16/11/12.
//  Copyright (c) 2012 Ring. All rights reserved.
//

#import "EPCVersionChecker.h"

#define kLastVersionKey @"kLastVersionKey"

@implementation EPCVersionChecker

static id myself = nil;

+ (void)load {
	myself = [[[self class] alloc] init];
	if (myself) {
		[[NSNotificationCenter defaultCenter] addObserver:myself selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
	}
}

- (void)appDidBecomeActive {
	NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
	NSString *lastVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kLastVersionKey];
	if (![currentVersion isEqualToString:lastVersion]) {
		// version changed
		
		[[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:kLastVersionKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		id appdelegate = [[UIApplication sharedApplication] delegate];
		if ([appdelegate conformsToProtocol:@protocol(EPCVersionCheckerDelegate)]) {
			[appdelegate appicationBundleChangedFromVersion:lastVersion toVersion:currentVersion];
		}
	}
	[[NSNotificationCenter defaultCenter] removeObserver:myself name:UIApplicationDidBecomeActiveNotification object:nil];
	[myself release];
	myself = nil;
}

@end
