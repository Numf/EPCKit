//
//  EPCComboBoxDelegate.h
//
//  Created by Everton Postay Cunha on 28/06/11.
//  Copyright 2011 Everton Postay Cunha. All rights reserved.
//

#import <Foundation/Foundation.h>


@class EPCComboBox;

@protocol EPCComboBoxDelegate <NSObject>

@required
- (UIButton*)buttonForComboBox:(EPCComboBox*)comboBox;

- (UITableViewCell *)comboBox:(EPCComboBox*)comboBox tableView:(UITableView*)tableView viewForRowAtIndex:(int)index;

- (NSInteger)numberOfRowsForComboBox:(EPCComboBox*)comboBox;

- (UIView*)comboBox:(EPCComboBox *)comboBox viewForSelectedItemWhileOpen:(BOOL)open;

@optional
- (void)comboBox:(EPCComboBox *)comboBox didSelectedRowAtIndex:(int)index;

@end
