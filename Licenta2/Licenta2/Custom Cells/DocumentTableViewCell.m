//
//  DocumentTableViewCell.m
//  Licenta
//
//  Created by Sebastian Feier on 1/5/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import "DocumentTableViewCell.h"

@implementation DocumentTableViewCell {
    BOOL _isSelected;
    BOOL _canEdit;
//    BOOL _canEdit;
}

- (void)awakeFromNib {
    // Initialization code
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

- (void)canEdit:(BOOL)canEdit {
//    _selectionButton.enabled = canEdit;
    _canEdit = canEdit;
}

- (IBAction)selectionButtonTapped:(id)sender {
    if (_canEdit) {
        _isSelected = !_isSelected;
        if (_isSelected) {
            _textView.editable = YES;
            _textView.scrollEnabled = YES;
            [_selectionButton setImage:[UIImage imageNamed:@"login-checkboxon"] forState:UIControlStateNormal];
        } else {
            _textView.editable = NO;
            _textView.scrollEnabled = NO;
            [_selectionButton setImage:[UIImage imageNamed:@"login-checkboxoff"] forState:UIControlStateNormal];
        }
        
    }
    if (_delegate && [_delegate respondsToSelector:@selector(selectionButtonTapped:canEdit:)]) {
        [_delegate selectionButtonTapped:_selectedIndexPath canEdit:_canEdit];
    }

    
}
@end
