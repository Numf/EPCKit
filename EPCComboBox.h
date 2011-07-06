//
//  EPCComboBox.h
//
//  Created by Everton Postay Cunha on 28/06/11.
//  Copyright 2011 Everton Postay Cunha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPCComboBoxDelegate.h"

@interface EPCComboBox : UIView <UITableViewDataSource, UITableViewDelegate> {
    UIButton *button;
	UITableView *tableView;
	UIButton *selectedViewButton;
}

@property (nonatomic, assign) IBOutlet id<EPCComboBoxDelegate> delegate;

@property (nonatomic, readonly) int indexOfSelectedRow;

@property (nonatomic, assign) UIView *selectedView;

@property (nonatomic, readonly) BOOL listIsOpen;

- (void)selectRowAtIndex:(int)index;

- (void)reloadData;

@end
