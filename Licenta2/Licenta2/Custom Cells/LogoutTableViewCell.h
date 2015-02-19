//
//  LogoutTableViewCell.h
//  Licenta
//
//  Created by Sebastian Feier on 1/14/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogoutTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (nonatomic, strong) id parent;
- (IBAction)logoutButtonTapped:(id)sender;

@end
