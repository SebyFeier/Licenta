//
//  DocumentsViewController.h
//  Licenta
//
//  Created by Sebastian Feier on 1/5/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadManager.h"



@interface DocumentsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,DownloadManagerDelegate, UIAlertViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray *documents;
@property (weak, nonatomic) IBOutlet UITableView *documentsTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

- (void)updateDocumentListWithNewDocument:(NSMutableDictionary *)document;

@end
