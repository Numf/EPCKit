//
//  EPCScrollViewKeyboard.m
//  Pligg
//
//  Created by Everton Cunha on 26/04/13.
//  Copyright (c) 2013 Ring. All rights reserved.
//

#import "EPCScrollViewKeyboard.h"
#import "EPCCategories.h"

@implementation EPCScrollViewKeyboard

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [super dealloc];
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShowNotification:) name:UIKeyboardDidShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
	
	UIView *subview = [self.subviews objectAtIndex:0];
	subview.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
	
	[self setContentSize:subview.bounds.size];
}

#pragma mark - Keyboard


- (void)keyboardDidShowNotification:(NSNotification*)aNotification {
	NSDictionary* info = [aNotification userInfo];
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	CGRect rect = [window convertRect:[[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue] toView:self];
	CGSize kbSize = rect.size;
	self.frameHeight -= kbSize.height;
	
	UIView *subview = [self.subviews objectAtIndex:0];
	UIView *responder = [UIResponder currentFirstResponder];
	
	[self scrollRectToVisible:CGRectMake(0, responder.frameY+subview.frameY, subview.frameWidth, responder.frameHeight) animated:YES];
}

- (void)keyboardWillHideNotification:(NSNotification*)aNotification {
	NSDictionary* info = [aNotification userInfo];
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	CGRect rect = [window convertRect:[[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue] toView:self];
	CGSize kbSize = rect.size;
	self.frameHeight += kbSize.height;
}


#pragma mark - TextFields

- (void)nextTextField:(UITextField*)sender {
	
	UIView *superview = sender.superview;
	
	NSArray *subviews = superview.subviews;
	
	int index = [subviews indexOfObject:sender];
	
	for (int i = index+1; i < [subviews count]; i++) {
		id obj = [subviews objectAtIndex:i];
		if ([obj isKindOfClass:[UITextField class]]) {
			[obj becomeFirstResponder];
			break;
		}
	}
}
@end
