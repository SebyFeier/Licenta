//
//  ViewController.m
//  Licenta2
//
//  Created by Sebastian Feier on 1/5/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import "ViewController.h"
#import "DocumentsViewController.h"
#import "Constants.h"
#import "NSDictionary+JSON.h"
#import "LoginScreenViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    DownloadManager *_downloadManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonTapped:(id)sender {
    LoginScreenViewController *loginScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginScreenViewControllerID"];
    loginScreen.isLogin = YES;
    [self.navigationController pushViewController:loginScreen animated:YES];
}

- (IBAction)registerButtonTapped:(id)sender {
    LoginScreenViewController *loginScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginScreenViewControllerID"];
    loginScreen.isLogin = NO;
    [self.navigationController pushViewController:loginScreen animated:YES];
}

@end
