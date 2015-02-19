//
//  CreateDocumentViewController.h
//  Licenta
//
//  Created by Sebastian Feier on 1/13/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadManager.h"

@protocol CreateDocumentDelegate <NSObject>

- (void)readWriteButtonTapped:(NSDictionary *)user forIndexPath:(NSIndexPath *)indexPath;

@end

@interface CreateDocumentViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, CreateDocumentDelegate, DownloadManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *usersTableView;
@property (nonatomic,strong) NSMutableArray *allUsers;
@property (weak, nonatomic) IBOutlet UITextField *documentNameLabel;
- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)saveButtonTapped:(id)sender;

@property (nonatomic, strong) id parentController;

@end
