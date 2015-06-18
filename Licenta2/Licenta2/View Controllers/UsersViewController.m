//
//  UsersViewController.m
//  Licenta
//
//  Created by Sebastian Feier on 1/15/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import "UsersViewController.h"
#import "UserOptionsTableViewCell.h"
#import "User.h"
#import "UserInfoModel.h"
#import "UIViewController+ProgressHud.h"
#import "Constants.h"
#import "NSDictionary+JSON.h"

#define kGivePermissions @"Give Permissions"
#define kGetMoreUsers @"Get More Users"

@interface UsersViewController ()

@end

@implementation UsersViewController {
    DownloadManager *_downloadManager;
    NSInteger _pageNumber;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _pageNumber = 2;
    self.navigationItem.title = @"Users";
    UIImage *image = [UIImage imageNamed:@"save-button"];
    CGRect frame = CGRectMake(0, 0, 61, 31);
    UIButton *saveButton = [[UIButton alloc] initWithFrame:frame];
    [saveButton setBackgroundImage:image forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    UIImage *backImage = [UIImage imageNamed:@"back-button"];
    CGRect backFrame = CGRectMake(0, 0, 61, 31);
    UIButton *backButton = [[UIButton alloc] initWithFrame:backFrame];
    [backButton setBackgroundImage:backImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    // Do any additional setup after loading the view.
}

- (void)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveButtonTapped:(id)sender {
    NSString *users = @"";
    NSString *permissions = @"";
    for (NSDictionary *userInfo in _allUsers) {
        users = [users stringByAppendingPathComponent:userInfo[@"userID"]];
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
    NSString *path = [NSString stringWithFormat:@"updatePermissions.php?documentId=%@&user=%@&permission=%@", _documentID, users, permissions];
    [self showHudWithText:@""];
    [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
}

- (void)downloadManager:(DownloadManager *)downloadManager didDownloadWithError:(NSError *)error {
    [self removeHud];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)downloadManager:(DownloadManager *)downloadManager didDownloadSuccessfullyWithInfo:(id)responseInfo {
    [self removeHud];
    if ([responseInfo isKindOfClass:[NSData class]]){
        responseInfo = [[NSString alloc] initWithData:responseInfo encoding:NSUTF8StringEncoding];
    }
    NSDictionary *responseDict = [NSDictionary createJSONDictionaryFromNSString:responseInfo];
    if ([downloadManager.callType isEqualToString:kGivePermissions]) {
        if ([[responseDict objectForKey:@"status"] isEqualToString:@"OK"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"OK" message:@"Permissions updated" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _allUsers.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserOptionsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userOptionsCustomCell"];
    if (!cell) {
        cell = [[UserOptionsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userOptionsCustomCell"];
    }
    NSMutableDictionary *user = _allUsers[indexPath.row];
    cell.user = user;
    cell.documentsLabel.text = user[@"username"];
    cell.delegate = self;
    cell.indexPath = indexPath;
    [cell updateCell];
    if (indexPath.row == _allUsers.count - 3) {
        if (!_downloadManager) {
            _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
        }
        _downloadManager.callType = kGetMoreUsers;
        NSString *path = [NSString stringWithFormat:@"getUserAndPermissions.php?documentId=%@&page=%ld",_documentID,_pageNumber++];
        [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
