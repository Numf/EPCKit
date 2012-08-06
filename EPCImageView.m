//
//  EPCImageView.m
//
//  Created by Everton Postay Cunha on 15/05/12.
//

#import "EPCImageView.h"

@implementation EPCImageView
@synthesize imageCache,delegate;

-(NSCache *)imageCache {
	if (!imageCache) {
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
	
	[request clearDelegatesAndCancel];
	
    [currentURL release];
	
	[request release];
	
    [super dealloc];
}

-(void)setImageByURL:(NSURL *)url {
	
	[request clearDelegatesAndCancel];
	[request release];
	request = nil;
	
	[currentURL release];
	currentURL = nil;
	
	self.image = nil;
	
	[actView stopAnimating];
	
	if (url) {
		
		currentURL = [url retain];
		
		if ([self.delegate respondsToSelector:@selector(epcImageView:shouldHandleImageForURL:)]) {
			if (![self.delegate epcImageView:self shouldHandleImageForURL:url]) {
				return;
			}
		}
		
		UIImage *cachedImage = [self.imageCache objectForKey:[url absoluteString]];
		
		if (!cachedImage) {
			if ([self.delegate respondsToSelector:@selector(epcImageView:imageForURL:)]) {
				cachedImage = [self.delegate epcImageView:self imageForURL:url];
				if (cachedImage) {
					[self.imageCache setObject:cachedImage forKey:[url absoluteString]];
				}
			}
		}
		
		if (!cachedImage) {
			if (!actView) {
				actView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
				actView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
				actView.hidesWhenStopped = YES;
				[self addSubview:actView];
				[actView release];
			}
			[actView startAnimating];
			
			request = [[ASIHTTPRequest alloc] initWithURL:url];
			request.otherData = url;
			[request setDelegate:self];
			[request startAsynchronous];
		}
		else {
			[self setImage:cachedImage];
			
			if ([self.delegate respondsToSelector:@selector(epcImageView:isShowingImage:fromURL:isFromCache:data:)])
				[self.delegate epcImageView:self isShowingImage:cachedImage fromURL:currentURL isFromCache:YES data:nil];
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)_request {
	
	if (_request.otherData == currentURL) {
		[self setImage:nil];
		if ([self.delegate respondsToSelector:@selector(epcImageView:failedLoadingURL:)])
			[self.delegate epcImageView:self failedLoadingURL:currentURL];
		[actView stopAnimating];
	}
}

-(void)requestFinished:(ASIHTTPRequest *)_request {
	
	NSData *data = [_request responseData];
	UIImage *newImage = nil;
	
	if (data && (newImage = [UIImage imageWithData:data])) {
		
		[self.imageCache setObject:newImage forKey:[_request.otherData absoluteString]];
		[actView stopAnimating];
		if (_request.otherData == currentURL) {
			[actView stopAnimating];
			[self setImage:newImage];
			if ([self.delegate respondsToSelector:@selector(epcImageView:isShowingImage:fromURL:isFromCache:data:)])
				[self.delegate epcImageView:self isShowingImage:newImage fromURL:currentURL isFromCache:NO data:data];
		}
		
		
	}
	else {
		if (_request.otherData == currentURL) {
			[actView stopAnimating];
			[self setImage:nil];
			if ([self.delegate respondsToSelector:@selector(epcImageView:failedLoadingURL:)])
				[self.delegate epcImageView:self failedLoadingURL:currentURL];
		}
	}
	
}

@end
