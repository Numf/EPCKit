//
//  EPCVersionChecker.h
//  Renner
//
//  Created by Everton Cunha on 16/11/12.
//  Copyright (c) 2012 Ring. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EPCVersionCheckerDelegate <NSObject>
- (void)appicationBundleChangedFromVersion:(NSString*)previousVersion toVersion:(NSString*)newVersion;
@end

@interface EPCVersionChecker : NSObject

@end
