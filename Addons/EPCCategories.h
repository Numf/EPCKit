//
//  EPCCategories.h
//
//  Created by Everton Postay Cunha on 25/07/12.
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>

// IOS ONLY

@interface UIApplication (EPCCategories)
+ (NSString*)documentsDirectoryPath;
+ (NSString*)cacheDirectoryPath;
+ (NSString*)tmpDirectoryPath;
@end

@interface UIImage (EPCCategories)
+ (UIImage*)imageWithContentsOfFileNamed:(NSString*)name; /* this prevents caching the image object */
+ (UIImage*)imageWithContentsOfFileInDocumentsDirectoryNamed:(NSString*)name;
+ (UIImage*)imageWithContentsOfFileInCacheDirectoryNamed:(NSString*)name;
- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
- (UIImage *)imageTintedWithColor:(UIColor *)color;
- (UIImage *)imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction;
+ (UIImage *)imageNamedA4I:(NSString*)name;
@end

@interface UIView (EPCCategories)
+ (id)loadFromNib;
+ (id)loadFromNibName:(NSString*)nibName;
+ (id)loadFromNibReplacingView:(UIView*)view;
- (void)removeAllSubviews;
- (void)removeAllSubviewsOfClass:(Class)aClass;
@property (nonatomic) CGPoint frameOrigin;
@property (nonatomic) CGSize frameSize;
@property (nonatomic) CGFloat frameX;
@property (nonatomic) CGFloat frameY;
@property (nonatomic) CGFloat frameWidth;
@property (nonatomic) CGFloat frameHeight;
@end

@interface UIViewController (EPCCategories)
- (void)unloadView;
- (IBAction)popViewControllerAnimated;
@end

@interface UIWebView (EPCCategories)
- (void)adjustToHeight;
- (void)disableScroll;
- (UIScrollView*)webScrollView;
- (void)ajustToHeightAndStopBouncing;
@end

@interface UIResponder (EPCCategories)
+ (id)currentFirstResponder;
@end

@interface UIScrollView (EPCCategories)
- (void)scrollToBottomAnimated:(BOOL)animated;
@end

#else

// MAC ONLY

@interface NSAttributedString (EPCCategories)
+ (id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;
@end

#endif

@interface NSUserDefaults (EPCCategories)
+ (BOOL)syncBool:(BOOL)value forKey:(NSString*)key;
+ (BOOL)boolForKey:(NSString*)key;
+ (BOOL)syncObject:(id)object forKey:(NSString*)key;
+ (id)objectForKey:(NSString*)key;
+ (void)clearUserDefaults;
@end

@interface NSArray (EPCCategories)
- (NSArray*)reversedArray;
- (NSArray*)sortedArrayWithKey:(NSString*)property ascending:(BOOL)asc;
- (NSArray*)sortedArrayUsingArray:(NSArray*)otherArray;
- (id)firstObject;
@end

@interface NSMutableArray (EPCCategories)
- (void)reverse;
- (void)removeNullObjects;
@end

@interface NSSet (EPCCategories)
- (NSArray*)sortedArrayWithKey:(NSString*)property ascending:(BOOL)asc;
@end

@interface NSMutableDictionary (EPCCategories)
- (void)removeNullObjects;
@end

@interface NSDate (EPCCategories)
@property (readonly) NSString *day;
@property (readonly) NSString *hours;
@property (readonly) NSString *minutes;
@property (readonly) NSString *month;
@property (readonly) NSString *seconds;
@property (readonly) NSString *year;
@end

@interface NSString (EPCCategories)
- (NSString*)md5;
- (NSString*)sha1;
- (NSURL*)urlSafe;
- (NSString*)stringByTruncatingToLength:(int)length tail:(NSString*)tail;
- (NSString*)stringByRemovingCharacterSet:(NSCharacterSet*)characterSet;
- (NSString*)stringByRemovingNewLinesAndWhitespace;
- (NSArray*)arrayByExplodingWithString:(NSString*)string;
- (NSString*)phpURLEncoded;
- (NSString*)stringByFirstCharCapital;
- (NSString*)stringByAllWordsFirstCharUpperCase;
#if TARGET_OS_IPHONE
- (BOOL)excludePathFromBackup;
#endif
@end

@interface NSMutableString (EPCCategories)
- (NSMutableString*)initWithUnknowEncondingAndData:(NSData*)data;
@end

@interface NSNumberFormatter (EPCCategories)
+ (NSString*)stringFromTime:(float)time;
@end