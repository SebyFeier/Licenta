//
//  DocumentViewController.h
//  Licenta
//
//  Created by Sebastian Feier on 1/5/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadManager.h"
#import "Protocols.h"

@interface DocumentViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, DownloadManagerDelegate,UITextViewDelegate,DocumentViewControllerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSDictionary *documentDetails;
@property (nonatomic, assign) BOOL canEdit;
@property (nonatomic, strong) id parent;

@end
