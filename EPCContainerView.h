//
//  EPCContainerView.h
//
//  Created by Everton Postay Cunha on 11/25/11.
//

#import <Foundation/Foundation.h>

@class EPCContainerView;
@protocol ContainerViewDelegate <NSObject>
@optional
- (void)container:(EPCContainerView*)container pushedViewController:(UIViewController*)pushedViewController animated:(BOOL)animated;
- (void)container:(EPCContainerView*)container poppedToViewController:(UIViewController*)poppedToViewController animated:(BOOL)animated;
@end


@interface EPCContainerView : UIView {
	NSMutableArray *pushedViewControllers;
	
}

- (void)pushViewController:(UIViewController*)newViewController animated:(BOOL)animated;

- (void)pushNewRootViewController:(UIViewController*)newViewController animated:(BOOL)animated;

- (void)popToViewController:(UIViewController*)toViewController animated:(BOOL)animated;

- (void)popViewControllerAnimated:(BOOL)animated;

- (void)popToRootViewControllerAnimated:(BOOL)animated;

- (BOOL)canPop;

@property (nonatomic, readonly) UIViewController *visibleViewController;
@property (nonatomic, readonly) NSArray *pushedViewControllers;
@property (nonatomic, assign) IBOutlet id<ContainerViewDelegate>delegate;
@property (nonatomic, assign) IBOutlet UIViewController *containerViewController;

@end


@interface UIView (container)
- (EPCContainerView *)containerView;
@end

@interface UIViewController (container)
- (EPCContainerView *)containerView;
@end