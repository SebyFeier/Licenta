//
//  DocumentsViewController.m
//  Licenta
//
//  Created by Sebastian Feier on 1/5/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import "DocumentsViewController.h"
#import "Constants.h"
#import "DocumentViewController.h"
#import "NSDictionary+JSON.h"
#import "DocumentListTableViewCell.h"
#import "CreateDocumentViewController.h"
#import "User.h"
#import "UserInfoModel.h"
#import "OptionsViewController.h"
#import "UIViewController+ProgressHud.h"

#define kGetDocument @"Get Document"
#define kGetUsers @"Get Users"
#define kGetUsersDocuments @"Get User's Documents"
#define kSendRequest @"Send Request"
#define kGetMoreDocuments @"Get More Documents"
#define kDeleteDocument @"Delete Document"
#define kSearchDocuments @"Search Documents"

#define kDeleteDocumentTag 999
#define kSendRequestTag 998

@implementation DocumentsViewController {
    DownloadManager *_downloadManager;
    NSString *_permissionType;
    NSDictionary *_docDetails;
    NSInteger _pageNumber;
    NSDictionary *_deletedDocument;
    NSIndexPath *_deletedIndexPath;
    NSMutableArray *_tempDocuments;
    BOOL _isSearched;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    _tempDocuments = [NSMutableArray arrayWithArray:_documents];
    _pageNumber = 2;
    self.navigationItem.title = @"Documents";
//    _documentsTableView.editing = YES;
    [_documentsTableView setEditing:YES animated:YES];
    _documentsTableView.allowsSelectionDuringEditing = YES;
    self.navigationController.navigationBarHidden = NO;
    UIImage *image = [UIImage imageNamed:@"options-button"];
    CGRect frame = CGRectMake(0, 0, 61, 31);
    UIButton *optionsButton = [[UIButton alloc] initWithFrame:frame];
    [optionsButton setBackgroundImage:image forState:UIControlStateNormal];
    [optionsButton addTarget:self action:@selector(optionsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:optionsButton];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    UIImage *newImage = [UIImage imageNamed:@"new-button"];
    UIButton *newButton = [[UIButton alloc] initWithFrame:frame];
    [newButton setBackgroundImage:newImage forState:UIControlStateNormal];
    [newButton addTarget:self action:@selector(newButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:newButton];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    self.navigationItem.hidesBackButton = YES;
}

- (void)optionsButtonTapped:(id)sender {
    if (!_downloadManager) {
        _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
    }
    _downloadManager.callType = kGetUsersDocuments;
    User *currentUser = [UserInfoModel retrieveCurrentUser];
    NSString *path = [NSString stringWithFormat:@"Licenta/getDocumentForUser.php?userId=%@&page=1",currentUser.userID];
    [self showHudWithText:@""];
    [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
}

- (void)newButtonTapped:(id)sender {
    if (!_downloadManager) {
        _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
    }
    _downloadManager.callType = kGetUsers;
    User *currentUser = [UserInfoModel retrieveCurrentUser];
    NSString *path = [NSString stringWithFormat:@"Licenta/getUsers.php?userId=%@&page=1",currentUser.userID];
    [self showHudWithText:@""];
    [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _documents.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DocumentListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"documentListCustomCell"];
    if (!cell) {
        cell = [[DocumentListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"documentListCustomCell"];
    }
    NSDictionary *docDetails = _documents[indexPath.row];
    [cell updateCell:docDetails];
    if (indexPath.row == _documents.count - 3 && !_isSearched) {
        if (!_downloadManager) {
            _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
        }
        _downloadManager.callType = kGetMoreDocuments;
        User *currentUser = [UserInfoModel retrieveCurrentUser];
        NSString *path = [NSString stringWithFormat:@"Licenta/getAllDocuments.php?userId=%@&page=%ld",currentUser.userID, _pageNumber++];
        [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _docDetails = _documents[indexPath.row];
    if ([_docDetails[@"permissionType"] isEqualToString:@"None"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You do not have permission to see this document. Send request?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        alertView.tag = kSendRequestTag;
        [alertView show];
    } else {
        if (!_downloadManager) {
            _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
        }
        NSString *path = [NSString stringWithFormat:@"Licenta/getDocument.php?documentName=%@",_docDetails[@"documentName"]];
        _downloadManager.callType = kGetDocument;
        [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
        [self showHudWithText:@""];
        _permissionType = _docDetails[@"permissionType"];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _deletedIndexPath = indexPath;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to delete the document?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        alert.tag = kDeleteDocumentTag;
        [alert show];
    }
}

- (void)downloadManager:(DownloadManager *)downloadManager didDownloadSuccessfullyWithInfo:(id)responseInfo {
    [self removeHud];
    if ([responseInfo isKindOfClass:[NSData class]]){
        responseInfo = [[NSString alloc] initWithData:responseInfo encoding:NSUTF8StringEncoding];
    }
    NSDictionary *responseDict = [NSDictionary createJSONDictionaryFromNSString:responseInfo];
    if ([downloadManager.callType isEqualToString:kGetDocument]) {
        DocumentViewController *documentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"documentViewControllerID"];
        NSDictionary *docDetails = [[responseDict objectForKey:@"documents"] firstObject];
        documentViewController.documentDetails = docDetails;
        BOOL canEdit = NO;
        if ([_permissionType isEqualToString:@"Read"]) {
            canEdit = NO;
        } else if ([_permissionType isEqualToString:@"Write"]) {
            canEdit = YES;
        }
        documentViewController.canEdit = canEdit;
        documentViewController.parent = self;
        [self.navigationController pushViewController:documentViewController animated:YES];
    } else if ([downloadManager.callType isEqualToString:kGetUsers]) {
        NSArray *users = responseDict[@"users"];
        CreateDocumentViewController *createDocument = [self.storyboard instantiateViewControllerWithIdentifier:@"createDocumentViewControllerID"];
        createDocument.allUsers = [NSMutableArray arrayWithArray:users];
        createDocument.parentController = self;
        [self presentViewController:createDocument animated:YES completion:nil];

    } else if ([downloadManager.callType isEqualToString:kGetUsersDocuments]) {
        OptionsViewController *options = [self.storyboard instantiateViewControllerWithIdentifier:@"optionsViewControllerID"];
        if (responseDict) {
            options.documents = responseDict[@"documents"];
        } else {
            options.documents = nil;
        }
        [self.navigationController pushViewController:options animated:YES];
    } else if ([downloadManager.callType isEqualToString:kSendRequest]) {
        if ([[responseDict objectForKey:@"status"] isEqualToString:@"OK"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OK" message:@"Request sent" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Request already sent" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    } else if ([downloadManager.callType isEqualToString:kGetMoreDocuments]) {
        if (responseDict) {
            _isSearched = NO;
            for (NSDictionary *doc in responseDict[@"documents"]) {
                [_documents addObject:doc];
            }
            [_documentsTableView reloadData];
        }
    } else if ([downloadManager.callType isEqualToString:kDeleteDocument]) {
        if ([[responseDict objectForKey:@"status"] isEqualToString:@"OK"]) {
            [_documentsTableView beginUpdates];
            [_documents removeObject:_deletedDocument];
            [_documentsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_deletedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [_documentsTableView endUpdates];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You don't have permission to delete this document" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    } else if ([downloadManager.callType isEqualToString:kSearchDocuments]) {
        if ([responseDict objectForKey:@"documents"]) {
            _isSearched = YES;
            _documents = [NSMutableArray arrayWithArray:responseDict[@"documents"]];
            _pageNumber = 2;
            [_documentsTableView reloadData];
            [self.view endEditing:YES];
        }
    }
}
//
- (void)updateDocumentListWithNewDocument:(NSMutableDictionary *)document {
    [document setObject:@"Write" forKey:@"permissionType"];
    User *currentUser = [UserInfoModel retrieveCurrentUser];
    [document setObject:currentUser.username forKey:@"username"];
    if (!_documents) {
        _documents = [[NSMutableArray alloc] init];
    }
    [_documents addObject:document];
    [_documentsTableView reloadData];
    
}

- (void)downloadManager:(DownloadManager *)downloadManager didDownloadWithError:(NSError *)error {
    [self removeHud];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        if (alertView.tag == kDeleteDocumentTag) {
            if (!_downloadManager) {
                _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
            }
            _downloadManager.callType = kDeleteDocument;
            User *currentUser = [UserInfoModel retrieveCurrentUser];
            _deletedDocument = _documents[_deletedIndexPath.row];
            NSString *path = [NSString stringWithFormat:@"Licenta/deleteDocument.php?userId=%@&documentId=%@",currentUser.userID,_deletedDocument[@"documentId"]];
            [self showHudWithText:@""];
            [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
        } else if (alertView.tag == kSendRequestTag) {
            if (!_downloadManager) {
                _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
            }
            _downloadManager.callType = kSendRequest;
            User *currentUser = [UserInfoModel retrieveCurrentUser];
            NSString *path = [NSString stringWithFormat:@"Licenta/sendRequest.php?createdBy=%@&userId=%@&documentId=%@",_docDetails[@"createdBy"],currentUser.userID,_docDetails[@"documentId"]];
            [self showHudWithText:@""];
            [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (!_downloadManager) {
        _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
    }
    _downloadManager.callType = kSearchDocuments;
    User *currentUser = [UserInfoModel retrieveCurrentUser];
    [self showHudWithText:@""];
    NSString *path = [NSString stringWithFormat:@"Licenta/getDocumentsByName.php?userId=%@&docName=%@",currentUser.userID,searchBar.text];
    [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (![searchText length]) {
        _documents = [NSMutableArray arrayWithArray:_tempDocuments];
        [_documentsTableView reloadData];
        _pageNumber = 2;
        _isSearched = NO;
        [searchBar performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0.1];
    }
}




@end
