//
//  CommonButton.m
//  Magic Videos
//
//  Created by Everton Cunha on 25/01/13.
//  Copyright (c) 2013 Everton Postay Cunha. All rights reserved.
//

#import "CommonButton.h"

@implementation CommonButton

- (void)awakeFromNib {
	[self setBackgroundImage:[UIImage imageNamed:@"btn-common-bg.png"] forState:UIControlStateNormal];
	[self setBackgroundImage:[UIImage imageNamed:@"btn-common-bg-hl.png"] forState:UIControlStateHighlighted];
	[self setBackgroundImage:[UIImage imageNamed:@"btn-common-bg-hl.png"] forState:UIControlStateSelected];
	[self setBackgroundImage:[UIImage imageNamed:@"btn-common-bg-hl.png"] forState:UIControlStateSelected|UIControlStateHighlighted];
	[[self titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.f]];
	[self setTitleColor:UIColorFromRGB(0xd2be94) forState:UIControlStateNormal];
	[self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	[self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected|UIControlStateHighlighted];
	[super awakeFromNib];
}

@end
