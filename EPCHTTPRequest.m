//
//  EPCHTTPRequest.m
//
//  Created by Everton Cunha on 17/08/12.
//

#import "EPCHTTPRequest.h"

@interface EPCHTTPRequest() {
	NSOperationQueue *_operationQueue;
	NSError *_error;
	NSString *_responseString;
}
@end

@implementation EPCHTTPRequest
+ (EPCHTTPRequest*)requestWithURL:(NSURL *)url delegate:(id<EPCHTTPRequestDelegate>)delegate {
	EPCHTTPRequest *me = [[[self new] initWithURL:url delegate:delegate] autorelease];
	return me;
}
+ (EPCHTTPRequest*)startRequestWithURL:(NSURL *)url delegate:(id<EPCHTTPRequestDelegate>)delegate {
	EPCHTTPRequest *me = [self requestWithURL:url delegate:delegate];
	[me startAsynchronous];
	return me;
}
- (id)initWithURL:(NSURL *)url delegate:(id<EPCHTTPRequestDelegate>)delegate {
	self = [[self class] new];
	if (self) {
		self.url = url;
		self.delegate = delegate;
	}
	return self;
}
- (void)dealloc
{
    [_operationQueue cancelAllOperations];
	[_operationQueue release];
	_operationQueue = nil;
	self.url = nil;
	self.delegate = nil;
	[_responseData release];
    [super dealloc];
}
- (void)clearDelegatesAndCancel {
	self.delegate = nil;
	[_operationQueue cancelAllOperations];
}
- (void)startAsynchronous {
	NSAssert(_url, @"%@ %s no URL to start the request.", NSStringFromClass([self class]), __PRETTY_FUNCTION__);
	
	if (_url) {
		[_operationQueue cancelAllOperations];
		if (_operationQueue)
			_operationQueue = [NSOperationQueue new];
		
		EPCHTTPRequest *operation = [[EPCHTTPRequest new] autorelease];
		operation.url = _url;
		operation.delegate = (id<EPCHTTPRequestDelegate>)self;
		[_operationQueue addOperation:operation];
	}
}
- (void)epcHTTPRequestStarted:(EPCHTTPRequest*)request {
	if ([_delegate respondsToSelector:@selector(epcHTTPRequestStarted:)])
		[_delegate epcHTTPRequestStarted:self];
}
- (void)epcHTTPRequestFinished:(EPCHTTPRequest*)request {
	[_responseString release];
	_responseString = nil;
	[_responseData release];
	_responseData = [request.responseData retain];
	if ([_delegate respondsToSelector:@selector(epcHTTPRequestFinished:)])
		[_delegate epcHTTPRequestFinished:self];
}
- (void)epcHTTPRequestFailed:(EPCHTTPRequest*)request {
	[_responseString release];
	_responseString = nil;
	[_error release];
	_error = [request.error retain];
	if ([_delegate respondsToSelector:@selector(epcHTTPRequestFailed:)])
		[_delegate epcHTTPRequestFailed:self];
}
- (NSString *)responseString {
	if (!_responseString && _responseData) {
		_responseString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
	}
	return _responseString;
}
- (void)startSynchronous {
	BOOL isDone = NO;
	if (_url) {
		while (![self isCancelled] && !isDone) {
			if ([_delegate respondsToSelector:@selector(epcHTTPRequestStarted:)])
				[(EPCHTTPRequest*)_delegate performSelectorOnMainThread:@selector(epcHTTPRequestStarted:) withObject:self waitUntilDone:YES];
			if ([self isCancelled])
				break;
			_responseData = [[NSData alloc] initWithContentsOfURL:_url options:NSDataReadingUncached error:&_error];
			if ([self isCancelled])
				break;
			if (_responseData && !_error) {
				if ([_delegate respondsToSelector:@selector(epcHTTPRequestFinished:)])
					[(EPCHTTPRequest*)_delegate performSelectorOnMainThread:@selector(epcHTTPRequestFinished:) withObject:self waitUntilDone:YES];
			}
			else {
				if ([_delegate respondsToSelector:@selector(epcHTTPRequestFailed:)])
					[(EPCHTTPRequest*)_delegate performSelectorOnMainThread:@selector(epcHTTPRequestFailed:) withObject:self waitUntilDone:YES];
			}
			isDone = YES;
		}
	}
}
- (void)main {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[self startSynchronous];
	[pool drain];
}
- (void)cancel {
	self.delegate = nil;
	[super cancel];
}
@end
