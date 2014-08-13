//
//  NSURL+QueryParser.m
//  novel-design
//
//  Created by ltebean on 14-8-13.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//

#import "NSURL+QueryParser.h"

@implementation NSURL (QueryParser)

-(NSDictionary *)queryDictionary
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *param in [[self query] componentsSeparatedByString:@"&"]) {
        NSArray *parts = [param componentsSeparatedByString:@"="];
        if([parts count] < 2) continue;
        [params setObject:[parts objectAtIndex:1] forKey:[parts objectAtIndex:0]];
    }
    return params;
}

@end
