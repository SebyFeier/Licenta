//
//  DocumentListTableViewCell.h
//  Licenta
//
//  Created by Sebastian Feier on 1/13/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocumentListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *documentNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *readImageView;
@property (weak, nonatomic) IBOutlet UIImageView *writeImage;

- (void)updateCell:(NSDictionary *)docDetails;

@end
