//
//  EPCDropView.h
//
//  Created by Everton Cunha on 16/11/12.
//  Copyright (c) 2012 Everton Postay Cunha. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EPCDropView;

@protocol EPCDropViewDelegate <NSObject>
- (void)dropView:(EPCDropView*)dropView didReceiveFiles:(NSArray*)files holdingAlt:(BOOL)holdingAlt;
- (BOOL)dropView:(EPCDropView*)dropView shouldAcceptFiles:(NSArray*)files holdingAlt:(BOOL)holdingAlt;
@end

@interface EPCDropView : NSView {
	BOOL _holdingAlt;
	id<EPCDropViewDelegate> _delegate;
}

@property (assign) IBOutlet id<EPCDropViewDelegate> delegate;

@end
