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
//    _lastConflict = [_conflictedSections lastObject];
//    [_lastConflict setObject:@(3) forKey:@"isSelected"];
    if (_conflictedSections && [_conflictedSections count] == 2) {
        _existingSection = [_conflictedSections firstObject][@"sections"][@"section"];
        _newSection = [_conflictedSections lastObject][@"sections"][@"section"];
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
    
    
    
//    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonTapped:)];

    UIImage *image = [UIImage imageNamed:@"save-button"];
    CGRect frame = CGRectMake(0, 0, 61, 31);
    UIButton *saveButton = [[UIButton alloc] initWithFrame:frame];
    [saveButton setBackgroundImage:image forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    //    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain
    //target:self action:@selector(optionsButtonTapped:)];
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
//    if ([[_lastConflict objectForKey:@"isSelected"] integerValue] == 3) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select a field" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alertView show];
//    } else {
//        if (!_downloadManager) {
//            _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
//        }
//        NSString *selectedField = [[_lastConflict objectForKey:@"sectionContent"] objectAtIndex:[[_lastConflict objectForKey:@"isSelected"] integerValue]];
//        NSString *path = [NSString stringWithFormat:@"resolveConflict.php?documentName=%@&timeStamp=%@&%@=%@",_docName,_docTimeStamp,[_lastConflict objectForKey:@"sectionName"],selectedField];
//        [self showHudWithText:@""];
//        [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
//    }
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
//    [_conflictedSections removeLastObject];
//    _lastConflict = [_conflictedSections lastObject];
//    if (_lastConflict) {
//        [_lastConflict setObject:@(3) forKey:@"isSelected"];
//        [_tableView reloadData];
//    } else {
////        [self.navigationController popToRootViewControllerAnimated:YES];
//        [self.navigationController popToViewController:(UIViewController *)_parent animated:YES];
//    }
    if ([_newSection isKindOfClass:[NSDictionary class]] && [_newSection isKindOfClass:[NSDictionary class]]) {
        _lastNewConflict = nil;
        _lastExistingConflict = nil;
    } else if ([_existingSection isKindOfClass:[NSArray class]] && [_newSection isKindOfClass:[NSArray class]]) {
        _lastExistingConflict = [_existingSection lastObject];
        _lastNewConflict = [_newSection lastObject];
    }
    if (_lastExistingConflict && _lastNewConflict) {
        [_lastExistingConflict setObject:@(3) forKey:@"isSelected"];
        [_lastNewConflict setObject:@(3) forKey:@"isSelected"];
        [_tableView reloadData];
    } else {
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
//    NSArray *sectionContent = [_lastConflict objectForKey:@"sectionContent"];
//    cell.textView.text = [sectionContent objectAtIndex:indexPath.row];
    cell.textView.tag = indexPath.row;
    cell.selectedIndexPath = indexPath;
//    if ([[_lastConflict objectForKey:@"isSelected"] intValue] == indexPath.row) {
//        [cell.selectionButton setImage:[UIImage imageNamed:@"login-checkboxon"] forState:UIControlStateNormal];
//    } else {
//        [cell.selectionButton setImage:[UIImage imageNamed:@"login-checkboxoff"] forState:UIControlStateNormal];
//    }
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
