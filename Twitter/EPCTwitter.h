//
//  EPCTwitter.h
//
//  Created by Everton Cunha on 13/09/12.
//

#import <Foundation/Foundation.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@class EPCTwitter;

@protocol EPCTwitterDelegate <NSObject>
- (void)epcTwitterAccounts:(NSArray*)accounts;
- (void)epcTwitterAccountsDeniedWithError:(NSError*)error;
@end

@interface EPCTwitter : NSObject

+ (BOOL)canSendTweet;

+ (void)twitterAccountsFor:(NSObject<EPCTwitterDelegate>*)delegate;

@end
