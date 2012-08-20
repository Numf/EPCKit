//
//  EPCWebService.h
//
//  Created by Everton Cunha on 08/08/12.
//

// You should subclass and override (copy-paste) the following methods:
/*
// The WS URL.
- (NSString*)webServiceURL {
	static NSString *urlString = @"";
	return urlString;
}

// Parse the string to NSObject. (JSON/XML to Obj-C objects). This runs in a background thread.
- (id)parseToObjectFromString:(NSString*)string pagination:(EPCPagination**)pagination error:(NSError**)error continueAfterError:(BOOL**)continueAfterError {
	*continueAfterError = NO;
	*error = nil;
	*pagination = nil;
	return nil;
}
*/

#import <Foundation/Foundation.h>
#import "EPCHTTPRequest.h"

@class EPCPagination;
@class EPCWebService;

@protocol EPCWebServiceDelegate <NSObject>
@required
/*
 Fired when the request finishes. URL is nil if it's from cache.
 */
- (void)epcWebService:(EPCWebService*)epcWebService returnedData:(id)data pagination:(EPCPagination*)pagination isCache:(BOOL)isCache url:(NSURL*)url parseError:(NSError*)parseError;

/*
 Fired when request fails.
 */
- (void)epcWebService:(EPCWebService*)epcWebService requestFailedWithError:(NSError*)error;

/*
 Fired when an error ocurred while parsing. URL is nil if it's from cache.
 */
- (void)epcWebService:(EPCWebService*)epcWebService encounteredError:(NSError*)error parsingURL:(NSURL*)url;
@optional
/*
 Fired when request starts.
 */
- (void)epcWebService:(EPCWebService*)epcWebService requestStartedWithURL:(NSURL*)url;

/*
 Fired when there is no cache when requesting for it. 
 */
- (void)epcWebService:(EPCWebService *)epcWebService noCacheForURLString:(NSString *)urlString;
@end

@interface EPCWebService : NSObject <EPCHTTPRequestDelegate>

/*
 Clear delegate and cancel all requests.
 */
- (void)cancelAllRequests;

/*
 Clear delegate and cancel all requests.
 */
- (void)clearDelegateAndCancel;

/*
 Delete all caches for this WS subclass.
 */
- (void)deleteCache;

/*
 Delete the cache of a given URL for this WS subclass.
 */
- (void)deleteCacheForURLString:(NSString*)urlString;

/*
 Reads local cached data from WS URL.
 */
- (void)requestDataFromCache;

/*
 Reads local cached data from a given URL.
 */
- (void)requestCachedDataFromURLString:(NSString*)urlString;

/*
 Request data from WS.
 */
- (void)requestData;

/*
 Request with a given URL. Useful for paginations.
 */
- (void)requestDataWithURL:(NSURL*)url;

/*
 Simulate received response string.
 */
- (void)simulateReceivedResponseString:(NSString*)responseString;

/*
 Saves response strings to cache. This writes a md5(url).txt file.
 */
@property (readwrite,getter=isCachingResponses) BOOL cacheResponses;

/*
 The delegate.
 */
@property (assign) id<EPCWebServiceDelegate> delegate;
@end

@interface EPCPagination : NSObject
@property (copy) NSString *previousURLString, *nextURLString;
@end