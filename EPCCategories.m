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
- (void)removeAllSubviews {
	for (UIView *sub in self.subviews) {
		[sub removeFromSuperview];
	}
}
- (void)removeAllSubviewsOfClass:(Class)aClass {
	for (UIView *sub in self.subviews) {
		if ([sub isKindOfClass:aClass]) {
			[sub removeFromSuperview];
		}
	}
}
- (UIImage*)renderToImageOfSize:(CGSize)size opaque:(BOOL)opaque
{
	CGRect originalRect = self.frame;
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
	UIGraphicsBeginImageContextWithOptions(self.frame.size, opaque, 0.0);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	self.frame = originalRect;
	return image;
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
- (NSArray*)arrayByExplodingWithString:(NSString*)string {
	NSMutableArray *strings = [NSMutableArray array];
	NSRange range = [self rangeOfString:string];
	while (range.location != NSNotFound && range.location > 0) {
		NSRange nextRange = [self rangeOfString:string options:NSLiteralSearch range:NSMakeRange(range.location+range.length, [self length] - (range.location+range.length))];
		NSString *subs = nil;
		if (nextRange.location == NSNotFound) {
			subs = [self substringFromIndex:range.location+range.length];
		}
		else {
			subs = [self substringWithRange:NSMakeRange(range.location+range.length, nextRange.location-(range.location+range.length))];
		}
		if (subs)
			[strings addObject:subs];
		range = nextRange;
	}
	if ([strings count] > 0)
		return strings;
	return nil;
}
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
- (NSString*)stringByTruncatingToLength:(int)limit tail:(NSString*)tail {
	NSString *text = self;
	if ([text length] > limit) {
		if ([[text substringWithRange:NSMakeRange(limit, 1)] isEqualToString:@" "]) {
			// end not breaking a word
			text = [text substringToIndex:limit];
		}
		else {
			// don't break a word
			NSRange range = [text rangeOfString:@" " options:NSBackwardsSearch range:NSMakeRange(0, limit)];
			text = [text substringToIndex:range.location];
		}
		if (tail)
			text = [text stringByAppendingString:tail];
	}
	return text;
}

-(NSString *)stringByRemovingCharacterSet:(NSCharacterSet*)characterSet {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSScanner *scanner = [[NSScanner alloc] initWithString:self];
	[scanner setCharactersToBeSkipped:nil];
	NSMutableString *result = [[NSMutableString alloc] init];
	NSString *temp;
	while (![scanner isAtEnd]) {
		temp = nil;
		[scanner scanUpToCharactersFromSet:characterSet intoString:&temp];
		if (temp) [result appendString:temp];
		if ([scanner scanCharactersFromSet:characterSet intoString:NULL]) {
			if (result.length > 0 && ![scanner isAtEnd])
				[result appendString:@" "];
		}
	}
	[scanner release];
	NSString *retString = [[NSString stringWithString:result] retain];
	[result release];
	[pool drain];
	return [retString autorelease];
}

-(NSString *)stringByRemovingNewLinesAndWhitespace {
	
	// Strange New lines:
	//  Next Line, U+0085
	//  Form Feed, U+000C
	//  Line Separator, U+2028
	//  Paragraph Separator, U+2029
	
	NSCharacterSet *newLineAndWhitespaceCharacters = [NSCharacterSet characterSetWithCharactersInString:
													  [NSString stringWithFormat:@" \t\n\r%d%d%d%d", 0x0085, 0x000C, 0x2028, 0x2029]];
	return [self stringByRemovingCharacterSet:newLineAndWhitespaceCharacters];
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

@implementation NSDate (EPCCategories)
// YYYY-MM-DD HH:MM:SS ±HHMM
- (NSString*)day {
	return [[self description] substringWithRange:NSMakeRange(8, 2)];
}
- (NSString*)hours {
	return [[self description] substringWithRange:NSMakeRange(11, 2)];
}
- (NSString*)minutes {
	return [[self description] substringWithRange:NSMakeRange(14, 2)];
}
- (NSString*)month {
	return [[self description] substringWithRange:NSMakeRange(5, 2)];
}
- (NSString*)seconds {
	return [[self description] substringWithRange:NSMakeRange(17, 2)];
}
- (NSString*)year {
	return [[self description] substringWithRange:NSMakeRange(0, 4)];
}
@end
