//
//  EPCCategories.m
//
//  Created by Everton Postay Cunha on 25/07/12.
//

#import "EPCCategories.h"
#import "EPCDefines.h"
#import <CommonCrypto/CommonDigest.h>

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
		for (id sub in self.subviews) {
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
	if (webScrollView)
		self.frameHeight = webScrollView.contentSize.height;
}

-(void)ajustToHeightAndStopBouncing {
	UIScrollView *webScrollView = [self webScrollView];
	if (webScrollView) {
		self.frameHeight = webScrollView.contentSize.height;
		webScrollView.bounces = NO;
	}
}
@end

@implementation NSString (EPCCategories)
- (NSString *) md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3],
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];
}
- (NSURL*)urlSafe {
	NSURL *url = [NSURL URLWithString:self];
	if (!url)
		url = [NSURL URLWithString:[self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	return url;
}
@end

@implementation UIViewController (EPCCategories)
-(void)unloadView {
	if(!IOS_VERSION_LESS_THAN(@"6.0")) {
		if ([self respondsToSelector:@selector(viewWillUnload)])
			[self viewWillUnload];
		self.view = nil;
		if ([self respondsToSelector:@selector(viewDidUnload)])
			[self viewDidUnload];	
	}
}
@end

@implementation UIImage (EPCCategories)
+(UIImage *)imageWithContentsOfFileNamed:(NSString *)name {
	return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[name stringByDeletingPathExtension] ofType:[name pathExtension]]];
}
+(UIImage *)imageWithContentsOfFileInDocumentsDirectoryNamed:(NSString *)name {
	static id docDir = nil;
	if (!docDir)
		docDir = [[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path] copy];
	return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[name stringByDeletingPathExtension] ofType:[name pathExtension]]];
}
@end

@implementation UIApplication (EPCCategories)
+ (NSString *)documentsDirectoryPath {
	static id dir = nil;
	if (!dir) {
		dir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] copy];
	}
	return dir;
}
@end
