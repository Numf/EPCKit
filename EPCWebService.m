//
//  EPCWebService.m
//
//  Created by Everton Cunha on 08/08/12.
//

#import "EPCWebService.h"
#import "EPCCategories.h"
#import "EPCHTTPRequest.h"

@interface EPCWebService () {
	NSOperationQueue *operationQueue;
	NSString *cachePath;
}
@end

@implementation EPCWebService

- (void)dealloc
{
	[self clearDelegateAndCancel];
    [operationQueue release];
	[cachePath release];
    [super dealloc];
}

-(void)clearDelegateAndCancel {
	self.delegate = nil;
	[self cancelAllRequests];
}

-(void)cancelAllRequests {
	@synchronized(self) {
		[operationQueue cancelAllOperations];
		[operationQueue release];
		operationQueue = nil;
	}
}

-(void)requestDataWithURL:(NSURL*)url {
	if (url) {
		if (!operationQueue)
			operationQueue = [[NSOperationQueue alloc] init];
		
		EPCHTTPRequest *request = [EPCHTTPRequest requestWithURL:url delegate:self];
		[operationQueue addOperation:request];
	}
#ifdef DEBUG
	else {
		NSLog(@"%s Warning: Given URL is nil.", __PRETTY_FUNCTION__);
	}
#endif
}

// this is a copy fom requestDataWithURL:, because you may want override this and call super.
-(void)requestData {
	NSString *urlString = [self webServiceURL];
	
	NSURL *url = [NSURL URLWithString:urlString];
	
	if (url) {
		if (!operationQueue)
			operationQueue = [[NSOperationQueue alloc] init];
		
		EPCHTTPRequest *request = [EPCHTTPRequest requestWithURL:url delegate:self];
		[operationQueue addOperation:request];
	}
#ifdef DEBUG
	else {
		NSLog(@"%s Warning: Given URL is nil.", __PRETTY_FUNCTION__);
	}
#endif
}

-(void)requestCachedDataFromURLString:(NSString *)urlString {
	NSString *cachedResponse = [self cachedResponseStringFromURLString:urlString];
	if (cachedResponse) {
		[self performSelectorInBackground:@selector(convertToObjectFromRequest:) withObject:cachedResponse];
	}
	else if ([self.delegate respondsToSelector:@selector(epcWebService:noCacheForURLString:)]) {
		[self.delegate epcWebService:self noCacheForURLString:urlString];
	}
}

// this is a copy fom requestCachedDataFromURLString:, because you may want override this and call super.
-(void)requestDataFromCache {
	NSString *urlString = [self webServiceURL];
	NSString *cachedResponse = [self cachedResponseStringFromURLString:urlString];
	if (cachedResponse) {
		[self performSelectorInBackground:@selector(convertToObjectFromRequest:) withObject:cachedResponse];
	}
	else if ([self.delegate respondsToSelector:@selector(epcWebService:noCacheForURLString:)]) {
		[self.delegate epcWebService:self noCacheForURLString:urlString];
	}
}

-(void)simulateReceivedResponseString:(NSString *)responseString {
	if (responseString) {
		[self performSelectorInBackground:@selector(convertToObjectFromRequest:) withObject:responseString];
	}
}

#pragma mark - Response

-(void)epcHTTPRequestStarted:(EPCHTTPRequest *)request {
	if ([self.delegate respondsToSelector:@selector(epcWebService:requestStartedWithURL:)])
		[self.delegate epcWebService:self requestStartedWithURL:request.url];
}

-(void)epcHTTPRequestFailed:(EPCHTTPRequest *)request {
	[self.delegate epcWebService:self requestFailedWithError:request.error];
}

-(void)epcHTTPRequestFinished:(EPCHTTPRequest *)request {
	if (self.isCachingResponses) {
		[self performSelectorInBackground:@selector(saveRequestToCache:) withObject:request];
	}
	
	[self performSelectorInBackground:@selector(convertToObjectFromRequest:) withObject:request];
}



#pragma mark - Threaded Parser

- (void)convertToObjectFromRequest:(id)requestOrCachedString {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	EPCPagination *pagination = nil;
	NSError *error = nil;
	BOOL *continueAftError = NO;
	BOOL isCache = NO;
	
	EPCHTTPRequest *request = nil;
	
	NSString *responseString = nil;
	
	if ([requestOrCachedString isKindOfClass:[EPCHTTPRequest class]]) {
		request = requestOrCachedString;
		responseString = request.responseString;
	}
	else if ([requestOrCachedString isKindOfClass:[NSString class]]) {
		responseString = requestOrCachedString;
		isCache = YES;
	}
	
	id parsedObj = [self parseToObjectFromString:responseString pagination:&pagination error:&error continueAfterError:&continueAftError];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
	
	if (error) {
		[dict setObject:[NSNumber numberWithBool:isCache] forKey:@"cac"];
		if (error)
			[dict setObject:error forKey:@"err"];
		if (request)
			[dict setObject:request forKey:@"req"];
		
		[self performSelectorOnMainThread:@selector(requestEnconteredError:) withObject:dict waitUntilDone:YES];
	}
	
	if (parsedObj && (!error || continueAftError)) {
		
		[dict setObject:[NSNumber numberWithBool:isCache] forKey:@"cac"];
		if (error)
			[dict setObject:error forKey:@"err"];
		if (parsedObj)
			[dict setObject:parsedObj forKey:@"obj"];
		if (pagination)
			[dict setObject:pagination forKey:@"pag"];
		if (request)
			[dict setObject:request forKey:@"req"];
		
		[self performSelectorOnMainThread:@selector(requestHasFinished:) withObject:dict waitUntilDone:YES];
	}

	[pool drain];
}

- (void)requestHasFinished:(NSDictionary*)dict {
	id data = [dict objectForKey:@"obj"];
	EPCPagination *pagination = [dict objectForKey:@"pag"];
	EPCHTTPRequest *request = [dict objectForKey:@"req"];
	NSError *error = [dict objectForKey:@"err"];
	BOOL isCache = [[dict objectForKey:@"cac"] boolValue];
	
	[self.delegate epcWebService:self returnedData:data pagination:pagination isCache:isCache url:request.url parseError:error];
}

- (void)requestEnconteredError:(NSDictionary*)dict {
	NSError *error = [dict objectForKey:@"err"];
	EPCHTTPRequest *request = [dict objectForKey:@"req"];
	
	[self.delegate epcWebService:self encounteredError:error parsingURL:request.url];
}

#pragma mark - Cache

-(void)deleteCache {
	@synchronized(self) {
		NSString *path = [self cachePath];
		NSError *error = nil;
		NSFileManager *fm = [NSFileManager defaultManager];
		if ([fm fileExistsAtPath:path]) {
			[fm removeItemAtPath:path error:&error];
		}
#ifdef DEBUG
		if (error)
			NSLog(@"%s Warning: Error while deleting cache folder (%@). %@", __PRETTY_FUNCTION__, path, error);
#endif
		[cachePath release];
		cachePath = nil;
	}
}

-(void)deleteCacheForURLString:(NSString *)urlString {
	@synchronized(self) {
		NSString *key = [urlString md5];
		NSString *path = [[self cachePath] stringByAppendingFormat:@"/%@.txt", key];
		NSError *error = nil;
		NSFileManager *fm = [NSFileManager defaultManager];
		if ([fm fileExistsAtPath:path]) {
			[fm removeItemAtPath:path error:&error];
		}
#ifdef DEBUG
		if (error)
			NSLog(@"%s Warning: Error while deleting cache folder (%@). %@", __PRETTY_FUNCTION__, path, error);
#endif
	}
}

-(void)saveRequestToCache:(EPCHTTPRequest *)request {
	NSString *path = [self cachePath];
	if (!path)
		return;
	
	NSString *key = [[request.url absoluteString] md5];
	path = [path stringByAppendingFormat:@"/%@.txt", key];
	
	NSError *error = nil;
	
	if(![request.responseString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
#ifdef DEBUG
		NSLog(@"%s Warning: Error while writing file (%@). %@", __PRETTY_FUNCTION__, path, error);
#endif
	}
}

- (NSString*)cachedResponseStringFromURLString:(NSString*)urlString {
	NSString *storePath = [self cachePath];
	if (!storePath)
		return nil;
	
	NSString *key = [urlString md5];
	NSString *path = [storePath stringByAppendingFormat:@"/%@.txt", key];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		NSError *error = nil;
		NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
		if (error) {
#ifdef DEBUG
			NSLog(@"%s Warning: Error while trying to load cache file (%@). %@", __PRETTY_FUNCTION__, path, error);
#endif
			return nil;
		}
		return string;
	}
	
	return nil;
}

- (NSString*)cachePath {
	if (!cachePath) {
		cachePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"EPCWSCache/%@", NSStringFromClass([self class])]];
		NSFileManager *fm = [NSFileManager defaultManager];
		if (![fm fileExistsAtPath:cachePath]) {
			NSError *error = nil;
			[fm createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&error];
			if (error) {
#ifdef DEBUG
				NSLog(@"%s Warning: Error while trying to create cache folder (%@). %@", __PRETTY_FUNCTION__, cachePath,error);
#endif
				cachePath = nil;
			}
		}
		[cachePath retain];
	}
	return cachePath;
}



#pragma mark - Override these

- (NSString*)webServiceURL {
	NSAssert(NO, @"Override this. %s", __PRETTY_FUNCTION__);
	return nil;
}

- (id)parseToObjectFromString:(NSString*)string pagination:(EPCPagination**)pagination error:(NSError**)error continueAfterError:(BOOL**)continueAfterError {
	NSAssert(NO, @"Override this. %s", __PRETTY_FUNCTION__);
	return nil;
}

#pragma mark - End Override
@end


@implementation EPCPagination
- (void)dealloc {
    self.previousURLString = nil;
	self.nextURLString = nil;
    [super dealloc];
}
@end