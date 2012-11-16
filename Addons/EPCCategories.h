//
//  EPCCategories.h
//
//  Created by Everton Postay Cunha on 25/07/12.
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
@interface UIApplication (EPCCategories)
+ (NSString *)documentsDirectoryPath;
+ (NSString *)cacheDirectoryPath;
@end

@interface UIImage (EPCCategories)
+ (UIImage*)imageWithContentsOfFileNamed:(NSString*)name; /* this prevents caching the image object */
+ (UIImage*)imageWithContentsOfFileInDocumentsDirectoryNamed:(NSString *)name;
+(UIImage *)imageWithContentsOfFileInCacheDirectoryNamed:(NSString *)name;
@end

@interface UIView (EPCCategories)
+ (id)loadFromNib;
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
@end

@interface UIWebView (EPCCategories)
- (void)adjustToHeight;
- (void)disableScroll;
- (UIScrollView*)webScrollView;
- (void)ajustToHeightAndStopBouncing;
@end

#endif

@interface NSUserDefaults (EPCCategories)
+ (BOOL)syncBool:(BOOL)value forKey:(NSString*)key;
+ (BOOL)boolForKey:(NSString*)key;
+ (BOOL)syncObject:(id)object forKey:(NSString*)key;
+ (id)objectForKey:(NSString*)key;
@end

@interface NSArray (EPCCategories)
- (NSArray*)sortedArrayWithKey:(NSString*)property ascending:(BOOL)asc;
- (NSArray*)sortedArrayUsingArray:(NSArray*)otherArray;
@end

@interface NSSet (EPCCategories)
- (NSArray*)sortedArrayWithKey:(NSString*)property ascending:(BOOL)asc;
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
#if TARGET_OS_IPHONE
- (BOOL)excludePathFromBackup;
#endif
@end