//
//  DocumentTableViewCell.h
//  Licenta
//
//  Created by Sebastian Feier on 1/5/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"

@interface DocumentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *selectionButton;
- (IBAction)selectionButtonTapped:(id)sender;
@property (nonatomic, weak)id<DocumentViewControllerDelegate>delegate;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (weak, nonatomic) IBOutlet UIButton *typingImage;

- (void)canEdit:(BOOL)canEdit;

@end
