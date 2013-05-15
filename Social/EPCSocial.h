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

/*
 On iOS 5 the handler will receive every state change.
 */
+ (void)requestAccessToFacebookShowingUI:(BOOL)showUI handler:(EPCSocialHandler)handler;

+ (void)requestFacebookAccountUsername:(EPCSocialHandler)handler;

+ (void)shareFacebookText:(NSString *)text image:(UIImage *)image url:(NSURL*)url viewController:(UIViewController*)viewController completionHandler:(EPCSocialHandler)handler;

/*
 For iOS 6 it returns YES but does nothing.
 */
+ (void)logoutFromFacebook:(EPCSocialHandler)handler;

@end
