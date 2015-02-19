//
//  UserOptionsTableViewCell.h
//  Licenta
//
//  Created by Sebastian Feier on 1/14/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UsersViewController.h"

@interface UserOptionsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *documentsLabel;

@property (weak, nonatomic) IBOutlet UIButton *readButton;
- (IBAction)readButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *writeButton;
- (IBAction)writeButtonTapped:(id)sender;
@property (nonatomic, strong) NSMutableDictionary *user;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id<UsersDelegate>delegate;

- (void)updateCell;
@end
