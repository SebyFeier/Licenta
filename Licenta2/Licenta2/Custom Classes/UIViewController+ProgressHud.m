//
//  UIViewController+ProgressHud.m
//  O3CoreMaps
//
//  Created by Raica Cristian on 13/12/13.
//
//

#import "UIViewController+ProgressHud.h"

@implementation UIViewController (ProgressHud)

MBProgressHUD *mProgressHud;


- (void)showHudWithText:(NSString *)text {
    mProgressHud  = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    mProgressHud.labelText = text;
}
- (void)removeHud {
    [mProgressHud hide:YES];
    mProgressHud = nil;
}
- (void)removeHudWithText:(NSString *)text withDelay:(CGFloat )delay {
    mProgressHud.labelText = text;
    [mProgressHud setMode:MBProgressHUDModeText];
    [mProgressHud hide:YES afterDelay:delay];
    mProgressHud = nil;
}
@end
