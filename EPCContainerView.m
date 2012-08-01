//
//  EPCContainerView.m
//
//  Created by Everton Postay Cunha on 11/25/11.
//

#import "EPCContainerView.h"
#import <QuartzCore/QuartzCore.h>

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@implementation EPCContainerView
@synthesize delegate, pushedViewControllers,containerViewController;

- (void)dealloc {
    for (UIView *vv in self.subviews)
		[vv removeFromSuperview];
	if (pushedViewControllers)
		[pushedViewControllers release];
    [super dealloc];
}


-(void)pushNewRootViewController:(UIViewController *)newViewController animated:(BOOL)animated {
	NSAssert((newViewController != nil), @"Trying to push nil");
	
	if (!pushedViewControllers)
		pushedViewControllers = [[NSMutableArray array] retain];
    
    [pushedViewControllers removeAllObjects];
	[pushedViewControllers addObject:newViewController];
    
	if (self.autoresizesSubviews)
		newViewController.view.frame = self.bounds;
	
	if (!animated) 
    {
        
		for (UIView *sub in self.subviews)
			[sub removeFromSuperview];
		[self addSubview:newViewController.view];
	}
	else {
        
        [newViewController.view setPointX:self.frame.size.width];
		[self addSubview:newViewController.view];
        
		[UIView beginAnimations:@"push" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.333f];
		[UIView setAnimationDelegate:self];
		self.userInteractionEnabled = NO;
        for (UIView *sub in self.subviews) {
			if (sub != newViewController.view) {
				[sub setPointX:-sub.frame.size.width];
			}
		}

		[newViewController.view setPointX:0];
		[UIView commitAnimations];        
	}
        
	
	if ([self.delegate respondsToSelector:@selector(container:pushedViewController:animated:)])
		[self.delegate container:self pushedViewController:newViewController animated:animated];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	UIView *currentView = self.visibleViewController.view;
	for (UIView *sub in self.subviews) {
		if (sub != currentView) {
			[sub removeFromSuperview];
		}
	}
	self.userInteractionEnabled = YES;
}

-(void)pushViewController:(UIViewController *)newViewController animated:(BOOL)animated {
	NSAssert((newViewController != nil), @"Trying to push nil");
    
	if (!pushedViewControllers)
		pushedViewControllers = [[NSMutableArray array] retain];
    
	[pushedViewControllers addObject:newViewController];
    
	if (self.autoresizesSubviews)
		newViewController.view.frame = self.bounds;
	
	if (!animated) {
		for (UIView *sub in self.subviews)
			[sub removeFromSuperview];
		[self addSubview:newViewController.view];
	}
	else {
		[newViewController.view setPointX:self.frame.size.width];
		[self addSubview:newViewController.view];
		
		[UIView beginAnimations:@"push" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.333f];
		[UIView setAnimationDelegate:self];
		self.userInteractionEnabled = NO;
		for (UIView *sub in self.subviews) {
			if (sub != newViewController.view) {
				[sub setPointX:-sub.frame.size.width];
			}
		}
        
		[newViewController.view setPointX:0];
		[UIView commitAnimations];
		
	}
	
	if ([self.delegate respondsToSelector:@selector(container:pushedViewController:animated:)])
		[self.delegate container:self pushedViewController:newViewController animated:animated];
}

- (void)popToViewController:(UIViewController *)toViewController animated:(BOOL)animated {
	
	if (![pushedViewControllers containsObject:toViewController])
		[NSException raise:@"Exception!" format:@"Trying to pop a view that wasn't push in the container."];
	
	if (!animated) 
    {
		for (UIView *sub in self.subviews)
			[sub removeFromSuperview];
		
		[self addSubview:toViewController.view];
	}
	else 
    {
        
		[toViewController.view setPointX:-toViewController.view.frame.size.width];
		[self addSubview:toViewController.view];
		
		[UIView beginAnimations:@"pop" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.333f];
		[UIView setAnimationDelegate:self];
		self.userInteractionEnabled = NO;
		for (UIView *sub in self.subviews) {
			if (sub != toViewController.view) {
				[sub setPointX:self.frame.size.width];
			}
		}
		[toViewController.view setPointX:0];
        [self performSelector:@selector(callViewDidAppearWithAnimation:) withObject:toViewController afterDelay:0.4f];
		[UIView commitAnimations];
	}
    
    while([pushedViewControllers lastObject] != toViewController)
    {
		[pushedViewControllers removeLastObject];
    }
	
	if ([self.delegate respondsToSelector:@selector(container:poppedToViewController:animated:)])
		[self.delegate container:self poppedToViewController:toViewController animated:animated];
	
}

-(void)popViewControllerAnimated:(BOOL)animated
{
	assert([pushedViewControllers count] > 0);
	
	[pushedViewControllers removeLastObject];
	UIViewController *toViewController = [pushedViewControllers lastObject];
	
	if (!animated) 
    {        
        
		for (UIView *sub in self.subviews)
			[sub removeFromSuperview];
        
		[self addSubview:toViewController.view];
	}
	else 
    {
        
		[toViewController.view setPointX:-toViewController.view.frame.size.width];
		[self addSubview:toViewController.view];
		
		[UIView beginAnimations:@"pop" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.333f];
		[UIView setAnimationDelegate:self];
		self.userInteractionEnabled = NO;
		for (UIView *sub in self.subviews) {
			if (sub != toViewController.view) {
				[sub setPointX:self.frame.size.width];
			}
		}
		[toViewController.view setPointX:0];
		[UIView commitAnimations];
	}
	
	if ([self.delegate respondsToSelector:@selector(container:poppedToViewController:animated:)])
		[self.delegate container:self poppedToViewController:toViewController animated:animated];
}

-(void)popToRootViewControllerAnimated:(BOOL)animated {

	if ([pushedViewControllers count] <= 1) {
		return;
	}
	
	while ([pushedViewControllers count] > 1)
		[pushedViewControllers removeLastObject];
	
	UIViewController *toViewController = [pushedViewControllers lastObject];
	
	
	if (!animated) {

		for (UIView *sub in self.subviews)
			[sub removeFromSuperview];
        
		[self addSubview:toViewController.view];
	}
	else 
    {
        
		[toViewController.view setPointX:-toViewController.view.frame.size.width];
		[self addSubview:toViewController.view];
		
		[UIView beginAnimations:@"pop" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.333f];
		[UIView setAnimationDelegate:self];
		self.userInteractionEnabled = NO;
		for (UIView *sub in self.subviews) {
			if (sub != toViewController.view) {
				[sub setPointX:self.frame.size.width];
			}
		}

		[toViewController.view setPointX:0];
		[UIView commitAnimations];
	}
	
	if ([self.delegate respondsToSelector:@selector(container:poppedToViewController:animated:)])
		[self.delegate container:self poppedToViewController:toViewController animated:animated];
}


-(BOOL)canPop {
	return ([pushedViewControllers count] > 1);
}

-(UIView *)visibleViewController {
	return [pushedViewControllers lastObject];
}

@end



@implementation UIView (container)
- (EPCContainerView *)containerView {
	UIView *view = self.superview;
	
	while (view != nil && ![view isKindOfClass:[EPCContainerView class]])
		view = view.superview;
	
	NSAssert((view != nil && [view isKindOfClass:[EPCContainerView class]]), @"View not in a EPCContainerViewController");
	return (id)view;
}
@end

@implementation UIViewController (container)
- (EPCContainerView *)containerView {
	UIView *view = self.view.superview;
	
	while (view != nil && ![view isKindOfClass:[EPCContainerView class]])
		view = view.superview;
	
	NSAssert((view != nil && [view isKindOfClass:[EPCContainerView class]]), @"View not in a EPCContainerViewController");
	return (id)view;
}
@end

