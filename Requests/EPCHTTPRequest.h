//
//  EPCHTTPRequest.h
//
//  Created by Everton Cunha on 17/08/12.
//

#import <Foundation/Foundation.h>

@class EPCHTTPRequest;

@protocol EPCHTTPRequestDelegate <NSObject>
@optional
/*
 Fired when the request succeeds.
 */
- (void)epcHTTPRequestFinished:(EPCHTTPRequest*)request;

/*
 Fired when the request fails.
 */
- (void)epcHTTPRequestFailed:(EPCHTTPRequest *)request;

/*
 Fired just before the request starts
 */
- (void)epcHTTPRequestStarted:(EPCHTTPRequest *)request;

@end

@interface EPCHTTPRequest : NSOperation
/*
 Allocates the request with an URL.
 */
- (EPCHTTPRequest*)initWithURL:(NSURL *)url delegate:(id<EPCHTTPRequestDelegate>)delegate;

/*
 Allocates the request with a NSURLRequest.
 */
- (EPCHTTPRequest*)initWithURLRequest:(NSURLRequest *)urlRequest delegate:(id<EPCHTTPRequestDelegate>)delegate;

/*
 Autoreleased request for NSURLRequest.
 */
+ (EPCHTTPRequest*)requestWithRequest:(NSURLRequest *)urlRequest delegate:(id<EPCHTTPRequestDelegate>)delegate;

/*
 Autoreleased request for NSURL.
 */
+ (EPCHTTPRequest*)requestWithURL:(NSURL*)url delegate:(id<EPCHTTPRequestDelegate>)delegate;

/*
 Autoreleased request that automatically starts.
 */
+ (EPCHTTPRequest*)startRequestWithURL:(NSURL *)url delegate:(id<EPCHTTPRequestDelegate>)delegate;

/*
 Clear the delegate and cancel the request.
 */
- (void)clearDelegatesAndCancel;

/*
 Starts the request Asynchronously.
 */
- (void)startAsynchronous;

/*
 Starts the request Synchronously.
 */
- (void)startSynchronous;

/*
 The delegate.
 */
@property (assign) id<EPCHTTPRequestDelegate> delegate;

/*
 Request error when it fails.
 */
@property (retain) NSError *error;

/*
 The data returned from the request.
 */
@property (readonly) NSData *responseData;

/*
 The data as string.
 */
@property (readonly) NSString *responseString;

/*
 A tag.
 */
@property (readwrite) int tag;

/*
 The request URL.
 */
@property (retain) NSURL *url;

/*
 The NSURLRequest.
 */
@property (retain) NSURLRequest *urlRequest;

/*
 The default is NSUTF8StringEncoding.
 */
@property (readwrite) NSStringEncoding responseStringEncoding;
@end