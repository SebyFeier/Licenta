//
//  DeviceRequestTableViewCell.m
//  Licenta2
//
//  Created by Sebastian Feier on 1/21/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import "DeviceRequestTableViewCell.h"

@implementation DeviceRequestTableViewCell {
    BOOL _isEnabled;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)updateCell {
    [_enableButton setImage:[UIImage imageNamed:@"login-checkboxoff"] forState:UIControlStateNormal];
    _isEnabled = NO;
    _deviceNameLabel.text = [NSString stringWithFormat:@"%@",_deviceInfo[@"deviceName"]];
    [_deviceInfo setObject:@(0) forKey:@"isApproved"];
}

- (IBAction)enableButtonTapped:(id)sender {
    if (_isEnabled) {
        [_enableButton setImage:[UIImage imageNamed:@"login-checkboxoff"] forState:UIControlStateNormal];
        [_deviceInfo setValue:@(0) forKey:@"isApproved"];
    } else {
        [_enableButton setImage:[UIImage imageNamed:@"login-checkboxon"] forState:UIControlStateNormal];
        [_deviceInfo setValue:@(1) forKey:@"isApproved"];
    }
    _isEnabled = !_isEnabled;
    
    if (_delegate && [_delegate respondsToSelector:@selector(enabledButtonTapped:)]) {
        [_delegate enabledButtonTapped:_deviceInfo];
    }
}
@end
