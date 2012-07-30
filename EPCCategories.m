//
//  EPCCategories.m
//
//  Created by Everton Postay Cunha on 25/07/12.
//

#import "EPCCategories.h"

@implementation UIView (EPCCategories)
+ (id)loadFromNib {
	return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
}
- (CGPoint)frameOrigin {
	return self.frame.origin;
}
- (void)setFrameOrigin:(CGPoint)newOrigin {
	self.frame = CGRectMake(newOrigin.x, newOrigin.y, self.frame.size.width, self.frame.size.height);
}
- (CGSize)frameSize {
	return self.frame.size;
}
- (void)setFrameSize:(CGSize)newSize {
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newSize.width, newSize.height);
}
- (CGFloat)frameX {
	return self.frame.origin.x;
}
- (void)setFrameX:(CGFloat)newX {
	self.frame = CGRectMake(newX, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}
- (CGFloat)frameY {
	return self.frame.origin.y;
}
- (void)setFrameY:(CGFloat)newY {
	self.frame = CGRectMake(self.frame.origin.x, newY, self.frame.size.width, self.frame.size.height);
}
- (CGFloat)frameWidth {
	return self.frame.size.width;
}
- (void)setFrameWidth:(CGFloat)newWidth {
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newWidth, self.frame.size.height);
}
- (CGFloat)frameHeight {
	return self.frame.size.height;
}
- (void)setFrameHeight:(CGFloat)newHeight {
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, newHeight);
}
@end

@implementation UIWebView (EPCCategories)

- (UIScrollView*)webScrollView {
	UIScrollView *webScrollView = nil;
	if ([self respondsToSelector:@selector(scrollView)]) {
		webScrollView = self.scrollView;
	}
	else {
		for (id sub in webScrollView.subviews) {
			if ([sub isKindOfClass:[UIScrollView class]]) {
				webScrollView = sub;
				break;
			}
		}
	}
	return webScrollView;
}

- (void)disableScroll {
	[self webScrollView].scrollEnabled  = NO;
}

- (void)adjustToHeight {
	UIScrollView *webScrollView = [self webScrollView];
	self.frameHeight = webScrollView.contentSize.height;
}
@end
