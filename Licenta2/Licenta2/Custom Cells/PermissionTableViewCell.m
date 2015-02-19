//
//  PermissionTableViewCell.m
//  Licenta
//
//  Created by Sebastian Feier on 1/13/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import "PermissionTableViewCell.h"

@implementation PermissionTableViewCell {
    BOOL _isReadButtonTapped;
    BOOL _isWriteButtonTapped;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)readButtonTapped:(id)sender {
    if (_isReadButtonTapped) {
        [_readButton setImage:[UIImage imageNamed:@"login-checkboxoff"] forState:UIControlStateNormal];
        [_user setValue:@(0) forKey:@"readOnly"];
    } else {
        [_readButton setImage:[UIImage imageNamed:@"login-checkboxon"] forState:UIControlStateNormal];
        [_user setValue:@(1) forKey:@"readOnly"];
    }
    _isReadButtonTapped = !_isReadButtonTapped;
    if (_delegate && [_delegate respondsToSelector:@selector(readWriteButtonTapped:forIndexPath:)]) {
        [_delegate readWriteButtonTapped:_user forIndexPath:_indexPath];
    }
}

- (IBAction)writeButtonTapped:(id)sender {
    if (_isWriteButtonTapped) {
        [_writeButton setImage:[UIImage imageNamed:@"login-checkboxoff"] forState:UIControlStateNormal];
        [_user setValue:@(0) forKey:@"readWrite"];
    } else {
        [_writeButton setImage:[UIImage imageNamed:@"login-checkboxon"] forState:UIControlStateNormal];
        [_user setValue:@(1) forKey:@"readWrite"];
    }
    _isWriteButtonTapped = !_isWriteButtonTapped;
    if (_delegate && [_delegate respondsToSelector:@selector(readWriteButtonTapped:forIndexPath:)]) {
        [_delegate readWriteButtonTapped:_user forIndexPath:_indexPath];
    }
}
@end
