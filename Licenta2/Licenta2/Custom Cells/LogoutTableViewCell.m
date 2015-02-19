//
//  LogoutTableViewCell.m
//  Licenta
//
//  Created by Sebastian Feier on 1/14/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import "LogoutTableViewCell.h"
#import "OptionsViewController.h"

@implementation LogoutTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)logoutButtonTapped:(id)sender {
    [(OptionsViewController *)_parent logout];
}
@end
