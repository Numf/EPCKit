//
//  EPCButton.h
//
//  Created by Everton Postay Cunha on 16/07/12.
//

#import <UIKit/UIKit.h>
#import "EPCImageView.h"

@interface EPCButton : UIControl {
}

@property (nonatomic, retain) id dataObject;
@property (nonatomic, readonly) EPCImageView *epcImageView;
@end
