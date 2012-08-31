//
//  EPCImageView.h
//
//  Created by Everton Postay Cunha on 15/05/12.
//

#import <UIKit/UIKit.h>

@class EPCImageView;
@protocol EPCImageViewDelegate <NSObject>
@optional

/*
 isFromCache can either be from EPCImageView cache or because you gave an UIImage in epcImageView:imageForURL:.
 */
- (void)epcImageView:(EPCImageView*)epcImageView isShowingImage:(UIImage*)image fromURL:(NSURL*)url isFromCache:(BOOL)isFromCache data:(NSData*)data;
/*
 When EPCImageView fails to load given URL.
 */
- (void)epcImageView:(EPCImageView*)epcImageView failedLoadingURL:(NSURL*)url;

/*
 When a internet request will start.
 */
- (void)epcImageView:(EPCImageView*)epcImageView willStartRequestForURL:(NSURL*)url;

/*
 When the internet request finishes.
 */
- (void)epcImageView:(EPCImageView*)epcImageView finishedRequestForURL:(NSURL *)url wasCancelled:(BOOL)cancelled;

/*
 You can provide an UIImage for a given URL. This will be handle as cache and will prevent the request.
 */
- (UIImage*)epcImageView:(EPCImageView*)epcImageView imageForURL:(NSURL*)url;

/*
 If EPCImageView should handle given URL, or ignore.
 */
- (BOOL)epcImageView:(EPCImageView*)epcImageView shouldHandleImageForURL:(NSURL*)url;

/*
 You can provide a frame for the default UIActivityIndicatorView.
 */
- (CGRect)epcImageView:(EPCImageView*)epcImageView frameForActivityIndicatorView:(UIActivityIndicatorView*)activityIndicatorView;
@end


@interface EPCImageView : UIImageView

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
 The delegate.
 */
@property (nonatomic, assign) IBOutlet id<EPCImageViewDelegate> delegate;

/*
 You can set your own cache. It also should work with NSMutableDictionary.
 */
@property (nonatomic, assign) NSCache *imageCache;

/*
 The image URL.
*/
@property (nonatomic, readonly) NSURL *imageURL;

/*
 Set YES to prevent UIActivityIndicatorView allocation.
*/
@property (nonatomic, readwrite) BOOL hideActivityIndicator;
@end



@interface GrabImageOperation : NSOperation
+(GrabImageOperation*)grabImageOperationWithURL:(NSURL*)url epcImageView:(EPCImageView*)epcImageView;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, assign) EPCImageView *epcImageView;
@property (nonatomic, retain) UIImage *grabbedImage;
@property (nonatomic, retain) NSData *downloadedData;
@end