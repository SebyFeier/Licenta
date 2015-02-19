//
//  UsersViewController.h
//  Licenta
//
//  Created by Sebastian Feier on 1/15/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadManager.h"
@protocol UsersDelegate <NSObject>

- (void)readWriteButtonTapped:(NSDictionary *)user forIndexPath:(NSIndexPath *)indexPath;

@end

@interface UsersViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UsersDelegate, DownloadManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *usersTableView;
@property (nonatomic, strong) NSMutableArray *allUsers;
@property (nonatomic, strong) NSString *documentID;
@end
