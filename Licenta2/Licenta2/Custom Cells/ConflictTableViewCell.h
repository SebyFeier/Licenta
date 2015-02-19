//
//  ConflictTableViewCell.h
//  Licenta
//
//  Created by Sebastian Feier on 1/6/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"

@interface ConflictTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *selectionButton;
- (IBAction)selectionButtonTapped:(id)sender;
@property (nonatomic, weak)id<DocumentViewControllerDelegate>delegate;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@end
