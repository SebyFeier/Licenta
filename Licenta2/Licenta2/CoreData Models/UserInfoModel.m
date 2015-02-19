//
//  UserInfoModel.m
//  Licenta
//
//  Created by Sebastian Feier on 1/14/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import "UserInfoModel.h"

@implementation UserInfoModel

+ (BOOL)saveUserWithUsername:(NSString *)username andUserId:(NSString *)userID {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
    User *currentUser = nil;
    currentUser = [self retrieveCurrentUser];
    if (!currentUser) {
        currentUser = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
    }
    if (currentUser) {
        currentUser.username = username;
        currentUser.userID = userID;
    }
    
    // intialise The Layers
    // if the map already has layers configured, then we don't need to set the Bing Sattelite map as default
    [UserInfoModel saveChangesInCoreData];
    
    
    return YES;
}

+ (User *)retrieveCurrentUser {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
    NSMutableArray *allUsers = [self returnAllUsersForManagedObjectContext:managedObjectContext];
    User *currentUser = nil;
    if (allUsers && [allUsers count]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *username = [userDefaults valueForKey:@"username"];
        for (currentUser in allUsers) {
            if ([currentUser.username isEqualToString:username]) {
                return currentUser;
            }
        }
    }
    return nil;
}

+ (void)saveChangesInCoreData {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
}

+ (NSMutableArray *)returnItemsOfType:(NSString *)type withSortField:(NSString *)sortField andCacheName:(NSString *)cacheName inManagedObjectContext:(NSManagedObjectContext *)objectContenxt {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!objectContenxt)
        objectContenxt = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:type];
    
    NSError *error = nil;
    NSInteger coredataCount = [objectContenxt countForFetchRequest:fetchRequest error:&error];
    if (coredataCount == NSNotFound || coredataCount == 0) {
        return nil;
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:sortField ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    NSFetchedResultsController *fetchRequestController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                             managedObjectContext:objectContenxt sectionNameKeyPath:sortField cacheName:cacheName];
    if (![fetchRequestController performFetch:&error]) {
        return nil;
    }
    return [NSMutableArray arrayWithArray:[fetchRequestController fetchedObjects]];
}

+ (NSMutableArray *)returnAllUsersForManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    return [self returnItemsOfType:@"User" withSortField:@"username" andCacheName:@"users" inManagedObjectContext:managedObjectContext];
}

@end
