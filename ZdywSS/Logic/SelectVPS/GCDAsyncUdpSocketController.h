//
//  GCDAsyncUdpSocketController.h
//  ZdywClient
//
//  Created by zhouww on 13-8-26.
//  Copyright (c) 2013年 guoling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

@protocol GCDAsyncUdpSocketControllerDelegate <NSObject>

- (void)sendDataDidEnd:(NSString *)host port:(int)port;

@end

@interface GCDAsyncUdpSocketController : NSObject
{
    GCDAsyncUdpSocket                   *_gcdAsyncUdpSocket;
    
    NSString                            *_host;
    int                                 _port;
    
    int                                 _tag;
}

@property(assign)id<GCDAsyncUdpSocketControllerDelegate> delegate;

@property(copy)NSString *host;
@property(assign)int port;

// 初始化
- (id)initHostName:(NSString *)host withPort:(NSString *)port;

// 测试vps的相关参数
- (void)testVPS;

@end
