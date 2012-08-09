//
//  EPCCategories.h
//
//  Created by Everton Postay Cunha on 25/07/12.
//

#import <UIKit/UIKit.h>

@interface UIView (EPCCategories)

+ (id)loadFromNib;

@property (nonatomic) CGPoint frameOrigin;
@property (nonatomic) CGSize frameSize;

@property (nonatomic) CGFloat frameX;
@property (nonatomic) CGFloat frameY;

@property (nonatomic) CGFloat frameWidth;
@property (nonatomic) CGFloat frameHeight;

@end

@interface UIWebView (EPCCategories)
- (void)adjustToHeight;
- (void)disableScroll;
- (UIScrollView*)webScrollView;
- (void)ajustToHeightAndStopBouncing;
@end

@interface NSString (EPCCategories)
- (NSString*)md5;
@end