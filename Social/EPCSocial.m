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
		ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
		ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
		return accountType.accessGranted;
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
		handler(error==nil, error, userName);
	}];
}

+ (void)requestFacebookAccountUsername:(EPCSocialHandler)handler {
	if (IOS_VERSION_LESS_THAN(@"6.0")) {
		if ([[FBSession activeSession] isOpen]) {
			[self RequestFacebookUsernameOnIOS5:handler];
		}
		else {
			[self requestAccessToFacebookShowingUI:NO handler:^(BOOL hasAccess, NSError *error, id data) {
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

+ (void)askForFacebookPublishPermissionsOnIOS5ShowingUI:(BOOL)showUI handler:(EPCSocialHandler)handler {
	NSArray *publishPermissions = [self facebookPublishPermissions];
	NSAssert([publishPermissions count] > 0, @"FacebookPublishPermissionsKey or FacebookReadPermissionsKey must be set in Info.plist");
	[FBSession openActiveSessionWithPublishPermissions:publishPermissions defaultAudience:[self facebookAudienceForIOS5] allowLoginUI:showUI completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
		if (handler != nil) {
			handler(status == FBSessionStateOpen, error, nil);
		}
	}];
}

+ (void)requestAccessToFacebookShowingUI:(BOOL)showUI handler:(EPCSocialHandler)handler; {
	if (IOS_VERSION_LESS_THAN(@"6.0")) {
		NSArray *readPermissions = [self facebookReadPermissions];
		
		if ([readPermissions count] == 0) {
			// no read permissions
			[self askForFacebookPublishPermissionsOnIOS5ShowingUI:showUI handler:handler];
		}
		else {
			// ask for read permissions
			[FBSession openActiveSessionWithReadPermissions:readPermissions allowLoginUI:showUI completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
				
				NSArray *publishPermissions = [self facebookPublishPermissions];
				
				if (status == FBSessionStateOpen && [publishPermissions count] > 0) {
					// after read is granted, ask for publish
					[self askForFacebookPublishPermissionsOnIOS5ShowingUI:showUI handler:handler];
				}
				else {
					if (handler != nil) {
						handler(status == FBSessionStateOpen, error, nil);
					}
				}
			}];
		}
	}
	else {
		[self requestAccessToAccountsWithIdentifier:ACAccountTypeIdentifierFacebook handler:^(BOOL success, NSError *error, id data) {
			if (handler != nil) {
				handler(success, nil, nil);
			}
		}];
	}
}

+ (void)askForFacebookPublishPermissionsAccountStore:(ACAccountStore*)accountStore accountType:(ACAccountType*)accountType options:(NSDictionary*)options handler:(EPCSocialHandler)handler {
	[accountStore requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error) {
		handler(granted, error, accountStore);
	}];
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
			
			// Facebook
			
			NSArray *readPermissions = [self facebookReadPermissions];
			
			NSArray *publishPermissions = [self facebookPublishPermissions];
			
			if ([readPermissions count] == 0) {
				// no read permissions, ask for publish
				NSAssert([publishPermissions count] > 0, @"FacebookPublishPermissionsKey or FacebookReadPermissionsKey must be set in Info.plist");
				options = [self facebookOptionsForPermissions:publishPermissions];
				[self askForFacebookPublishPermissionsAccountStore:accountStore accountType:accountType options:options handler:^(BOOL success, NSError *error, id data) {
					handler(success, error, accountStore);
					[accountStore release];
				}];
				
			}
			else {
				// ask for read
				options = [self facebookOptionsForPermissions:readPermissions];
				[self askForFacebookPublishPermissionsAccountStore:accountStore accountType:accountType options:options handler:^(BOOL success, NSError *error, id data) {
					if (success && [publishPermissions count] > 0) {
						// read granted, ask for publish
						[self askForFacebookPublishPermissionsAccountStore:accountStore accountType:accountType options:options handler:^(BOOL success, NSError *error, id data) {
							handler(success, error, accountStore);
							[accountStore release];
						}];
					}
					else {
						handler(success, error, accountStore);
						[accountStore release];
					}
				}];
			}
			
		}
		else {
			
			// Twitter
			
			[accountStore requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error) {
				handler(granted, error, accountStore);
				
				[accountStore release];
			}];
		}
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

+ (NSArray*)facebookPublishPermissions {
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookPublishPermissionsKey"];
}

+ (NSArray*)facebookReadPermissions {
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookReadPermissionsKey"];
}

+ (int)facebookAudienceForIOS5 {
	NSString *audience = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAudienceKey"];
	NSAssert(audience != nil, @"FacebookAudienceKey is not set in Info.plist");
	int result = FBSessionDefaultAudienceNone;
	if ([audience isEqualToString:@"ACFacebookAudienceEveryone"]) {
		result = FBSessionDefaultAudienceEveryone;
	}
	else if ([audience isEqualToString:@"ACFacebookAudienceFriends"]) {
		result = FBSessionDefaultAudienceFriends;
	}
	else if ([audience isEqualToString:@"ACFacebookAudienceOnlyMe"]) {
		result = FBSessionDefaultAudienceOnlyMe;
	}
	return result;
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
	
	return audience;
}

+ (NSDictionary*)facebookOptionsForPermissions:(NSArray*)permissions {
	NSString *facebookAppId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"];
	NSAssert(facebookAppId != nil, @"FacebookAppID is not set in Info.plist");
	
	NSString *const audience = [self facebookAudience];
	
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
		NSMutableDictionary* params = [NSMutableDictionary dictionary];
		NSString *graphPath = @"me/feed";
		if (text) {
			[params setObject:text forKey:@"message"];
		}
		if (image) {
			NSData *data = UIImagePNGRepresentation(image);
			if (data) {
				[params setObject:UIImagePNGRepresentation(image) forKey:@"picture"];
				graphPath = @"me/photos";
			}
		}
		if (url) {
			[params setObject:[url absoluteString] forKey:@"link"];
		}
		
		[FBRequestConnection startWithGraphPath:graphPath parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
		 {
			 DLog(@"%@ %@ %@", connection, result, error);
			 if (handler != nil) {
				 handler(error==nil, error, result);
			 }
		 }];
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
