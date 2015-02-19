//
//  RequestsViewController.h
//  Licenta
//
//  Created by Sebastian Feier on 1/15/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadManager.h"
#import "Constants.h"

@protocol RequestDelegate <NSObject>

- (void)readWriteButtonTapped:(NSDictionary *)details forIndexPath:(NSIndexPath *)indexPath;
- (void)enabledButtonTapped:(NSDictionary *)deviceInfo;

@end

@interface RequestsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, RequestDelegate, DownloadManagerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *requestsTableView;
@property (weak, nonatomic) IBOutlet UIButton *saveButtonTapped;
- (IBAction)notNowButtonTapped:(id)sender;
- (IBAction)saveButtonTapped:(id)sender;
@property (nonatomic, assign) REQUESTTYPE requestType;
@property (nonatomic, strong) NSMutableArray *allDetails;
@property (nonatomic, strong) id parent;

@end
