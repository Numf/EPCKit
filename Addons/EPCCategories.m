//
//  EPCCategories.m
//
//  Created by Everton Postay Cunha on 25/07/12.
//

#import "EPCCategories.h"
#import "EPCDefines.h"
#import <CommonCrypto/CommonDigest.h>
#import <sys/xattr.h>

#if TARGET_OS_IPHONE
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
- (void)popViewControllerAnimated {
	[self.navigationController popViewControllerAnimated:YES];
}
@end

@implementation UIImage (EPCCategories)
+(UIImage *)imageWithContentsOfFileNamed:(NSString *)name {
	return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[name stringByDeletingPathExtension] ofType:[name pathExtension]]];
}
+(UIImage *)imageWithContentsOfFileInDocumentsDirectoryNamed:(NSString *)name {
	if (name) {
		NSString *path = [[UIApplication documentsDirectoryPath] stringByAppendingPathComponent:name];
		if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
			return [UIImage imageWithContentsOfFile:path];
		}
	}
	return nil;
}
+(UIImage *)imageWithContentsOfFileInCacheDirectoryNamed:(NSString *)name {
	return [UIImage imageWithContentsOfFile:[[UIApplication cacheDirectoryPath] stringByAppendingPathComponent:name]];
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
+ (NSString *)cacheDirectoryPath {
	static id cachedir = nil;
	if (!cachedir) {
		cachedir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] copy];
	}
	return cachedir;
}
+ (NSString *)tmpDirectoryPath {
	static id tempDir = nil;
	if (!tempDir) {
		tempDir = [NSTemporaryDirectory() copy];
		NSFileManager *fm = [NSFileManager defaultManager];
		if (![fm fileExistsAtPath:tempDir]) {
			[fm createDirectoryAtPath:tempDir withIntermediateDirectories:NO attributes:nil error:nil];
		}
	}
	return tempDir;
}
@end

@implementation UIView (EPCCategories)
+ (id)loadFromNibName:(NSString*)nibName {
	return [[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil] lastObject];
}
+ (id)loadFromNib {
	return [self loadFromNibName:NSStringFromClass(self)];
}
+ (id)loadFromNibReplacingView:(UIView *)view {
	UIView *vv = [self loadFromNib];
	vv.frame = view.frame;
	[view.superview addSubview:vv];
	[view removeFromSuperview];
	return vv;
}
- (void)removeAllSubviews {
	[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}
- (void)removeAllSubviewsOfClass:(Class)aClass {
	for (UIView *sub in self.subviews) {
		if ([sub isKindOfClass:aClass]) {
			[sub removeFromSuperview];
		}
	}
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
#endif

#pragma mark - End iOS Only -

@implementation NSUserDefaults (EPCCategories)
+ (BOOL)syncBool:(BOOL)value forKey:(NSString*)key {
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud setBool:value forKey:key];
	return [ud synchronize];
}
+ (BOOL)boolForKey:(NSString*)key {
	return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}
+ (BOOL)syncObject:(id)object forKey:(NSString*)key {
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud setObject:object forKey:key];
	return [ud synchronize];
}
+ (id)objectForKey:(NSString*)key {
	return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}
@end

@implementation	NSArray (EPCCategories)
- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}
- (NSArray *)sortedArrayWithKey:(NSString *)key ascending:(BOOL)asc {
	return [self sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:key ascending:asc]]];
}
static NSInteger comparatorForSortingUsingArray(id object1, id object2, void *context) {
    NSUInteger index1 = [(NSArray *)context indexOfObject:object1];
    NSUInteger index2 = [(NSArray *)context indexOfObject:object2];
    if (index1 < index2)
        return NSOrderedAscending;
    // else
    if (index1 > index2)
        return NSOrderedDescending;
    // else
    return [object1 compare:object2];
}
- (NSArray *)sortedArrayUsingArray:(NSArray *)otherArray {
    return [self sortedArrayUsingFunction:comparatorForSortingUsingArray context:otherArray];
}
@end

@implementation NSMutableArray (EPCCategories)
- (void)reverse {
	if ([self count] == 0)
        return;
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i withObjectAtIndex:j];
        i++;
        j--;
    }
}
@end

@implementation	NSSet (EPCCategories)
- (NSArray *)sortedArrayWithKey:(NSString *)key ascending:(BOOL)asc {
	return [self sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:key ascending:asc]]];
}
@end

@implementation NSString (EPCCategories)
- (NSArray*)arrayByExplodingWithString:(NSString*)string {
	NSMutableArray *strings = [NSMutableArray array];
	NSRange range = [self rangeOfString:string];
	if (range.location != NSNotFound) { // first
		NSString *subf = [self substringWithRange:NSMakeRange(0, range.location)];
		if ([subf length] > 0) {
			[strings addObject:subf];
		}
	}
	while (range.location != NSNotFound && range.location > 0) {
		NSRange nextRange = [self rangeOfString:string options:NSLiteralSearch range:NSMakeRange(range.location+range.length, [self length] - (range.location+range.length))];
		NSString *subs = nil;
		if (nextRange.location == NSNotFound) {
			subs = [self substringFromIndex:range.location+range.length];
		}
		else {
			subs = [self substringWithRange:NSMakeRange(range.location+range.length, nextRange.location-(range.location+range.length))];
		}
		if ([subs length] > 0)
			[strings addObject:subs];
		range = nextRange;
	}
	if ([strings count] > 0)
		return strings;
	if ([self length] > 0)
		return [NSArray arrayWithObject:self];
	return nil;
}
- (NSString *) md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3],
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];
}
- (NSString *)sha1 {
	NSString *str = self;
	const char *cStr = [str UTF8String];
	unsigned char result[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(cStr, (CC_LONG)strlen(cStr), result);
	NSString *s = [NSString  stringWithFormat:
				   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				   result[0], result[1], result[2], result[3], result[4],
				   result[5], result[6], result[7],
				   result[8], result[9], result[10], result[11], result[12],
				   result[13], result[14], result[15],
				   result[16], result[17], result[18], result[19]
				   ];
	
    return s;
}
- (NSURL*)urlSafe {
	NSURL *url = [NSURL URLWithString:self];
	if (!url)
		url = [NSURL URLWithString:[self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	return url;
}
-(NSString *)phpURLEncoded {
	NSMutableString *str = [[NSMutableString alloc] initWithString:[self stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	[str replaceOccurrencesOfString:@":" withString:@"%3A" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
	[str replaceOccurrencesOfString:@"/" withString:@"%2F" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
	[str replaceOccurrencesOfString:@"?" withString:@"%3F" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
	[str replaceOccurrencesOfString:@"=" withString:@"%3D" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
	[str replaceOccurrencesOfString:@"&" withString:@"%26" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
	NSString *encodedString = [[str copy] autorelease];
	[str release];
	return encodedString;
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

- (NSString *)stringByFirstCharCapital {
	if ([self length] > 0) {
		return [self stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[self substringToIndex:1] uppercaseString]];
	}
	return self;
}

#if TARGET_OS_IPHONE
-(BOOL)excludePathFromBackup {
	NSURL *url = [[NSURL alloc] initFileURLWithPath:self];
	
	if ([[[UIDevice currentDevice] systemVersion] isEqualToString:@"5.0.1"]) {
		assert([[NSFileManager defaultManager] fileExistsAtPath: self]);
		
		const char* filePath = [[url path] fileSystemRepresentation];
		
		const char* attrName = "com.apple.MobileBackup";
		u_int8_t attrValue = 1;
		
		int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
		assert(result);
		return result == 0;
	}
	else if (!IOS_VERSION_LESS_THAN(@"5.0.1")) {
		assert([[NSFileManager defaultManager] fileExistsAtPath: self]);
		
		NSError *error = nil;
		BOOL success = [url setResourceValue: [NSNumber numberWithBool: YES]
									  forKey: NSURLIsExcludedFromBackupKey error: &error];
		if(!success){
			NSLog(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
		}
		[url release];
		assert(success);
		return success;
	}
	return YES; // ios 5 and earlier can't ignore files from backup, so we just return yes to ignore error alerts.
}
#endif
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

@implementation NSMutableString (EPCCategories)

- (NSMutableString*)initWithUnknowEncondingAndData:(NSData*)data {
	int e [23];
	e[0] = NSASCIIStringEncoding;
	e[1] = NSUTF8StringEncoding;
	e[2] = NSISOLatin1StringEncoding;
	e[3] = NSISOLatin2StringEncoding;
	e[4] = NSUnicodeStringEncoding;
	e[5] = NSSymbolStringEncoding;
	e[6] = NSNonLossyASCIIStringEncoding;
	e[7] = NSShiftJISStringEncoding;
	e[8] = NSUTF32StringEncoding;
	e[9] = NSUTF16StringEncoding;
	e[10] = NSWindowsCP1251StringEncoding;
	e[11] = NSWindowsCP1252StringEncoding;
	e[12] = NSWindowsCP1253StringEncoding;
	e[13] = NSWindowsCP1254StringEncoding;
	e[14] = NSWindowsCP1250StringEncoding;
	e[15] = NSISO2022JPStringEncoding;
	e[16] = NSMacOSRomanStringEncoding;
	e[17] = NSUTF16BigEndianStringEncoding;
	e[18] = NSUTF32LittleEndianStringEncoding;
	e[19] = NSJapaneseEUCStringEncoding;
	e[20] = NSUTF16LittleEndianStringEncoding;
	e[21] = NSUTF32BigEndianStringEncoding;
	e[22] = NSNEXTSTEPStringEncoding;
	
	NSMutableString *dataString = nil;
	for (int i = 0; i < 23; i++) {
		NSStringEncoding encode = e[i];
		dataString = [self initWithData:data encoding:encode];
		if (dataString) {
			return dataString;
		}
	}
	return nil;
}

@end

@implementation NSNumberFormatter (EPCCategories)
+ (NSString *)stringFromTime:(float)time {
	int minutes = ((int)time)/60.f;
	int seconds = fmodf(time, 60.f);
	int hours = 0;
	if (minutes > 60) {
		hours = (int)(minutes/60.f);
		minutes = fmodf(minutes, 60.f);
	}
	if (hours > 0) {
		return fstr(@"%02d:%02d:%02d", hours, minutes, seconds);
	}
	return fstr(@"%02d:%02d", minutes, seconds);
}
@end
