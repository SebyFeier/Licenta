//
//  OptionsViewController.h
//  Licenta
//
//  Created by Sebastian Feier on 1/14/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadManager.h"

@interface OptionsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,DownloadManagerDelegate> {
}

@property (weak, nonatomic) IBOutlet UITableView *optionsTableView;

@property (nonatomic, strong) NSMutableArray *documents;

- (void)logout;

@end
