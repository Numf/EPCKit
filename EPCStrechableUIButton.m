//
//  EPCStrechableUIButton.m
//
//  Created by Everton Postay Cunha on 8/30/11.
//

#import "EPCStrechableUIButton.h"

@implementation EPCStrechableUIButton

-(void)awakeFromNib {
	[super awakeFromNib];
	
	UIImage *img = [self backgroundImageForState:UIControlStateNormal];
	if (img)
		[self setBackgroundImage:img forState:UIControlStateNormal];
	
	
	if (img != (img = [self backgroundImageForState:UIControlStateHighlighted]))
		[self setBackgroundImage:img forState:UIControlStateHighlighted];
	
	if (img != (img = [self backgroundImageForState:UIControlStateSelected]))
		[self setBackgroundImage:img forState:UIControlStateSelected];
	
	NSAssert(img.size.height == self.frame.size.height, @"EPCStrechableUIButton Doesn't work well if the image height is different than button height. Image height is %f", img.size.height);
}

- (void)setBackgroundImage:(UIImage*)img forState:(UIControlState)state {
	NSAssert(img.size.height == self.frame.size.height, @"EPCStrechableUIButton Doesn't work well if the image height is different than button height. Image height is %f", img.size.height);
	
	int w = img.size.width/2;
	int h = img.size.height;
	[super setBackgroundImage:[img stretchableImageWithLeftCapWidth:w topCapHeight:h] forState:state];
}

@end
