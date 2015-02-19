//
//  ConflictViewController.h
//  Licenta
//
//  Created by Sebastian Feier on 1/6/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"
#import "DownloadManager.h"
@interface ConflictViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,DocumentViewControllerDelegate,DownloadManagerDelegate>

@property (nonatomic, strong) NSMutableArray *conflictedSections;
@property (nonatomic, strong) NSString *docTimeStamp;
@property (nonatomic, strong) NSString *docName;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) id parent;

@end
