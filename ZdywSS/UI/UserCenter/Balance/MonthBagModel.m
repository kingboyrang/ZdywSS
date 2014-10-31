//
//  MonthBagModel.m
//  ZdywClient
//
//  Created by ddm on 6/24/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "MonthBagModel.h"

@implementation MonthBagModel

- (id)initWithDict:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        id tagTitle = [dic objectForKey:@"package_name"];
        if (tagTitle && ![tagTitle isKindOfClass:[NSNull class]]) {
            _title = tagTitle;
        }
        
        id packageName = [dic objectForKey:@"package_name"];
        if (packageName && ![packageName isKindOfClass:[NSNull class]]) {
            _bagName = packageName;
        }
        
        id effTime = [dic objectForKey:@"eff_time"];
        if (effTime && ![effTime isKindOfClass:[NSNull class]]) {
            _beginTime = effTime;
        }
        
        id expTime = [dic objectForKey:@"exp_time"];
        if (expTime && ![expTime isKindOfClass:[NSNull class]]) {
            _endTime = expTime;
        }
        
        id second = [dic objectForKey:@"month_left_time"];
        if (second && ![second isKindOfClass:[NSNull class]]) {
            _traceMinute = [second integerValue];
        }
        
        id strType = [dic objectForKey:@"prefix"];
        if (strType && ![strType isKindOfClass:[NSNull class]]) {
            NSString * prefix = strType;
            if ([prefix isEqualToString:@"0083"]) {
                _traceMinute = _traceMinute/120;
            } else {
                _traceMinute = _traceMinute/60;
            }
        }
        
        id buy_time = [dic objectForKey:@"buy_time"];
        if (buy_time && ![buy_time isKindOfClass:[NSNull class]]) {
            _buyTime = buy_time;
        }
    }
    return self;
}

@end
