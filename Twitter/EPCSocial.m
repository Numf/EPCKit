//
//  EPCSocial.m
//
//  Created by Everton Cunha on 13/09/12.
//

#import "EPCSocial.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import <FacebookSDK/FacebookSDK.h>

@implementation EPCSocial

#pragma mark - Avaliability

+ (BOOL)canAccessTwitter {
	if (IOS_VERSION_LESS_THAN(@"6.0")) {
		return [TWTweetComposeViewController canSendTweet];
	}
	return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

+ (BOOL)canAccessFacebook {
	if (IOS_VERSION_LESS_THAN(@"6.0")) {
		return [[FBSession activeSession] isOpen];
	}
	return [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook];
}

#pragma mark - Username

+ (void)requestUsernameFromIdentifier:(NSString * const)identifier handler:(EPCSocialHandler)handler {
	NSString *username = nil;
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
	ACAccount *account = [accountsArray firstObject];
	username = account.username;
	handler(accountType.accessGranted,nil,username);
}

+ (void)requestTwitterAccountUsername:(EPCSocialHandler)handler {
	[self requestUsernameFromIdentifier:ACAccountTypeIdentifierTwitter handler:handler];
}

+ (void)RequestFacebookUsernameOnIOS5:(EPCSocialHandler)handler {
	[FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
		NSString *userName = [result isKindOfClass:[NSDictionary class]]?[result objectForKey:@"name"]:nil;
		handler(error!=nil, error, userName);
	}];
}

+ (void)requestFacebookAccountUsername:(EPCSocialHandler)handler {
	if (IOS_VERSION_LESS_THAN(@"6.0")) {
		if ([[FBSession activeSession] isOpen]) {
			[self RequestFacebookUsernameOnIOS5:handler];
		}
		else {
			[self requestAccessToFacebook:^(BOOL hasAccess, NSError *error, id data) {
				if (hasAccess) {
					[self RequestFacebookUsernameOnIOS5:handler];
				}
				else {
					handler(hasAccess, error, nil);
				}
			}];
		}
	}
	else {
		[self requestUsernameFromIdentifier:ACAccountTypeIdentifierFacebook handler:handler];
	}
}

#pragma mark - Access

+ (void)requestAccessToTwitter:(EPCSocialHandler)handler {
	[self requestAccessToAccountsWithIdentifier:ACAccountTypeIdentifierTwitter handler:^(BOOL success, NSError *error, id data) {
		handler(success, nil, nil);
	}];
}

+ (void)requestAccessToFacebook:(EPCSocialHandler)handler {
	if (IOS_VERSION_LESS_THAN(@"6.0")) {
		NSArray *permissions = [self facebookPermissions];
		BOOL publish = NO;
		for (NSString *per in permissions) {
			if ([per rangeOfString:@"publish"].location != NSNotFound) {
				publish = YES;
				break;
			}
		}
		if (publish) {
			[FBSession openActiveSessionWithPublishPermissions:permissions defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:<#(BOOL)#> completionHandler:<#^(FBSession *session, FBSessionState status, NSError *error)handler#>]
		}
		else {
			[FBSession openActiveSessionWithReadPermissions:permissions allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
				handler(status == FBSessionStateOpen, error, nil);
			}];
		}
	}
	else {
		[self requestAccessToAccountsWithIdentifier:ACAccountTypeIdentifierFacebook handler:^(BOOL success, NSError *error, id data) {
			handler(success, nil, nil);
		}];
	}
}

+ (void)requestAccessToAccountsWithIdentifier:(NSString * const)identifier handler:(EPCSocialHandler)handler {
	
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:identifier];
	
	if (IOS_VERSION_LESS_THAN(@"6.0")) {
		[accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
			handler(granted, error, accountStore);
			
			[accountStore release];
		}];
	}
	else {
		
		NSDictionary *options = nil;
		
		if (identifier == ACAccountTypeIdentifierFacebook) {
			options = [self facebookOptions];
		}
		
		[accountStore requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error) {
			handler(granted, error, accountStore);
			
			[accountStore release];
		}];
	}
}

+ (void)logoutFromFacebook:(EPCSocialHandler)handler {
	if (IOS_VERSION_LESS_THAN(@"6.0")) {
		[[FBSession activeSession] close];
		if (handler!=nil) {
			handler(YES, nil, nil);
		}
	}
	else {
		if (handler!=nil) {
			handler(YES, nil, nil);
		}
	}
}

+ (NSArray*)facebookPermissions {
	NSArray *permissions = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookPermissionsKey"];
	NSAssert(permissions != nil && [permissions isKindOfClass:[NSArray class]], @"FacebookPermissionsKey is not set or isn't an array in Info.plist");
	return permissions;
}

+ (int)facebookAudienceForIOS5 {
#warning  AUQI!
	
	FBSessionDefaultAudienceEveryone
}

+ (NSString* const)facebookAudience {
	NSString *audience = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAudienceKey"];
	if ([audience isEqualToString:@"ACFacebookAudienceEveryone"]) {
		audience = ACFacebookAudienceEveryone;
	}
	else if ([audience isEqualToString:@"ACFacebookAudienceFriends"]) {
		audience = ACFacebookAudienceFriends;
	}
	else if ([audience isEqualToString:@"ACFacebookAudienceOnlyMe"]) {
		audience = ACFacebookAudienceOnlyMe;
	}
	NSAssert(audience != nil, @"FacebookAudienceKey is not set in Info.plist");
}

+ (NSDictionary*)facebookOptions {
	NSString *facebookAppId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"];
	NSAssert(facebookAppId != nil, @"FacebookAppID is not set in Info.plist");
	
	NSString *const audience = [self facebookAudience];
	
	NSArray *permissions = [self facebookPermissions];
	
	NSDictionary *options =  @{ACFacebookAppIdKey: facebookAppId, ACFacebookPermissionsKey: permissions, ACFacebookAudienceKey: audience};
	
	return options;
}

#pragma mark - Share Content

+ (void)shareForServiceType:(NSString *)serviceType text:(NSString *)text image:(UIImage *)image url:(NSURL *)url viewController:(UIViewController *)viewController completionHandler:(EPCSocialHandler)handler {
	SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:serviceType];
	
	if (text) {
		[mySLComposerSheet setInitialText:text];
	}
	if (image) {
		[mySLComposerSheet addImage:image];
	}
	if (url) {
		[mySLComposerSheet addURL:url];
	}
	
	[mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
		
		switch (result) {
			case SLComposeViewControllerResultCancelled:
				DLog(@"Post Canceled");
				[mySLComposerSheet dismissViewControllerAnimated:YES completion:nil];
				break;
			case SLComposeViewControllerResultDone:
				DLog(@"Post Sucessful");
				break;
			default:
				break;
		}
		
		if (handler != nil) {
			handler(YES, nil, nil);
		}
	}];
	
	[viewController presentViewController:mySLComposerSheet animated:YES completion:nil];
}

+ (void)shareFacebookText:(NSString *)text image:(UIImage *)image url:(NSURL *)url viewController:(UIViewController *)viewController completionHandler:(EPCSocialHandler)handler {
	if (IOS_VERSION_LESS_THAN(@"6.0")) {
		//TODO: ios 5 aqui
	}
	else {
		[self shareForServiceType:SLServiceTypeFacebook text:text image:image url:url viewController:viewController completionHandler:handler];
	}
}

+ (void)shareTwitterText:(NSString *)text image:(UIImage *)image url:(NSURL *)url viewController:(UIViewController *)viewController completionHandler:(EPCSocialHandler)handler {
	if (IOS_VERSION_LESS_THAN(@"6.0")) {
		TWTweetComposeViewController *tweet = [[TWTweetComposeViewController alloc] initWithNibName:nil bundle:nil];
		if (url) {
			[tweet addURL:url];
		}
		if (image) {
			[tweet addImage:image];
		}
		if (text) {
			[tweet setInitialText:text];
		}
		[viewController presentViewController:tweet animated:YES completion:nil];
		[tweet release];
		
		if (handler != nil) {
			handler(YES, nil, nil);
		}
	}
	else {
		[self shareForServiceType:SLServiceTypeTwitter text:text image:image url:url viewController:viewController completionHandler:handler];
	}
}
@end
