//
//  PermissionTableViewCell.h
//  Licenta
//
//  Created by Sebastian Feier on 1/13/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateDocumentViewController.h"

@interface PermissionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
- (IBAction)readButtonTapped:(id)sender;
- (IBAction)writeButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *writeButton;
@property (weak, nonatomic) IBOutlet UIButton *readButton;
@property (nonatomic, assign) NSMutableDictionary *user;
@property (nonatomic, weak) id<CreateDocumentDelegate>delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;
@end
