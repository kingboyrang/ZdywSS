//
//  SimplePingResult.h
//  PingServiceDemo
//
//  Created by wulanzhou-mini on 14-10-16.
//  Copyright (c) 2014年 guoling. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum{
    PingHostAddressStatusSuccess=0,//ping主机成功
    PingHostAddressStatusFailPacket=1,//ping成功但丢包
    PingHostAddressStatusFailed=2,//ping主机失败
    PingHostAddressStatusTimeOut=3//ping主机超时
}PingHostAddressStatus;


@interface SimplePingResult : NSObject
@property (nonatomic,assign) BOOL success;//是否ping成功
@property (nonatomic,strong) NSString *hostName;//ping主机
@property (nonatomic,assign) PingHostAddressStatus pingHostStatus;//主机状态
@property (nonatomic,assign) NSTimeInterval timeInterval;//ping所花时间
@property (nonatomic,assign) NSInteger packetLength;//丢包大小
@end
