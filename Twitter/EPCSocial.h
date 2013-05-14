//
//  EPCSocial.h
//
//  Created by Everton Cunha on 13/09/12.
//
//  For iOS 5 or later

#import <Foundation/Foundation.h>

typedef void (^EPCSocialHandler)(BOOL success, NSError *error, id data);

@class EPCSocial;

@interface EPCSocial : NSObject

#pragma mark - Twitter

+ (BOOL)canAccessTwitter;

+ (void)requestAccessToTwitter:(EPCSocialHandler)handler;

+ (void)requestTwitterAccountUsername:(EPCSocialHandler)handler;

+ (void)shareTwitterText:(NSString *)text image:(UIImage *)image url:(NSURL*)url viewController:(UIViewController*)viewController completionHandler:(EPCSocialHandler)handler;

#pragma mark - Facebook

+ (BOOL)canAccessFacebook;

+ (void)requestAccessToFacebook:(EPCSocialHandler)handler;

+ (void)requestFacebookAccountUsername:(EPCSocialHandler)handler;

+ (void)shareFacebookText:(NSString *)text image:(UIImage *)image url:(NSURL*)url viewController:(UIViewController*)viewController completionHandler:(EPCSocialHandler)handler;

+ (void)logoutFromFacebook:(EPCSocialHandler)handler; // return YES for iOS 6 or later, but does nothing

@end
