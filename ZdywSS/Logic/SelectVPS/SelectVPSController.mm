//
//  SelectVPSController.m
//  ZdywClient
//
//  Created by zhouww on 13-8-26.
//  Copyright (c) 2013年 guoling. All rights reserved.
//

#import "SelectVPSController.h"
#import "CallManager.h"

static SelectVPSController *g_selectVPSController = nil;

@implementation SelectVPSController

// 单实例
+ (SelectVPSController *)shareInstance
{
    if(g_selectVPSController == nil)
    {
        g_selectVPSController = [[SelectVPSController alloc] init];
    }
    
    return g_selectVPSController;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        _testVPSArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return self;
}

#pragma mark -
#pragma mark 选择最优的vps接入点

// 选择最优的vps
- (void)selectOptimalVPS
{
    [self performSelectorInBackground:@selector(handleSelectOptimalVPS) withObject:nil];
}

// 启动多个线程选择最优的vps
- (void)handleSelectOptimalVPS
{
    @synchronized(self)
    {
        //清除上一次的探测
        for(GCDAsyncUdpSocketController *obj in _testVPSArray)
        {
            obj.delegate = nil;
        }
        
        [_testVPSArray removeAllObjects];
        
        //开始下一次的探测
        _bFindVPSFlag = NO;

        NSArray *hostArray = [ZdywUtils getLocalIdDataValue:kZdywDataKeyVPSIPList];
        NSArray *portArray = [ZdywUtils getLocalIdDataValue:kZdywDataKeyVPSPortList];
        
        if([hostArray count] > 0 && [portArray count] > 0)
        {
            for(NSString *strHost in hostArray)
            {
                for(NSString *strPort in portArray)
                {
                    [NSThread detachNewThreadSelector:@selector(startSendDataToVPS:)
                                             toTarget:self
                                           withObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       strHost, @"host",
                                                       strPort, @"port", nil]];
                }
            }
        }
        else
        {
            return;
        }
    }
}

- (void)startSendDataToVPS:(NSDictionary *)dic
{
    NSString *strHost = [dic objectForKey:@"host"];
    NSString *strPort = [dic objectForKey:@"port"];
    NSLog(@"test vps:%@:%@", strHost, strPort);
    GCDAsyncUdpSocketController *gcdAsyncUdpSocketController = [[GCDAsyncUdpSocketController alloc] initHostName:strHost
                                                                                                        withPort:strPort];
    gcdAsyncUdpSocketController.delegate = self;
    [gcdAsyncUdpSocketController testVPS];
    
    [_testVPSArray addObject:gcdAsyncUdpSocketController];
    gcdAsyncUdpSocketController = nil;
}

#pragma mark -
#pragma mark GCDAsyncUdpSocketControllerDelegate

- (void)sendDataDidEnd:(NSString *)host port:(int)port
{
    @synchronized(self)
    {
        if(_bFindVPSFlag)
        {
            return;
        }
        
        _bFindVPSFlag = YES;
        
        NSLog(@"sendDataDidEnd host: %@, port: %d", host, port);
        
        NSString *strIP = [GCDAsyncUdpSocket getIPWithHostName:host];   //host转换为ip
        NSString *strPort = [NSString stringWithFormat:@"%d", port];
        
        NSLog(@"updateVPS host: %@, port: %@", strIP, strPort);
        
        //保存voip的服务器地址和端口
        [ZdywUtils setLocalDataString:strIP key:kZdywDataKeyVPSIP];
        [ZdywUtils setLocalDataString:strPort key:kZdywDataKeyVPSPort];
        
        if([[CallManager shareInstance] sp_is_registered])
        {
            [[CallManager shareInstance] sp_unregister];
        }
    }
}

@end
