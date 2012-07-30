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


#pragma mark View Appear
-(void)callViewWillAppearWithoutAnimation:(UIViewController *)vc
{
    if(SYSTEM_VERSION_LESS_THAN(@"5.0"))
        [vc viewWillAppear:NO];
}
-(void)callViewWillAppearWithAnimation:(UIViewController *)vc
{
    if(SYSTEM_VERSION_LESS_THAN(@"5.0"))
        [vc viewWillAppear:YES];
}

-(void)callViewDidAppearWithoutAnimation:(UIViewController *)vc
{
    if(SYSTEM_VERSION_LESS_THAN(@"5.0"))    
        [vc viewDidAppear:NO];
}
-(void)callViewDidAppearWithAnimation:(UIViewController *)vc
{
    if(SYSTEM_VERSION_LESS_THAN(@"5.0"))
        [vc viewDidAppear:YES];
}

#pragma mark View Disappear
-(void)callViewWillDisappearWithoutAnimation:(UIViewController *)vc
{
    if(SYSTEM_VERSION_LESS_THAN(@"5.0"))    
        [vc viewWillDisappear:NO];
}
-(void)callViewWillDisappearWithAnimation:(UIViewController *)vc
{
    if(SYSTEM_VERSION_LESS_THAN(@"5.0"))
        [vc viewWillDisappear:YES];
}

-(void)callViewDidDisappearWithoutAnimation:(UIViewController *)vc
{
    if(SYSTEM_VERSION_LESS_THAN(@"5.0"))
        [vc viewDidDisappear:NO];
}
-(void)callViewDidDisappearWithAnimation:(UIViewController *)vc
{
    if(SYSTEM_VERSION_LESS_THAN(@"5.0"))
        [vc viewDidDisappear:YES];
}



-(void)pushNewRootViewController:(UIViewController *)newViewController animated:(BOOL)animated {
	NSAssert((newViewController != nil), @"Trying to push nil");
	
	if (!pushedViewControllers)
		pushedViewControllers = [[NSMutableArray array] retain];
	
	
    UIViewController *fromViewController = [[pushedViewControllers lastObject] retain];
    [fromViewController performSelector:@selector(release) withObject:nil afterDelay:0.4f];
    NSLog(@"******* fromview: %@", fromViewController);
    
    [pushedViewControllers removeAllObjects];
	[pushedViewControllers addObject:newViewController];
    
	if (self.autoresizesSubviews)
		newViewController.view.frame = self.bounds;
	
	if (!animated) 
    {
		[self callViewWillDisappearWithoutAnimation:fromViewController];
        
		for (UIView *sub in self.subviews)
			[sub removeFromSuperview];
        
        [self callViewDidDisappearWithoutAnimation:fromViewController];
        
        [self callViewWillAppearWithoutAnimation:newViewController];
		[self addSubview:newViewController.view];
        [self callViewDidAppearWithoutAnimation:newViewController];
	}
	else {
		
        [self callViewWillAppearWithAnimation:newViewController];
        [self callViewWillDisappearWithAnimation:fromViewController];
        
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
        [self performSelector:@selector(callViewDidAppearWithAnimation:) withObject:newViewController afterDelay:0.4f];
        [self performSelector:@selector(callViewDidDisappearWithAnimation:) withObject:fromViewController afterDelay:0.39f];
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
	
    UIViewController *fromViewController = [pushedViewControllers lastObject];
    
	[pushedViewControllers addObject:newViewController];
    
    
	
	if (self.autoresizesSubviews)
		newViewController.view.frame = self.bounds;
	
	if (!animated) {
        [self callViewWillDisappearWithoutAnimation:fromViewController];
		for (UIView *sub in self.subviews)
			[sub removeFromSuperview];
        [self callViewDidDisappearWithoutAnimation:fromViewController];
		
        [self callViewWillAppearWithoutAnimation:newViewController];
		[self addSubview:newViewController.view];
        [self callViewDidAppearWithoutAnimation:newViewController];
	}
	else {
		[newViewController.view setPointX:self.frame.size.width];
		[self addSubview:newViewController.view];
        
        [self callViewWillDisappearWithoutAnimation:fromViewController];
        [self callViewWillAppearWithAnimation:newViewController];
        
		
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
        
        [self performSelector:@selector(callViewDidAppearWithAnimation:) withObject:newViewController afterDelay:0.4f];
        [self performSelector:@selector(callViewDidDisappearWithAnimation:) withObject:fromViewController afterDelay:0.4f];
		[newViewController.view setPointX:0];
		[UIView commitAnimations];
		
	}
	
	if ([self.delegate respondsToSelector:@selector(container:pushedViewController:animated:)])
		[self.delegate container:self pushedViewController:newViewController animated:animated];
}

- (void)popToViewController:(UIViewController *)toViewController animated:(BOOL)animated {
	
	if (![pushedViewControllers containsObject:toViewController])
		[NSException raise:@"Exception!" format:@"Trying to pop a view that wasn't push in the container."];
    
    UIViewController *fromViewController = [pushedViewControllers lastObject];
	
	if (!animated) 
    {        
        [self callViewWillDisappearWithoutAnimation:fromViewController];
        
		for (UIView *sub in self.subviews)
			[sub removeFromSuperview];
                
        [self callViewDidDisappearWithoutAnimation:fromViewController];
		
        [self callViewWillAppearWithoutAnimation:toViewController];
		[self addSubview:toViewController.view];
        [self callViewDidAppearWithoutAnimation:toViewController];
	}
	else 
    {
        
        [self callViewWillDisappearWithAnimation:fromViewController];        
        [self callViewWillAppearWithAnimation:toViewController];
        
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
    

    [self callViewDidDisappearWithAnimation:fromViewController];
    
    while([pushedViewControllers lastObject] != toViewController)
    {
		[pushedViewControllers removeLastObject];
    }
	
	if ([self.delegate respondsToSelector:@selector(container:poppedViewController:animated:)])
		[self.delegate container:self poppedViewController:toViewController animated:animated];
	
}

-(void)popViewControllerAnimated:(BOOL)animated
{
	assert([pushedViewControllers count] > 0);
	
	UIViewController *fromViewController = [[pushedViewControllers lastObject] retain];
	[fromViewController performSelector:@selector(release) withObject:nil afterDelay:0.4f];    
	
	[pushedViewControllers removeLastObject];
	UIViewController *toViewController = [pushedViewControllers lastObject];
	
	if (!animated) 
    {        
        [self callViewWillDisappearWithoutAnimation:fromViewController];
        
		for (UIView *sub in self.subviews)
			[sub removeFromSuperview];
		
        [self callViewDidDisappearWithoutAnimation:fromViewController];
        
        
        [self callViewWillAppearWithoutAnimation:toViewController];
		[self addSubview:toViewController.view];
        [self callViewDidAppearWithoutAnimation:toViewController];
	}
	else 
    {
        [self callViewWillDisappearWithAnimation:fromViewController];
        [self callViewWillAppearWithoutAnimation:toViewController];
        
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
        [self performSelector:@selector(callViewDidAppearWithAnimation:) withObject:toViewController afterDelay:0.4f];
        [self performSelector:@selector(callViewDidDisappearWithAnimation:) withObject:fromViewController afterDelay:0.39f];
		[toViewController.view setPointX:0];
		[UIView commitAnimations];
	}
	
	if ([self.delegate respondsToSelector:@selector(container:poppedViewController:animated:)])
		[self.delegate container:self poppedViewController:toViewController animated:animated];
}

-(void)popToRootViewControllerAnimated:(BOOL)animated {

	if ([pushedViewControllers count] <= 1) {
		return;
	}
	
	UIViewController *fromViewController = [[pushedViewControllers lastObject] retain];
	[fromViewController performSelector:@selector(release) withObject:nil afterDelay:0.4f];
	
	while ([pushedViewControllers count] > 1)
		[pushedViewControllers removeLastObject];
	
	UIViewController *toViewController = [pushedViewControllers lastObject];
	
	
	if (!animated) {
        
        [self callViewWillDisappearWithoutAnimation:fromViewController];

		for (UIView *sub in self.subviews)
			[sub removeFromSuperview];
        
        [self callViewDidDisappearWithoutAnimation:fromViewController];
		
        [self callViewWillAppearWithoutAnimation:toViewController];
		[self addSubview:toViewController.view];
        [self callViewDidAppearWithoutAnimation:toViewController];
	}
	else 
    {
        [self callViewWillDisappearWithAnimation:fromViewController];        
        [self callViewWillAppearWithAnimation:toViewController];
        
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
        [self performSelector:@selector(callViewDidAppearWithAnimation:) withObject:toViewController afterDelay:0.4f];
        [self performSelector:@selector(callViewDidDisappearWithAnimation:) withObject:fromViewController afterDelay:0.39f];
		[toViewController.view setPointX:0];
		[UIView commitAnimations];
	}
	
	if ([self.delegate respondsToSelector:@selector(container:poppedViewController:animated:)])
		[self.delegate container:self poppedViewController:toViewController animated:animated];
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

