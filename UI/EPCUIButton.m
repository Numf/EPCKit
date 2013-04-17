//
//  EPCUIButton.m
//  Pligg
//
//  Created by Everton Cunha on 11/03/13.
//  Copyright (c) 2013 Ring. All rights reserved.
//

#import "EPCUIButton.h"

@implementation EPCUIButton

- (void)awakeFromNib {
	[super awakeFromNib];
	
	UIImage *img = [self backgroundImageForState:UIControlStateSelected];
	[self setBackgroundImage:img forState:UIControlStateHighlighted|UIControlStateSelected];
	self.exclusiveTouch = YES;
}

@end