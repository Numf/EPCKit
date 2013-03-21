//
//  EPCTableView.h
//
//  Created by Everton Cunha on 21/03/13.
//


/* 
 
 * * INSTRUCTIONS * *
 
 
 * Required to override:
 
 - reloadTableViewDataSource
 
 
 * Optional to override and call super:
 
 - scrollViewDidScroll:
 - scrollViewDidEndDragging:willDecelerate:
 
 
 * Optional if you want to customize refresh view
 
 - customRefreshView (Note Autosizing rules)
 
*/

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@class EPCTableViewRefreshView;

@interface EPCTableViewController : UIViewController <UITableViewDelegate, EGORefreshTableHeaderDelegate> {
	UIColor *_activityIndicatorViewColor;
	BOOL _reloading;
}

- (void)beginRefreshing;

- (void)endRefreshing;

- (void)setRefreshActivityIndicatorViewColor:(UIColor*)color;

- (void)reloadTableViewDataSource; // * REQUIRED OVERRIDE * //

/*
 Your custom view will be streched to TableView's width and height, note your Autosizing rules.
 */
- (EPCTableViewRefreshView*)customRefreshView; // * OPTIONAL OVERRIDE * //

@property (assign) IBOutlet UITableView *tableView;

@property (strong) UITableViewController *tableViewController;

@property (strong) EPCTableViewRefreshView *refreshView;

@property (getter=refreshIsHidden) BOOL refreshHidden;

@end




@interface EPCTableViewRefreshView : EGORefreshTableHeaderView {
	int _offsetHeight;
}

- (void)beginRefreshing;

- (void)endRefreshing;

@property (assign) IBOutlet UIActivityIndicatorView *activityView;

@property (assign) IBOutlet UILabel *statusLabel;

@property (assign) IBOutlet UIImageView *arrowDownImageView;

@end