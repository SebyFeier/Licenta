//
//  DownloadManager.h
//  Licenta
//
//  Created by Sebastian Feier on 1/5/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DownloadManager;
@protocol DownloadManagerDelegate <NSObject>

- (void)downloadManager:(DownloadManager *)downloadManager didDownloadSuccessfullyWithInfo:(id)responseInfo;
- (void)downloadManager:(DownloadManager *)downloadManager didDownloadWithError:(NSError *)error;

@end

@interface DownloadManager : NSObject

@property (nonatomic, strong) NSString *callType;

- (id)initWithDelegate:(id<DownloadManagerDelegate>)delegate;
- (void)downloadFromServer:(NSString *)server atPath:(NSString *)path withParameters:(NSDictionary *)parameters;

@end


