//
//  DeviceRequestTableViewCell.h
//  Licenta2
//
//  Created by Sebastian Feier on 1/21/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestsViewController.h"

@interface DeviceRequestTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *enableButton;
- (IBAction)enableButtonTapped:(id)sender;
@property (nonatomic, weak) id <RequestDelegate>delegate;

@property (nonatomic, strong) NSMutableDictionary *deviceInfo;

- (void)updateCell;
@end
