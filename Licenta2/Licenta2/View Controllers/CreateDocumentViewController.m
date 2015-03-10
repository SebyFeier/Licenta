//
//  CreateDocumentViewController.m
//  Licenta
//
//  Created by Sebastian Feier on 1/13/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import "CreateDocumentViewController.h"
#import "PermissionTableViewCell.h"
#import "User.h"
#import "UserInfoModel.h"
#import "Constants.h"
#import "NSDictionary+JSON.h"
#import "DocumentsViewController.h"
#import "UIViewController+ProgressHud.h"

#define kSaveDocument @"Save Document"
#define kGivePermissions @"Give Permissions"
#define kGetMoreUsers @"Get More Users"

@interface CreateDocumentViewController ()

@end

@implementation CreateDocumentViewController {
    DownloadManager *_downloadManager;
    NSMutableDictionary *_newDocument;
    NSInteger _pageNumber;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _pageNumber = 2;
    for (NSMutableDictionary *user in _allUsers) {
        [user setObject:@(0) forKey:@"readOnly"];
        [user setObject:@(0) forKey:@"readWrite"];
    }
//    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonTapped:)];
//    self.navigationItem.rightBarButtonItem = saveButton;
    // Do any additional setup after loading the view.
}

- (void)saveButtonTapped:(id)sender {
    if (_documentNameLabel.text.length) {
        if (!_downloadManager) {
            _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
        }
        User *currentUser = [UserInfoModel retrieveCurrentUser];
        NSString *path = [NSString stringWithFormat:@"insertDocument.php?documentName=%@&createdBy=%@",_documentNameLabel.text,currentUser.userID];
        _downloadManager.callType = kSaveDocument;
        [self showHudWithText:@""];
        [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please add a name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)cancelButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)downloadManager:(DownloadManager *)downloadManager didDownloadSuccessfullyWithInfo:(id)responseInfo {
    [self removeHud];
    if ([responseInfo isKindOfClass:[NSData class]]){
        responseInfo = [[NSString alloc] initWithData:responseInfo encoding:NSUTF8StringEncoding];
    }
    NSDictionary *responseDict = [NSDictionary createJSONDictionaryFromNSString:responseInfo];
    if ([downloadManager.callType isEqualToString:kSaveDocument]) {
        if ([responseDict[@"status"] isEqualToString:@"ERROR"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:responseDict[@"response"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            return;
        } else {
            _newDocument = [responseDict[@"documents"] firstObject];
//            NSMutableArray *users = [[NSMutableArray alloc] initWithCapacity:0];
//            NSMutableArray *permissions = [[NSMutableArray alloc] initWithCapacity:0];
            User *currentUser = [UserInfoModel retrieveCurrentUser];
            NSString *users = currentUser.userID;
            NSString *permissions = @"Write";
            for (NSDictionary *userInfo in _allUsers) {
//                [users addObject:userInfo[@"userID"]];
                users = [users stringByAppendingPathComponent:userInfo[@"userID"]];
                if ([userInfo[@"readWrite"] boolValue]) {
//                    [permissions addObject:@"Write"];
                    permissions = [permissions stringByAppendingPathComponent:@"Write"];
                } else if ([userInfo[@"readOnly"] boolValue]){
//                    [permissions addObject:@"Read"];
                    permissions = [permissions stringByAppendingPathComponent:@"Read"];
                } else {
                    permissions = [permissions stringByAppendingPathComponent:@"None"];
                }
            }
            if (!_downloadManager) {
                _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
            }
            _downloadManager.callType = kGivePermissions;
            NSString *path = [NSString stringWithFormat:@"givePermissions.php?documentId=%@&user=%@&permission=%@",_newDocument[@"documentId"],users, permissions];
            [self showHudWithText:@""];
            [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
//                    [self dismissViewControllerAnimated:YES completion:^{
//                        [(DocumentsViewController *)_parentController updateDocumentListWithNewDocument:user];
//                    }];
            
        }
    } else if ([downloadManager.callType isEqualToString:kGivePermissions]) {
        if ([[responseDict objectForKey:@"status"] isEqualToString:@"ERROR"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        } else if ([[responseDict objectForKey:@"status"] isEqualToString:@"OK"]) {
            [self dismissViewControllerAnimated:YES completion:^{
                [(DocumentsViewController *)_parentController updateDocumentListWithNewDocument:_newDocument];
            }];

        }
    } else if ([downloadManager.callType isEqualToString:kGetMoreUsers]) {
        if (responseDict) {
            for (NSMutableDictionary *user in responseDict[@"users"]) {
                [_allUsers addObject:user];
            }
            [_usersTableView reloadData];
        }
    }
}

- (void)downloadManager:(DownloadManager *)downloadManager didDownloadWithError:(NSError *)error {
    [self removeHud];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _allUsers.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 50)];
    label.text = @"Give permissions for this document";
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PermissionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"permissionCustomCell"];
    if (!cell) {
        cell = [[PermissionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"permissionCustomCell"];
    }
    NSMutableDictionary *user = _allUsers[indexPath.row];
    cell.user = user;
    cell.usernameLabel.text = user[@"username"];
    cell.delegate = self;
    cell.indexPath = indexPath;
    if (indexPath.row == _allUsers.count - 3) {
        if (!_downloadManager) {
            _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
        }
        _downloadManager.callType = kGetMoreUsers;
        User *currentUser = [UserInfoModel retrieveCurrentUser];
        NSString *path = [NSString stringWithFormat:@"getUsers.php?userId=%@&page=%ld",currentUser.userID,_pageNumber++];
        [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
    }
    return cell;
}

- (void)readWriteButtonTapped:(NSDictionary *)user forIndexPath:(NSIndexPath *)indexPath {
    for (NSMutableDictionary *userInfo in _allUsers) {
        if ([userInfo[@"userID"] integerValue] == [user[@"userID"] integerValue]) {
            [_allUsers replaceObjectAtIndex:indexPath.row withObject:user];
            break;
        }
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
