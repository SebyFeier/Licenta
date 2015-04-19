//
//  LoginScreenViewController.m
//  Licenta
//
//  Created by Sebastian Feier on 1/12/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import "LoginScreenViewController.h"
#import "Constants.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSDictionary+JSON.h"
#import "DocumentsViewController.h"
#import "User.h"
#import "UserInfoModel.h"
#import "UIViewController+ProgressHud.h"
#import "RequestsViewController.h"

#define kLoginUser @"Login User"
#define kGetDocuments @"Get Documents"
#define kCheckRequests @"Check Requests"
#define kSendDeviceRequest @"Send Device Request"
#define kCheckDeviceRequest @"Check Device Requests"
#define kGetNotifications @"Get Notifications"

@interface LoginScreenViewController ()

@end

@implementation LoginScreenViewController {
    DownloadManager *_downloadManager;
    NSString *_userId;
    NSString *_userIdForDevice;
    NSDictionary *_loggedInUser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _usernameTextField.text = @"user1";
    _passwordTextField.text = @"password";
    self.navigationController.navigationBarHidden = YES;
    if (_isLogin) {
        [_loginRegisterButton setImage:[UIImage imageNamed:@"signin-button"] forState:UIControlStateNormal];
    } else {
        [_loginRegisterButton setImage:[UIImage imageNamed:@"register"] forState:UIControlStateNormal];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSMutableString *)encodeMediaUrl:(NSString *)mediaUrl {
    
    const char *ptr = [mediaUrl UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    return output;
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)loginRegisterButtonTapped:(id)sender {
    if (!_downloadManager) {
        _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
    }
    NSString *uniqueIdentifier = @"";
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    if ([[[UIDevice currentDevice] name] isEqualToString:@"iPhone Simulator"]) {
        uniqueIdentifier = @"123456789";
    }
    NSString *path = [NSString stringWithFormat:@"username=%@&password=%@&deviceUdid=%@&deviceName=%@",_usernameTextField.text, [self encodeMediaUrl:_passwordTextField.text],uniqueIdentifier,[[UIDevice currentDevice] name]];
    NSString *serverUrl = @"";
    if (_isLogin) {
        serverUrl = [serverUrl stringByAppendingString:@"loginUser.php?"];
    } else {
        serverUrl = [serverUrl stringByAppendingString:@"createUser.php?"];
    }
    serverUrl = [serverUrl stringByAppendingString:path];
    _downloadManager.callType = kLoginUser;
    [self showHudWithText:@""];
    [_downloadManager downloadFromServer:kServerUrl atPath:serverUrl withParameters:nil];
}

- (void)downloadManager:(DownloadManager *)downloadManager didDownloadWithError:(NSError *)error {
    [self removeHud];
    [self createAlertViewWithTitle:@"Error" andMessage:[error localizedDescription]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        if (!_downloadManager) {
            _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
        }
        NSString *uniqueIdentifier = @"";
        if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
            uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        }
        if ([[[UIDevice currentDevice] name] isEqualToString:@"iPhone Simulator"]) {
            uniqueIdentifier = @"123456789";
        }
        NSString *path = [NSString stringWithFormat:@"sendDeviceRequest.php?userId=%@&deviceUdid=%@",_userIdForDevice, uniqueIdentifier];
        _downloadManager.callType = kSendDeviceRequest;
        [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
    }
}

- (void)downloadManager:(DownloadManager *)downloadManager didDownloadSuccessfullyWithInfo:(id)responseInfo {
    [self removeHud];
    if ([responseInfo isKindOfClass:[NSData class]]){
        responseInfo = [[NSString alloc] initWithData:responseInfo encoding:NSUTF8StringEncoding];
    }
    NSDictionary *responseDict = [NSDictionary createJSONDictionaryFromNSString:responseInfo];
    if (!responseDict) {
        if ([downloadManager.callType isEqualToString:kLoginUser]) {
            [self createAlertViewWithTitle:@"Error" andMessage:@"User does not exist"];
        } else if ([downloadManager.callType isEqualToString:kGetDocuments]) {
            DocumentsViewController *documentsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"documentsViewControllerID"];
            documentsViewController.documents = nil;
            [self.navigationController pushViewController:documentsViewController animated:YES];
        } else if ([downloadManager.callType isEqualToString:kCheckRequests]) {
            [self getDocuments];
        } else if ([downloadManager.callType isEqualToString:kCheckDeviceRequest]) {
            [self checkRequest];
        } else if ([downloadManager.callType isEqualToString:kGetNotifications]) {
//            [self checkRequest];
            if (!_downloadManager) {
                _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
            }
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:_loggedInUser[@"username"] forKey:@"username"];
            [UserInfoModel saveUserWithUsername:_loggedInUser[@"username"] andUserId:_loggedInUser[@"userID"]];
            User *currentUser = [UserInfoModel retrieveCurrentUser];
            [userDefaults synchronize];
            _downloadManager.callType = kCheckDeviceRequest;
            NSString *path = [NSString stringWithFormat:@"checkDeviceRequests.php?userId=%@",currentUser.userID];
            [self showHudWithText:@""];
            [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];

        }
    } else {
        if ([downloadManager.callType isEqualToString:kLoginUser]) {
            if ([[responseDict objectForKey:@"status"] isEqualToString:@"ERROR"]) {
                if ([responseDict objectForKey:@"userId"]) {
                    _userIdForDevice = responseDict[@"userId"];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDict objectForKey:@"response"] delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
                    [alertView show];
                    return;
                } else {
                    
                    [self createAlertViewWithTitle:@"Error" andMessage:[responseDict objectForKey:@"response"]];
                    return;
                }
            } else {
                NSDictionary *user = [[responseDict objectForKey:@"users"] firstObject];
                _loggedInUser = user;
                if (!_downloadManager) {
                    _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
                }
                NSString *path = [NSString stringWithFormat:@"getNotifications.php?userId=%@",user[@"userID"]];
                _downloadManager.callType = kGetNotifications;
                [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
            }
        } else if ([downloadManager.callType isEqualToString:kGetDocuments]) {
            if ([[responseDict objectForKey:@"status"] isEqualToString:@"ERROR"]) {
                [self createAlertViewWithTitle:@"Error" andMessage:[responseDict objectForKey:@"response"]];
                return;
            } else {
                NSArray *allDocuments = [responseDict objectForKey:@"documents"];
                DocumentsViewController *documentsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"documentsViewControllerID"];
                documentsViewController.documents = [NSMutableArray arrayWithArray:allDocuments];
                [self.navigationController pushViewController:documentsViewController animated:YES];
            }
            
        } else if ([downloadManager.callType isEqualToString:kCheckRequests]) {
            if ([[responseDict objectForKey:@"status"] isEqualToString:@"ERROR"]) {
                [self createAlertViewWithTitle:@"Error" andMessage:[responseDict objectForKey:@"response"]];
                return;
            } else {
                RequestsViewController *requests = [self.storyboard instantiateViewControllerWithIdentifier:@"requestsViewControllerID"];
                requests.allDetails = responseDict[@"requests"];
                requests.parent = self;
                requests.requestType = DocumentRequest;
                [self presentViewController:requests animated:YES completion:nil];
            }
        } else if ([downloadManager.callType isEqualToString:kSendDeviceRequest]) {
            if ([[responseDict objectForKey:@"status"] isEqualToString:@"OK"]) {
                [self createAlertViewWithTitle:@"OK" andMessage:[responseDict objectForKey:@"response"]];
            }
        } else if ([downloadManager.callType isEqualToString:kCheckDeviceRequest]) {
            RequestsViewController *requests = [self.storyboard instantiateViewControllerWithIdentifier:@"requestsViewControllerID"];
            requests.allDetails = responseDict[@"deviceRequests"];
            requests.parent = self;
            requests.requestType = DeviceRequest;
            [self presentViewController:requests animated:YES completion:nil];
        } else if ([downloadManager.callType isEqualToString:kGetNotifications]) {
            if ([responseDict isKindOfClass:[NSArray class]]) {
                ModifiedDocumentsViewController *modifiedDocuments = [self.storyboard instantiateViewControllerWithIdentifier:@"modifiedDocumentsViewControllerId"];
                modifiedDocuments.delegate = self;
                modifiedDocuments.modifiedDocuments = (NSArray *)responseDict;
                [self.navigationController presentViewController:modifiedDocuments animated:YES completion:nil];
            }
        }
    }
    
    NSLog(@"%@",responseDict);
}

- (void)closeButtonTapped {
    if (!_downloadManager) {
        _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_loggedInUser[@"username"] forKey:@"username"];
    [UserInfoModel saveUserWithUsername:_loggedInUser[@"username"] andUserId:_loggedInUser[@"userID"]];
    User *currentUser = [UserInfoModel retrieveCurrentUser];
    [userDefaults synchronize];
    _downloadManager.callType = kCheckDeviceRequest;
    NSString *path = [NSString stringWithFormat:@"checkDeviceRequests.php?userId=%@",currentUser.userID];
    [self showHudWithText:@""];
    [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];

}

- (void)createAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)checkRequest {
    User *currentUser = [UserInfoModel retrieveCurrentUser];
    _downloadManager.callType = kCheckRequests;
    NSString *path = [NSString stringWithFormat:@"checkForRequests.php?userId=%@",currentUser.userID];
    [self showHudWithText:@""];
    [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
}

- (void)getDocuments {
    if (!_downloadManager) {
        _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
    }
    User *currentUser = [UserInfoModel retrieveCurrentUser];
    NSString *path = [NSString stringWithFormat:@"getAllDocuments.php?userId=%@&page=1",currentUser.userID];
    _downloadManager.callType = kGetDocuments;
    [self showHudWithText:@""];
    [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];

}

@end
