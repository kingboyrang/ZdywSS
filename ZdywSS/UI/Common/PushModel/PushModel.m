//
//  PushModel.m
//  ZdywClient
//
//  Created by ddm on 7/3/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "PushModel.h"

@implementation PushModel

- (id)initWithDic:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        NSDictionary *aps = [dictionary objectForKey:@"aps"];
        self.sound = [aps objectForKey:@"sound"];
        self.badge = [aps objectForKey:@"badge"];
        self.alert = [aps objectForKey:@"alert"];
        
        NSDictionary *redirect = [dictionary objectForKey:@"redirect"];
        self.Id = [redirect objectForKey:@"id"];
        self.target = [redirect objectForKey:@"target"];
        self.type = [redirect objectForKey:@"type"];
    }
    return self;
}

@end
