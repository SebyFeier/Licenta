//
//  ConflictViewController.m
//  Licenta
//
//  Created by Sebastian Feier on 1/6/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import "ConflictViewController.h"
#import "Constants.h"
#import "ConflictTableViewCell.h"
#import "NSDictionary+JSON.h"
#import "UIViewController+ProgressHud.h"
#import "NSString+JSON.h"

#define kResolveConflict @"Resolve Conflict"
#define kAddNotifications @"Add Notifications"

@interface ConflictViewController ()

@end

@implementation ConflictViewController {
    NSMutableDictionary *_lastExistingConflict;//section on server
    NSMutableDictionary *_lastNewConflict;//updated section
    DownloadManager *_downloadManager;
    id _existingSection;
    id _newSection;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_conflictedSections && [_conflictedSections count] == 2) {
        _existingSection = [[NSMutableArray alloc] init];
        id section1 = [_conflictedSections firstObject][@"sections"][@"section"];
        if ([section1 isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in section1) {
                for (NSString *sectionName in _modifiedSections) {
                    if ([dict[@"name"][@"text"] integerValue] == [sectionName integerValue]) {
                        [_existingSection addObject:dict];
                    }
                }
            }
            [_existingSection sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
                if ([obj1[@"name"][@"text"] integerValue] > [obj2[@"name"][@"text"] integerValue]) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                if ([obj1[@"name"][@"text"] integerValue] < [obj2[@"name"][@"text"] integerValue]) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
        } else if ([section1 isKindOfClass:[NSDictionary class]]) {
            for (NSString *sectionName in _modifiedSections) {
                if ([section1[@"name"][@"text"] integerValue] == [sectionName integerValue]) {
                    [_existingSection addObject:section1];
                }
            }
        }
        _newSection = [[NSMutableArray alloc] init];
        id section2 = [_conflictedSections lastObject][@"sections"][@"section"];
        if ([section2 isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in section2) {
                for (NSString *sectionName in _modifiedSections) {
                    if ([dict[@"name"][@"text"] integerValue] == [sectionName integerValue]) {
                        [_newSection addObject:dict];
                    }
                }
            }
            [_newSection sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
                if ([obj1[@"name"][@"text"] integerValue] > [obj2[@"name"][@"text"] integerValue]) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                if ([obj1[@"name"][@"text"] integerValue] < [obj2[@"name"][@"text"] integerValue]) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
        } else if ([section2 isKindOfClass:[NSDictionary class]]) {
            for (NSString *sectionName in _modifiedSections) {
                if ([section2[@"name"][@"text"] integerValue] == [sectionName integerValue]) {
                    [_newSection addObject:section2];
                }
            }
        }
    }
    
    if ([_existingSection isKindOfClass:[NSDictionary class]] && [_newSection isKindOfClass:[NSDictionary class]]) {
        _lastExistingConflict = _existingSection;
        [_lastExistingConflict setObject:@(3) forKey:@"isSelected"];
        _lastNewConflict = _newSection;
        [_lastNewConflict setObject:@(3) forKey:@"isSelected"];
    } else if ([_existingSection isKindOfClass:[NSArray class]] && [_newSection isKindOfClass:[NSArray class]]) {
        _lastExistingConflict = [_existingSection lastObject];
        [_lastExistingConflict setObject:@(3) forKey:@"isSelected"];
        _lastNewConflict = [_newSection lastObject];
        [_lastNewConflict setObject:@(3) forKey:@"isSelected"];
    }

    UIImage *image = [UIImage imageNamed:@"save-button"];
    CGRect frame = CGRectMake(0, 0, 61, 31);
    UIButton *saveButton = [[UIButton alloc] initWithFrame:frame];
    [saveButton setBackgroundImage:image forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    self.navigationItem.rightBarButtonItem = barButtonItem;
//    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.navigationItem.hidesBackButton = YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveButtonTapped:(id)sender {
    if ([[_lastExistingConflict objectForKey:@"isSelected"] integerValue] == 3 && [[_lastNewConflict objectForKey:@"isSelected"] integerValue] == 3) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select a field" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else {
        if (!_downloadManager) {
            _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
        }
        NSDictionary *selectedSection = nil;
        if ([_lastExistingConflict[@"isSelected"] integerValue] != 3) {
            selectedSection = _lastExistingConflict;
        } else if ([_lastNewConflict[@"isSelected"] integerValue] != 3) {
            selectedSection = _lastNewConflict;
        }
        NSString *json = [NSString createJSONFromObject:selectedSection];
        NSString *path = [NSString stringWithFormat:@"resolveConflict.php?documentName=%@&timeStamp=%@&section=%@",_docName,_docTimeStamp,json];
        _downloadManager.callType = kResolveConflict;
        [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
    }
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
    if ([downloadManager.callType isEqualToString:kResolveConflict]) {
        if ([_newSection isKindOfClass:[NSDictionary class]] && [_newSection isKindOfClass:[NSDictionary class]]) {
            _lastNewConflict = nil;
            _lastExistingConflict = nil;
        } else if ([_existingSection isKindOfClass:[NSArray class]] && [_newSection isKindOfClass:[NSArray class]]) {
            [_existingSection removeLastObject];
            [_newSection removeLastObject];
            _lastExistingConflict = [_existingSection lastObject];
            _lastNewConflict = [_newSection lastObject];
        }
        if (_lastExistingConflict && _lastNewConflict) {
            [_lastExistingConflict setObject:@(3) forKey:@"isSelected"];
            [_lastNewConflict setObject:@(3) forKey:@"isSelected"];
            [_tableView reloadData];
        } else {
            if (!_downloadManager) {
                _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
            }
            NSString *path = [NSString stringWithFormat:@"addNotifications.php?documentName=%@&username=%@",_docName, [[NSUserDefaults standardUserDefaults] valueForKey:@"username"]];
            _downloadManager.callType = kAddNotifications;
            [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
        }
    } else if ([downloadManager.callType isEqualToString:kAddNotifications]) {
        [self.navigationController popToViewController:(UIViewController *)_parent animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ConflictTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"conflictCustomCell"];
    if (!cell) {
        cell = [[ConflictTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"conflictCustomCell"];
    }
    cell.delegate = self;
    if (indexPath.row == 0) {
        cell.textView.text = _lastExistingConflict[@"value"][@"text"];
        if ([_lastExistingConflict[@"isSelected"] integerValue] == indexPath.row) {
            [cell.selectionButton setImage:[UIImage imageNamed:@"login-checkboxon"] forState:UIControlStateNormal];
        } else {
            [cell.selectionButton setImage:[UIImage imageNamed:@"login-checkboxoff"] forState:UIControlStateNormal];
        }
    } else if (indexPath.row == 1) {
        cell.textView.text = _lastNewConflict[@"value"][@"text"];
        if ([_lastNewConflict[@"isSelected"] integerValue] == indexPath.row) {
            [cell.selectionButton setImage:[UIImage imageNamed:@"login-checkboxon"] forState:UIControlStateNormal];
        } else {
            [cell.selectionButton setImage:[UIImage imageNamed:@"login-checkboxoff"] forState:UIControlStateNormal];
        }
    }
    cell.textView.tag = indexPath.row;
    cell.selectedIndexPath = indexPath;
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)selectionButtonTapped:(NSIndexPath *)indexPath canEdit:(BOOL)canEdit{
    //    [_lastConflict setObject:@(indexPath.row) forKey:@"isSelected"];
    if (indexPath.row == 0) {
        [_lastExistingConflict setObject:@(indexPath.row) forKey:@"isSelected"];
        [_lastNewConflict setObject:@(3) forKey:@"isSelected"];
    } else if (indexPath.row == 1) {
        [_lastNewConflict setObject:@(indexPath.row) forKey:@"isSelected"];
        [_lastExistingConflict setObject:@(3) forKey:@"isSelected"];
    }
    [_tableView reloadData];
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
