//
//  EPCTwitter.m
//
//  Created by Everton Cunha on 13/09/12.
//

#import "EPCTwitter.h"

@implementation EPCTwitter

+ (BOOL)canSendTweet {
	return [TWTweetComposeViewController canSendTweet];
}

+ (void)twitterAccountsFor:(NSObject<EPCTwitterDelegate>*)delegate {
	
	[delegate retain];
	
	// Create an account store object.
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	
	// Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	[accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
		if ([delegate retainCount] > 1) {
			if(granted) {
				// Get the list of Twitter accounts.
				NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
				[delegate performSelectorOnMainThread:@selector(epcTwitterAccounts:) withObject:accountsArray waitUntilDone:YES];
			}
			else {
				DLog(@"%s Error: %@", __PRETTY_FUNCTION__, [error description]);
				[delegate performSelectorOnMainThread:@selector(epcTwitterAccountsDeniedWithError:) withObject:error waitUntilDone:YES];
			}
		}
		
		[delegate release];
		[accountStore release];
	}];
}

@end
