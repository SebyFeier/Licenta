//
//  NSDictionary+JSON.h
//  BRMB
//
//  Created by Sebastian Feier on 3/10/14.
//  Copyright (c) 2014 REEA (http://www.reea.net). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSON)

+ (NSMutableDictionary *)createJSONDictionaryFromNSString:(NSString *)jsonString;

@end
