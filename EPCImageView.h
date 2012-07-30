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
@end

@interface EPCImageView : UIImageView <ASIHTTPRequestDelegate> {
	UIActivityIndicatorView *actView;
	ASIHTTPRequest *request;
	NSURL *currentURL;
}

- (void)setImageByURL:(NSURL*)url;

+ (NSCache*)imageCache;

@property (nonatomic, assign) NSCache *imageCache;
@property (nonatomic, assign) IBOutlet id<EPCImageViewDelegate> delegate;
@end
