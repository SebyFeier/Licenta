//
//  NSString+JSON.m
//  Licenta2
//
//  Created by Seby Feier on 26/03/15.
//  Copyright (c) 2015 Seby Feier. All rights reserved.
//

#import "NSString+JSON.h"

@implementation NSString (JSON)

+ (NSString *)createJSONFromObject:(id)object {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:kNilOptions
                                                         error:&error];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return json;
}

@end
