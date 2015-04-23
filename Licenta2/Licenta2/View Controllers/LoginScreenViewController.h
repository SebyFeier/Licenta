//
//  LoginScreenViewController.h
//  Licenta
//
//  Created by Sebastian Feier on 1/12/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadManager.h"
#import "ModifiedDocumentsViewController.h"

@interface LoginScreenViewController : UIViewController<DownloadManagerDelegate, UITextFieldDelegate, UIAlertViewDelegate, ModifiedDocumentDelegate>
- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)loginRegisterButtonTapped:(id)sender;

@property (nonatomic, assign) BOOL isLogin;

- (void)getDocuments;
- (void)checkRequest;

@end
