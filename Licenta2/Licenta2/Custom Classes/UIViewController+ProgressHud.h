//
//  UIViewController+ProgressHud.h
//  O3CoreMaps
//
//  Created by Raica Cristian on 13/12/13.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"


@interface UIViewController (ProgressHud)

- (void)showHudWithText:(NSString *)text;
- (void)removeHudWithText:(NSString *)text withDelay:(CGFloat )delay;
- (void)removeHud;

@end
