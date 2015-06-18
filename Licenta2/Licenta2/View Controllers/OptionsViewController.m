//
//  OptionsViewController.m
//  Licenta
//
//  Created by Sebastian Feier on 1/14/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import "OptionsViewController.h"
#import "LogoutTableViewCell.h"
#import "DocumentOptionsTableViewCell.h"
#import "User.h"
#import "UserInfoModel.h"
#import "Constants.h"
#import "NSDictionary+JSON.h"
#import "DocumentsViewController.h"
#import "UIViewController+ProgressHud.h"
#import "UsersViewController.h"

#define kGetUserWithAccess @"Get Users With Access"
#define kGetMoreDocuments @"Get More Documents"
#define kLogout @"Logout"

@interface OptionsViewController ()

@end

@implementation OptionsViewController {
    DownloadManager *_downloadManager;
    NSDictionary *_selectedDocument;
    NSInteger _pageNumber;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _pageNumber = 2;
    self.navigationItem.title = @"Options";
    UIImage *image = [UIImage imageNamed:@"back-button"];
    CGRect frame = CGRectMake(0, 0, 61, 31);
    UIButton *backButton = [[UIButton alloc] initWithFrame:frame];
    [backButton setBackgroundImage:image forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = barButtonItem;
    // Do any additional setup after loading the view.
}

- (void)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return _documents.count;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_optionsTableView.frame), 50)];
    if (section == 1) {
        label.text = @"Update permissions for your documents";
    } else {
        label.text = @"Username";
    }
    return label;
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        LogoutTableViewCell *logoutCell = [tableView dequeueReusableCellWithIdentifier:@"logoutCustomCell"];
        if (!logoutCell) {
            logoutCell = [[LogoutTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"logoutCustomCell"];
        }
        User *currentUser = [UserInfoModel retrieveCurrentUser];
        logoutCell.usernameLabel.text = currentUser.username;
        logoutCell.parent = self;
        return logoutCell;
    } else if (indexPath.section == 1) {
        DocumentOptionsTableViewCell *documentCell = [tableView dequeueReusableCellWithIdentifier:@"documentOptionsCustomCell"];
        if (!documentCell) {
            documentCell = [[DocumentOptionsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"documentOptionsCustomCell"];
        }
        NSDictionary *document = _documents[indexPath.row];
        documentCell.documentLabel.text = document[@"documentName"];
        if (indexPath.row == _documents.count - 3) {
            if (!_downloadManager) {
                _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
            }
            _downloadManager.callType = kGetMoreDocuments;
            User *currentUser = [UserInfoModel retrieveCurrentUser];
            NSString *path = [NSString stringWithFormat:@"getDocumentForUser.php?userId=%@&page=%ld",currentUser.userID,_pageNumber++];
            [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
        }
        return documentCell;
    }
    return nil;
}

- (void)logout {
    if (!_downloadManager) {
        _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
    }
    _downloadManager.callType = kLogout;
    User *currentUser = [UserInfoModel retrieveCurrentUser];
    NSString *path = [NSString stringWithFormat:@"logoutUser.php?userId=%@",currentUser.userID];
    [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        _selectedDocument = _documents[indexPath.row];
        if (!_downloadManager) {
            _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
        }
        _downloadManager.callType = kGetUserWithAccess;
        NSString *path = [NSString stringWithFormat:@"getUserAndPermissions.php?documentId=%@&page=1",_selectedDocument[@"documentId"]];
        [self showHudWithText:@""];
        [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
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
    if ([downloadManager.callType isEqualToString:kGetUserWithAccess]) {
        if (responseDict) {
            NSMutableArray *users = responseDict[@"users"];
            UsersViewController *userViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"usersViewControllerID"];
            userViewController.allUsers = users;
            userViewController.documentID = _selectedDocument[@"documentId"];
            [self.navigationController pushViewController:userViewController animated:YES];
        }
    } else if ([downloadManager.callType isEqualToString:kGetMoreDocuments]) {
        if (responseDict) {
            for (NSDictionary *doc in responseDict[@"documents"]) {
                [_documents addObject:doc];
            }
            [_optionsTableView reloadData];
        }
    } else if ([downloadManager.callType isEqualToString:kLogout]) {
        if ([responseDict[@"status"] isEqualToString:@"OK"]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
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
