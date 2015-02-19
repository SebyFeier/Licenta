//
//  DocumentListTableViewCell.m
//  Licenta
//
//  Created by Sebastian Feier on 1/13/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import "DocumentListTableViewCell.h"

@implementation DocumentListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateCell:(NSDictionary *)docDetails {
    if ([docDetails[@"permissionType"] isEqualToString:@"Read"]) {
        [_readImageView setImage:[UIImage imageNamed:@"login-checkboxon"]];
        [_writeImage setImage:[UIImage imageNamed:@"login-checkboxoff"]];
    } else if ([docDetails[@"permissionType"] isEqualToString:@"Write"]) {
        [_readImageView setImage:[UIImage imageNamed:@"login-checkboxon"]];
        [_writeImage setImage:[UIImage imageNamed:@"login-checkboxon"]];
    } else if ([docDetails[@"permissionType"] isEqualToString:@"None"]) {
        [_readImageView setImage:[UIImage imageNamed:@"login-checkboxoff"]];
        [_writeImage setImage:[UIImage imageNamed:@"login-checkboxoff"]];
    }
    _documentNameLabel.text = docDetails[@"documentName"];
}

@end
