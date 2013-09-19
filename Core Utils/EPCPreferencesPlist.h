//
//  EPCPreferencesPlist.h
//
//  Created by Everton Cunha on 17/09/13.
//

#import <Foundation/Foundation.h>
#import "EPCPreferencesSession.h"

@interface EPCPreferencesPlist : EPCPreferencesSession

/*
 MUST OVERRIDE:
 */

+ (NSString*)preferencesPath;

@end
