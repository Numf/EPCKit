//
//  EPCImageView.h
//
//  Created by Everton Postay Cunha on 15/05/12.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@class EPCImageView;
@protocol EPCImageViewDelegate <NSObject>
@optional
- (void)epcImageView:(EPCImageView*)epcImageView isShowingImage:(UIImage*)image fromURL:(NSURL*)url isFromCache:(BOOL)isFromCache data:(NSData*)data;
- (void)epcImageView:(EPCImageView*)epcImageView failedLoadingURL:(NSURL*)url;
- (BOOL)epcImageView:(EPCImageView*)epcImageView shouldHandleImageForURL:(NSURL*)url;
- (UIImage*)epcImageView:(EPCImageView*)epcImageView imageForURL:(NSURL*)url;
- (CGRect)epcImageView:(EPCImageView*)epcImageView frameForActivityIndicatorView:(UIActivityIndicatorView*)activityIndicatorView;
@end

@interface EPCImageView : UIImageView <ASIHTTPRequestDelegate> {
	UIActivityIndicatorView *actView;
	ASIHTTPRequest *request;
	NSURL *currentURL;
}

/*
 Default singleton to cache the downloaded images.
 */
+ (NSCache*)imageCache;

/*
 Retry last URL.
 */
- (BOOL)retry;

/*
 Set the URL from the image to be loaded. Set to nil when you want to clear the current image.
 */
- (void)setImageByURL:(NSURL*)url;

/*
 You can set your own cache. It also should work with NSMutableDictionary.
 */
@property (nonatomic, assign) NSCache *imageCache;

/*
 The delegate.
 */
@property (nonatomic, assign) IBOutlet id<EPCImageViewDelegate> delegate;
@end
