//
//  EPCStrechableUIButton.m
//
//  Created by Everton Postay Cunha on 8/30/11.
//

#import "EPCStrechableUIButton.h"
//#import "EPCDefines.h"

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
	
	if (img != (img = [self backgroundImageForState:UIControlStateDisabled]))
		[self setBackgroundImage:img forState:UIControlStateSelected];
}

- (void)setBackgroundImage:(UIImage*)img forState:(UIControlState)state {
	int w = img.size.width/2;
	int h = img.size.height;
	[super setBackgroundImage:[img stretchableImageWithLeftCapWidth:w topCapHeight:h] forState:state];
	
//	DLog(@"%@", (img.size.height != self.frame.size.height)?fstr(@"Warning: EPCStrechableUIButton Doesn't work well if the image height is different than button height. Image height is %f and button height is %f", img.size.height, self.frame.size.height):@"");
}

+ (void)applyStretchOnButton:(UIButton *)button {
	UIImage *img = [button backgroundImageForState:UIControlStateNormal];
	int w = img.size.width/2;
	int h = img.size.height/2;
	if (img)
		[button setBackgroundImage:[img stretchableImageWithLeftCapWidth:w topCapHeight:h] forState:UIControlStateNormal];
	
	if (img != (img = [button backgroundImageForState:UIControlStateHighlighted]))
		[button setBackgroundImage:[img stretchableImageWithLeftCapWidth:w topCapHeight:h] forState:UIControlStateHighlighted];
	
	if (img != (img = [button backgroundImageForState:UIControlStateSelected]))
		[button setBackgroundImage:[img stretchableImageWithLeftCapWidth:w topCapHeight:h] forState:UIControlStateSelected];
}

@end
