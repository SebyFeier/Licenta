//
//  NSDictionary+JSON.m
//  BRMB
//
//  Created by Sebastian Feier on 3/10/14.
//  Copyright (c) 2014 REEA (http://www.reea.net). All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (JSON)

+ (NSMutableDictionary *)createJSONDictionaryFromNSString:(NSString *)jsonString {
    NSMutableDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    return jsonResponse;
}

@end
