//
//  DownloadManager.m
//  Licenta
//
//  Created by Sebastian Feier on 1/5/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import "DownloadManager.h"
#import <AFHTTPClient.h>
#import "AFJSONRequestOperation.h"

@implementation DownloadManager {
    id<DownloadManagerDelegate>_delegate;
}

- (id)initWithDelegate:(id<DownloadManagerDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
}

- (void)downloadFromServer:(NSString *)server atPath:(NSString *)path withParameters:(NSDictionary *)parameters {
    NSURL *url = [NSURL URLWithString:server];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient setStringEncoding:NSUTF8StringEncoding];
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self downloadFinishedSuccessfully:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self downloadFinishedWithError:error];
    }];
    [operation start];
}

- (void)downloadFinishedSuccessfully:(id)response {
    if (_delegate && [_delegate respondsToSelector:@selector(downloadManager:didDownloadSuccessfullyWithInfo:)]) {
        [_delegate downloadManager:self didDownloadSuccessfullyWithInfo:response];
    }
}

- (void)downloadFinishedWithError:(NSError *)error {
    if (_delegate && [_delegate respondsToSelector:@selector(downloadManager:didDownloadWithError:)]) {
        [_delegate downloadManager:self didDownloadWithError:error];
    }
}


@end
