//
//  RadioControl.h
//  BradescoRIApp
//
//  Created by AG2 on 14/06/11.
//  Copyright 2011 Bradesco. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RadioControl : NSObject {
}

- (id)initWithButtons:(NSArray *)btns;

@property (nonatomic, retain) NSArray *buttons;
@property (nonatomic, readonly) UIButton *selectedButton;
@end
