//
//  EPCImageView.m
//
//  Created by Everton Postay Cunha on 15/05/12.
//

#import "EPCImageView.h"

@interface EPCImageView () {
	UIActivityIndicatorView *actView;
	NSURL *currentURL;
	NSOperationQueue *operationQueue;
	BOOL imageCacheIsDefault;
}
@end


@implementation EPCImageView
@synthesize imageCache,delegate;
-(NSCache *)imageCache {
	if (!imageCache && !_dontCachesImages) {
		imageCacheIsDefault = YES;
		self.imageCache = [[self class] imageCache];
	}
	return imageCache;
}

+(NSCache *)imageCache {
	static id cache = nil;
	if (!cache) {
		cache = [[NSCache alloc] init];
	}
	return cache;
}

- (void)dealloc
{
	self.delegate = nil;
	
	if (!imageCacheIsDefault)
		self.imageCache = nil;
	
	[operationQueue cancelAllOperations];
	[operationQueue release];
	
    [currentURL release];
	
    [super dealloc];
}

-(BOOL)retry {
	if (currentURL) {
		[self setImageByURL:[NSURL URLWithString:[currentURL absoluteString]]];
		return YES;
	}
	return NO;
}

- (void)loadImageWithoutURL {
	[self setImageByURL:[NSURL URLWithString:@"http://www.google.com"]];
	self.dontCachesImages = YES;
}

-(void)setImageByURL:(NSURL *)url {

	BOOL cancelledARequest = ([operationQueue operationCount] > 0);
		
	[operationQueue cancelAllOperations];
	
	if (!operationQueue)
		operationQueue = [NSOperationQueue new];
	
	if (cancelledARequest) {
		[self requestWasCancelledForURL:currentURL];
	}
	
	[currentURL release];
	currentURL = nil;
	
	self.image = nil;
	
	[actView stopAnimating];
	
	if (url) {
		
		currentURL = [url retain];
		
		if (!actView && !self.hideActivityIndicator) {
			actView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			actView.hidesWhenStopped = YES;
			if ([self.delegate respondsToSelector:@selector(epcImageView:frameForActivityIndicatorView:)])
				actView.frame = [self.delegate epcImageView:self frameForActivityIndicatorView:actView];
			else
				actView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
			[self addSubview:actView];
			[actView release];
		}
		
		
		if ([self.delegate respondsToSelector:@selector(epcImageView:shouldHandleImageForURL:)]) {
			if (![self.delegate epcImageView:self shouldHandleImageForURL:url]) {
				return;
			}
		}
		
		// run operation
		
		[actView startAnimating];
		
		GrabImageOperation *operation = [GrabImageOperation grabImageOperationWithURL:currentURL epcImageView:self];
		[operationQueue addOperation:operation];
	}
}

- (NSURL *)imageURL {
	return currentURL;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	if (![self.delegate respondsToSelector:@selector(epcImageView:frameForActivityIndicatorView:)])
		actView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
}

- (void)downloadedImageFromOperation:(GrabImageOperation*)operation {
	if (operation.url == currentURL) {
		[actView stopAnimating];
		[self setImage:operation.grabbedImage];
		if ([self.delegate respondsToSelector:@selector(epcImageView:isShowingImage:fromURL:isFromCache:data:)])
			[self.delegate epcImageView:self isShowingImage:self.image fromURL:operation.url isFromCache:NO data:operation.downloadedData];
	}
}

- (void)imageFromCacheFromOperation:(GrabImageOperation*)operation {
	if (operation.url == currentURL) {
		[actView stopAnimating];
		[self setImage:operation.grabbedImage];
		if ([self.delegate respondsToSelector:@selector(epcImageView:isShowingImage:fromURL:isFromCache:data:)])
			[self.delegate epcImageView:self isShowingImage:self.image fromURL:operation.url isFromCache:YES data:nil];
	}
}

- (void)noImageFromOperation:(GrabImageOperation*)operation {
	if (operation.url == currentURL) {
		[actView stopAnimating];
		[self setImage:nil];
		if ([self.delegate respondsToSelector:@selector(epcImageView:failedLoadingURL:)])
			[self.delegate epcImageView:self failedLoadingURL:currentURL];
	}
}

- (void)requestWillStartWithURL:(NSURL*)url {
	if ([self.delegate respondsToSelector:@selector(epcImageView:willStartRequestForURL:)])
		[self.delegate epcImageView:self willStartRequestForURL:url];
}

- (void)requestWasCancelledForURL:(NSURL*)url {
	if ([self.delegate respondsToSelector:@selector(epcImageView:finishedRequestForURL:wasCancelled:)])
		[self.delegate epcImageView:self finishedRequestForURL:url wasCancelled:YES];
}

- (void)requestFinishedForURL:(NSURL*)url {
	if ([self.delegate respondsToSelector:@selector(epcImageView:finishedRequestForURL:wasCancelled:)])
		[self.delegate epcImageView:self finishedRequestForURL:url wasCancelled:NO];
}

- (BOOL)isRequesting {
	return [operationQueue operationCount] > 0;
}
@end


@implementation GrabImageOperation
@synthesize url, epcImageView, grabbedImage, downloadedData;

- (void)dealloc
{
    self.url = nil;
	self.grabbedImage = nil;
	self.epcImageView = nil;
	self.downloadedData = nil;
    [super dealloc];
}
+ (GrabImageOperation*)grabImageOperationWithURL:(NSURL *)url epcImageView:(EPCImageView *)imgView {
	GrabImageOperation *obj = [[[GrabImageOperation alloc] init] autorelease];
	obj.url = url;
	obj.epcImageView = imgView;
	return obj;
}
- (void)main {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	@try {
		BOOL isDone = NO;
		
		while (![self isCancelled] && !isDone) {
			// Do some work and set isDone to YES when finished
			
			BOOL imageIsFromCache = YES;
			
			self.grabbedImage = [epcImageView.imageCache objectForKey:[url absoluteString]];
			
			if (!grabbedImage) {
				
				if ([self isCancelled])
					break;
				if ([self.epcImageView.delegate respondsToSelector:@selector(epcImageView:imageForURL:)]) {
					if ([self isCancelled])
						break;
					self.grabbedImage = [epcImageView.delegate epcImageView:epcImageView imageForURL:url];
					if (grabbedImage) {
						if ([self isCancelled])
							break;
						[epcImageView.imageCache setObject:grabbedImage forKey:[url absoluteString]];
					}
				}
			}
			
			if ([self isCancelled])
				break;
			
			if (!grabbedImage) {
				
				imageIsFromCache = NO;
				[self.epcImageView performSelectorOnMainThread:@selector(requestWillStartWithURL:) withObject:url waitUntilDone:YES];
				self.downloadedData = [NSData dataWithContentsOfURL:url];
				if ([self isCancelled])
					break;
				if (downloadedData) {
					self.grabbedImage = [UIImage imageWithData:downloadedData];
				}
			}
			
			if ([self isCancelled])
				break;
			
			if (grabbedImage) {
				// sucessfull
				
				if ([self isCancelled])
					break;
				if (imageIsFromCache) {
					// from cache
					[self.epcImageView performSelectorOnMainThread:@selector(imageFromCacheFromOperation:) withObject:self waitUntilDone:YES];
				}
				else {
					// downloaded
					[self.epcImageView performSelectorOnMainThread:@selector(requestFinishedForURL:) withObject:url waitUntilDone:YES];
					if ([self isCancelled])
						break;
					[self.epcImageView performSelectorOnMainThread:@selector(downloadedImageFromOperation:) withObject:self waitUntilDone:YES];
				}
			}
			else {
				if ([self isCancelled])
					break;
				// failed
				[self.epcImageView performSelectorOnMainThread:@selector(noImageFromOperation:) withObject:self waitUntilDone:YES];
			}
			
			isDone = YES;
		}
	}
	@catch(NSException *ex) {
#ifdef DEBUG
		NSLog(@"%s %@", __PRETTY_FUNCTION__, ex);
#endif
		if (![self isCancelled]) {
			// Do not rethrow exceptions.
			[self.epcImageView performSelectorOnMainThread:@selector(noImageFromOperation:) withObject:self waitUntilDone:YES];
		}
	}
	[pool drain];
}
@end
