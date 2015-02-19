//
//  RequestTableViewCell.m
//  Licenta
//
//  Created by Sebastian Feier on 1/15/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import "RequestTableViewCell.h"

@implementation RequestTableViewCell {
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

- (void)updateCell {
        [_readButton setImage:[UIImage imageNamed:@"login-checkboxoff"] forState:UIControlStateNormal];
        [_writeButton setImage:[UIImage imageNamed:@"login-checkboxoff"] forState:UIControlStateNormal];
        _isReadButtonTapped = NO;
        _isWriteButtonTapped = NO;
        [_details setObject:@(0) forKey:@"readOnly"];
        [_details setObject:@(0) forKey:@"readWrite"];
    _detailsLabel.text = [NSString stringWithFormat:@"%@ (%@)", _details[@"documentName"], _details[@"username"]];
}


- (IBAction)readButtonTapped:(id)sender {
    if (_isReadButtonTapped) {
        [_readButton setImage:[UIImage imageNamed:@"login-checkboxoff"] forState:UIControlStateNormal];
        [_details setValue:@(0) forKey:@"readOnly"];
    } else {
        [_readButton setImage:[UIImage imageNamed:@"login-checkboxon"] forState:UIControlStateNormal];
        [_details setValue:@(1) forKey:@"readOnly"];
    }
    _isReadButtonTapped = !_isReadButtonTapped;
    if (_delegate && [_delegate respondsToSelector:@selector(readWriteButtonTapped:forIndexPath:)]) {
        [_delegate readWriteButtonTapped:_details forIndexPath:_indexPath];
    }
}

- (IBAction)writeButtonTapped:(id)sender {
    if (_isWriteButtonTapped) {
        [_writeButton setImage:[UIImage imageNamed:@"login-checkboxoff"] forState:UIControlStateNormal];
        [_details setValue:@(0) forKey:@"readWrite"];
    } else {
        [_writeButton setImage:[UIImage imageNamed:@"login-checkboxon"] forState:UIControlStateNormal];
        [_details setValue:@(1) forKey:@"readWrite"];
    }
    _isWriteButtonTapped = !_isWriteButtonTapped;
    if (_delegate && [_delegate respondsToSelector:@selector(readWriteButtonTapped:forIndexPath:)]) {
        [_delegate readWriteButtonTapped:_details forIndexPath:_indexPath];
    }
}
@end
