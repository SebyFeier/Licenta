//
//  UserInfoModel.h
//  Licenta
//
//  Created by Sebastian Feier on 1/14/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "AppDelegate.h"

@interface UserInfoModel : NSObject

+ (BOOL)saveUserWithUsername:(NSString *)username andUserId:(NSString *)userID;
+ (User *)retrieveCurrentUser;
+ (void)saveChangesInCoreData;

@end
