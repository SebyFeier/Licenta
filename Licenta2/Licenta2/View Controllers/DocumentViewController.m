//
//  DocumentViewController.m
//  Licenta
//
//  Created by Sebastian Feier on 1/5/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import "DocumentViewController.h"
#import "DocumentTableViewCell.h"
#import "Constants.h"
#import "NSDictionary+JSON.h"
#import "ConflictViewController.h"
#import "UIViewController+ProgressHud.h"
#import "User.h"
#import "UserInfoModel.h"

#define kSendRequest @"Send Request"
#define kUpdateDocument @"Update Document"

@interface DocumentViewController ()

@end

@implementation DocumentViewController {
    DownloadManager *_downloadManager;
    NSMutableArray *_docDetails;
    NSString *_docName;
    NSString *_docTimeStamp;
    NSString *_documentId;
    NSString *_createdBy;
    UIView *_messageView;
    UILabel *_messageLabel;
    BOOL _showTable;
    NSTimer *_timer;
    BOOL _isTyping;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (_canEdit) {
        UIImage *image = [UIImage imageNamed:@"save-button"];
        CGRect frame = CGRectMake(0, 0, 61, 31);
        UIButton *saveButton = [[UIButton alloc] initWithFrame:frame];
        [saveButton setBackgroundImage:image forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(saveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
        self.navigationItem.rightBarButtonItem = barButtonItem;
    }
    
    UIImage *image = [UIImage imageNamed:@"back-button"];
    CGRect frame = CGRectMake(0, 0, 61, 31);
    UIButton *backButton = [[UIButton alloc] initWithFrame:frame];
    [backButton setBackgroundImage:image forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = barButtonItem;
    _showTable = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    if (!_messageView) {
        _messageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), CGRectGetHeight(_tableView.frame))];
        _messageView.backgroundColor = [UIColor lightGrayColor];
        _messageView.alpha = 0.5f;
        [_tableView addSubview:_messageView];
    }
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
        _messageLabel.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2 - 50);
        _messageLabel.text = @"Please select a section to edit the document";
        _messageLabel.numberOfLines = 2;
        [_messageView addSubview:_messageLabel];
    }

    // Do any additional setup after loading the view.
}



- (void)removeLabel {
    _docDetails = [[NSMutableArray alloc] init];
    _isTyping = YES;
    for (NSString *key in [_documentDetails allKeys]) {
        if ([key isEqualToString:@"documentName"]) {
            _docName = [_documentDetails objectForKey:key];
        } else if ([key isEqualToString:@"lastModified"]) {
            _docTimeStamp = [_documentDetails objectForKey:key];
        }  else if ([key isEqualToString:@"createdBy"]) {
            _createdBy = _documentDetails[@"createdBy"];
        } else if ([key isEqualToString:@"documentId"]) {
            _documentId = _documentDetails[@"documentId"];
        } else if ([key rangeOfString:@"_modif"].location == NSNotFound) {
            NSString *sectionName = key;
            NSString *sectionText = [_documentDetails objectForKey:key];
            if ([sectionText length]) {
                NSMutableDictionary *section = [NSMutableDictionary dictionaryWithObjectsAndKeys:sectionName,@"sectionName",sectionText,@"sectionText",@(0),@"isModified", nil];
                [_docDetails addObject:section];
            }
        }
    }
    self.navigationItem.title = _docName;
    [self startTimer];
    _showTable = YES;
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sectionName" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sort];
    _docDetails = [NSMutableArray arrayWithArray:[_docDetails sortedArrayUsingDescriptors:sortDescriptors]];
    [_messageView removeFromSuperview];
    [_messageLabel removeFromSuperview];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [_tableView reloadData];
}

- (void)startTimer {
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timerUpdateFired) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)stopTimer {
    [_timer invalidate];
}

- (void)timerUpdateFired {
    _isTyping = !_isTyping;
    [_tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopTimer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self performSelector:@selector(removeLabel) withObject:nil afterDelay:1.0f];
}

- (void)saveButtonTapped:(id)sender {
    [self.view endEditing:YES];
    NSLog(@"%@",_docDetails);
    if (!_downloadManager) {
        _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
    }
    NSString *updatedSections = @"";
    for (NSDictionary *section in _docDetails) {
        if ([[section objectForKey:@"isModified"] boolValue]) {
            updatedSections = [updatedSections stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",[section objectForKey:@"sectionName"],[section objectForKey:@"sectionText"]]];
        }
    }
    
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *stringInterval = [NSString stringWithFormat:@"%f",timeStamp];
    NSString *lastTimeStamp = [[stringInterval componentsSeparatedByString:@"."] firstObject];
    NSString *path = [NSString stringWithFormat:@"updateDocument.php?documentName=%@%@&timeStamp=%@&initialTimeStamp=%@",_docName,updatedSections,lastTimeStamp,_docTimeStamp];
    [self showHudWithText:@""];
    _downloadManager.callType = kUpdateDocument;
    [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
}

- (void)backButtonTapped:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)textViewDidChange:(UITextView *)textView {
    [_tableView beginUpdates]; // This will cause an animated update of
    CGFloat maxHeight = 312.0f;
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), fminf(newSize.height, maxHeight));
    textView.frame = newFrame;
    [_tableView endUpdates];   // the height of your UITableViewCell

    // If the UITextView is not automatically resized (e.g. through autolayout
    // constraints), resize it here
    
    [self scrollToCursorForTextView:textView]; // OPTIONAL: Follow cursor
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        return NO;
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSMutableDictionary *section = [_docDetails objectAtIndex:textView.tag];
    [section setObject:textView.text forKey:@"sectionText"];
    [_docDetails replaceObjectAtIndex:textView.tag withObject:section];
}

- (BOOL)rectVisible: (CGRect)rect {
    CGRect visibleRect;
    visibleRect.origin = _tableView.contentOffset;
    visibleRect.origin.y += _tableView.contentInset.top;
    visibleRect.size = _tableView.bounds.size;
    visibleRect.size.height -= _tableView.contentInset.top + _tableView.contentInset.bottom;
    
    return CGRectContainsRect(visibleRect, rect);
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self scrollToCursorForTextView:textView];
}

- (void)scrollToCursorForTextView: (UITextView*)textView {
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    cursorRect = [_tableView convertRect:cursorRect fromView:textView];
    if (![self rectVisible:cursorRect]) {
        cursorRect.size.height += 8; // To add some space underneath the cursor
        [_tableView scrollRectToVisible:cursorRect animated:YES];
    }
}

- (CGFloat)textViewHeightForAttributedText:(NSAttributedString*)text andWidth:(CGFloat)width {
    UITextView *calculationView = [[UITextView alloc] init];
    [calculationView setAttributedText:text];
    CGSize size = [calculationView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != _docDetails.count) {
        NSDictionary *sectionDict = [ _docDetails objectAtIndex:indexPath.row];
        NSAttributedString *text = [[NSAttributedString alloc] initWithString:[sectionDict objectForKey:@"sectionText"]];
        CGFloat height = [self textViewHeightForAttributedText:text andWidth:170];
        return (height > 30?height + 50:44);
    }
    return 44;
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_showTable) {
        return (_docDetails.count?_docDetails.count + (_canEdit?1:0):1);
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (row != _docDetails.count) {
        DocumentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"documentCustomCell"];
        if (!cell) {
            cell = [[DocumentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"documentCustomCell"];
        }
        
        [cell canEdit:_canEdit];
        
        cell.delegate = self;
        cell.selectedIndexPath = indexPath;
        cell.textView.tag = indexPath.row;
        NSDictionary *sectionDict = [ _docDetails objectAtIndex:indexPath.row];
        cell.textView.text = [sectionDict objectForKey:@"sectionText"];
        cell.textView.delegate = self;
        if (!_isTyping) {
            cell.typingImage.hidden = YES;
        } else {
            cell.typingImage.hidden = NO;
        }
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"documentTableViewCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"documentTableViewCell"];
        }
        cell.textLabel.text = @"Create new section";
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == _docDetails.count) {
        [_docDetails addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"section%lu",_docDetails.count + 1],@"sectionName",@"",@"sectionText",@(1), @"isModified", nil]];
        [_tableView reloadData];
    }
}

- (void)selectionButtonTapped:(NSIndexPath *)indexPath canEdit:(BOOL)canEdit {
    if (canEdit) {
        NSMutableDictionary *section = [_docDetails objectAtIndex:indexPath.row];
        [section setObject:@(1) forKey:@"isModified"];
        [_docDetails replaceObjectAtIndex:indexPath.row withObject:section];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You do not have permission to edit this document. Send request?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alertView show];

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
    if ([downloadManager.callType isEqualToString:kUpdateDocument]) {
        NSMutableArray *conflictedSections = [[NSMutableArray alloc] init];
        if ([[responseDict objectForKey:@"status"] isEqualToString:@"OK"]) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        } else {
            for (NSString *key in [responseDict allKeys]) {
                NSMutableDictionary *section = [NSMutableDictionary dictionaryWithObjectsAndKeys:key, @"sectionName",[responseDict objectForKey:key],@"sectionContent", nil];
                [conflictedSections addObject:section];
            }
        }
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sectionName" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sort];
        conflictedSections = [NSMutableArray arrayWithArray:[conflictedSections sortedArrayUsingDescriptors:sortDescriptors]];
        ConflictViewController *conflictViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"conflictViewControllerID"];
        conflictViewController.conflictedSections = conflictedSections;
        conflictViewController.docTimeStamp = _docTimeStamp;
        conflictViewController.docName = _docName;
        conflictViewController.parent = _parent;
        [self.navigationController pushViewController:conflictViewController animated:YES];
    } else if ([downloadManager.callType isEqualToString:kSendRequest]) {
        if ([[responseDict objectForKey:@"status"] isEqualToString:@"OK"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OK" message:@"Request sent" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Request already sent" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        if (!_downloadManager) {
            _downloadManager = [[DownloadManager alloc] initWithDelegate:self];
        }
        _downloadManager.callType = kSendRequest;
        User *currentUser = [UserInfoModel retrieveCurrentUser];
        NSString *path = [NSString stringWithFormat:@"sendRequest.php?createdBy=%@&userId=%@&documentId=%@",_createdBy,currentUser.userID,_documentId];
        [self showHudWithText:@""];
        [_downloadManager downloadFromServer:kServerUrl atPath:path withParameters:nil];
    }
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, kbSize.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.35];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, 0.0, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    [UIView commitAnimations];
}

@end
