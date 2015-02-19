//
//  RequestTableViewCell.h
//  Licenta
//
//  Created by Sebastian Feier on 1/15/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestsViewController.h"

@interface RequestTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet UIButton *readButton;
- (IBAction)readButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *writeButton;
- (IBAction)writeButtonTapped:(id)sender;
@property (nonatomic, strong) NSMutableDictionary *details;
@property (nonatomic, weak) id<RequestDelegate>delegate;
- (void)updateCell;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end
