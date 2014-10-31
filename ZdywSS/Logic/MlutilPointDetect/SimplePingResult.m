//
//  SimplePingResult.m
//  PingServiceDemo
//
//  Created by wulanzhou-mini on 14-10-16.
//  Copyright (c) 2014年 guoling. All rights reserved.
//

#import "SimplePingResult.h"

@implementation SimplePingResult
- (id)init{
    if (self=[super init]) {
        self.hostName=@"";
        self.success=NO;
        self.pingHostStatus=PingHostAddressStatusFailed;
        self.timeInterval=9999999.0;
        self.packetLength=0;
    }
    return self;
}
@end
