//
//  EPCDropView.m
//
//  Created by Everton Cunha on 16/11/12.
//  Copyright (c) 2012 Everton Postay Cunha. All rights reserved.
//

#import "EPCDropView.h"
#import	"EPCDefines.h"

@implementation EPCDropView

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[self registerForDraggedTypes:[NSArray arrayWithObjects:
								   NSFilenamesPboardType, nil]];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask])
		== NSDragOperationGeneric) {
        return NSDragOperationCopy;
    }
    else {
        return NSDragOperationNone;
    }
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender {
	_holdingAlt = NO;
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask])
		== NSDragOperationGeneric) {
        return NSDragOperationCopy;
    }
	else if ((NSDragOperationCopy & [sender draggingSourceOperationMask]) == NSDragOperationCopy) {
		_holdingAlt = YES;
		return NSDragOperationCopy;
	}
    else {
        return NSDragOperationNone;
    }
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *paste = [sender draggingPasteboard];
	//gets the dragging-specific pasteboard from the sender
    NSArray *types = [NSArray arrayWithObjects:
					  NSFilenamesPboardType, nil];
	//a list of types that we can accept
    NSString *desiredType = [paste availableTypeFromArray:types];
    NSData *carriedData = [paste dataForType:desiredType];
	
    if (nil == carriedData) {
        //the operation failed for some reason
		DLog(@"Paste Error - Sorry, but the past operation failed");
        return NO;
    }
    else {
		NSArray *fileArray = [paste propertyListForType:NSFilenamesPboardType];
		return [self.delegate dropView:self shouldAcceptFiles:fileArray holdingAlt:_holdingAlt];
    }
	return NO;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard *paste = [sender draggingPasteboard];
	NSArray *fileArray = [paste propertyListForType:NSFilenamesPboardType];
	[self.delegate dropView:self didReceiveFiles:fileArray holdingAlt:_holdingAlt];
}

@end
