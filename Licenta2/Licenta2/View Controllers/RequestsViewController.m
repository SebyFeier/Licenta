//
//  RequestsViewController.m
//  Licenta
//
//  Created by Sebastian Feier on 1/15/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import "RequestsViewController.h"
#import "LoginScreenViewController.h"
#import "RequestTableViewCell.h"
#import "NSDictionary+JSON.h"
#import "UIViewController+ProgressHud.h"
#import "Constants.h"
#import "DeviceRequestTableViewCell.h"

#define kGivePermissions @"Give Permissions"
#define kGiveDeviceApprovals @"Give Device Approvals";

@interface RequestsViewController ()

@end

@implementation RequestsViewController {
    DownloadManager *_downloadManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _allDetails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_requestType == DocumentRequest) {
        RequestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"requestCustomCell"];
        if (!cell) {
            cell = [[RequestTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"requestCustomCell"];
        }
        NSMutableDictionary *details = _allDetails[indexPath.row];
        cell.details = details;
        cell.delegate = self;
        cell.indexPath = indexPath;
        [cell updateCell];
        return cell;
    } else if (_requestType == DeviceRequest) {
        DeviceRequestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceRequestCustomCell"];
        if (!cell) {
            cell = [[DeviceRequestTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"deviceRequestCustomCell"];
        }
        NSMutableDictionary *details = _allDetails[indexPath.row];
        cell.deviceInfo = details;
        cell.delegate = self;
        [cell updateCell];
        return cell;
    }
    return nil;
}

- (void)readWriteButtonTapped:(NSDictionary *)details forIndexPath:(NSIndexPath *)indexPath {
}

- (void)enabledButtonTapped:(NSDictionary *)deviceInfo {
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)notNowButtonTapped:(id)sender {
    if (_requestType == DocumentRequest) {
        [self dismissViewControllerAnimated:YES completion:^{
            [(LoginScreenViewController *)_parent getDocuments];
        }];
    } else if (_requestType == DeviceRequest) {
        [self dismissViewControllerAnimated:YES completion:^{
            [(LoginScreenViewController *)_parent checkRequest];
        }];
    }
}

- (IBAction)saveButtonTapped:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Are you sure you want to give this permissions?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        if (_requestType == DocumentRequest) {
            NSString *users = @"";
            NSString *permissions = @"";
            NSString *documentIds = @"";
            for (NSDictionary *userInfo in _allDetails) {
                users = [users stringByAppendingPathComponent:userInfo[@"userId"]];
                documentIds = [documentIds stringByAppendingPathComponent:userInfo[@"documentId"]];
                if ([userInfo[@"readWrite"] boolValue]) {
                    permissions = [permissions stringByAppendingPathComponent:@"Write"];
                } else if ([userInfo[@"readOnly"] boolValue]){
                    permissions = [permissions stringByAppendingPathComponent:@"Read"];
                } else {
                    permissions = [permissions stringByAppendingPathComponent:@"None"];
                }
            }
            if (!_downloadManager) {
                _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
            }
            _downloadManager.callType = kGivePermissions;
            NSString *path = [NSString stringWithFormat:@"removeRequests.php?documentId=%@&user=%@&permission=%@", documentIds, users, permissions];
            [self showHudWithText:@""];
            [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
        } else if (_requestType == DeviceRequest) {
            NSString *userId = @"";
            NSString *udids = @"";
            NSString *approvals = @"";
            for (NSDictionary *deviceInfo in _allDetails) {
                userId = deviceInfo[@"userId"];
                udids = [udids stringByAppendingPathComponent:deviceInfo[@"deviceUdid"]];
                approvals = [approvals stringByAppendingPathComponent:[deviceInfo[@"isApproved"] stringValue]];
            }
            if (!_downloadManager) {
                _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
            }
            _downloadManager.callType = kGiveDeviceApprovals;
            NSString *path = [NSString stringWithFormat:@"removeDeviceRequest.php?userId=%@&deviceUdid=%@&isApproved=%@",userId, udids, approvals];
            [self showHudWithText:@""];
            [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
        }
    }
}

- (void)downloadManager:(DownloadManager *)downloadManager didDownloadWithError:(NSError *)error {
    [self removeHud];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)downloadManager:(DownloadManager *)downloadManager didDownloadSuccessfullyWithInfo:(id)responseInfo {
    [self removeHud];
    if ([responseInfo isKindOfClass:[NSData class]]){
        responseInfo = [[NSString alloc] initWithData:responseInfo encoding:NSUTF8StringEncoding];
    }
    NSDictionary *responseDict = [NSDictionary createJSONDictionaryFromNSString:responseInfo];
    if (_requestType == DocumentRequest) {
        if ([[responseDict objectForKey:@"status"] isEqualToString:@"OK"]) {
            [self dismissViewControllerAnimated:YES completion:^{
                [(LoginScreenViewController *)_parent getDocuments];
            }];
        }
    } else if (_requestType == DeviceRequest) {
        if ([[responseDict objectForKey:@"status"] isEqualToString:@"OK"]) {
            [self dismissViewControllerAnimated:YES completion:^{
                [(LoginScreenViewController *)_parent checkRequest];
            }];
        }
    }
}
@end
