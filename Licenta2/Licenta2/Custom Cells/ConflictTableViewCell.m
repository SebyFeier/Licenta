//
//  ConflictTableViewCell.m
//  Licenta
//
//  Created by Sebastian Feier on 1/6/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import "ConflictTableViewCell.h"

@implementation ConflictTableViewCell {
    BOOL _isSelected;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)selectionButtonTapped:(id)sender {
//    _isSelected = !_isSelected;
//    if (_isSelected) {
//        _textView.editable = YES;
//        _selectionButton.backgroundColor = [UIColor greenColor];
//    } else {
//        _textView.editable = NO;
//        _selectionButton.backgroundColor = [UIColor blueColor];
//    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(selectionButtonTapped:canEdit:)]) {
        [_delegate selectionButtonTapped:_selectedIndexPath canEdit:YES];
    }
    
}

@end
