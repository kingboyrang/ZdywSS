//
//  GCDAsyncUdpSocketController.m
//  ZdywClient
//
//  Created by zhouww on 13-8-26.
//  Copyright (c) 2013年 guoling. All rights reserved.
//

#import "GCDAsyncUdpSocketController.h"

@implementation GCDAsyncUdpSocketController

#define kSendDataCount          5

@synthesize delegate = _delegate;

@synthesize host = _host;
@synthesize port = _port;

// 初始化
- (id)initHostName:(NSString *)host withPort:(NSString *)port
{
    self = [super init];
    
    if(self)
    {
        [self setHost:host];
        [self setPort:[port intValue]];
        
        _tag = 0;
    }
    
    return self;
}

#pragma mark -
#pragma mark test vps

// 测试vps的相关参数
- (void)testVPS
{
    _gcdAsyncUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    
    if (![_gcdAsyncUdpSocket bindToPort:0 error:&error])
    {
        NSLog(@"bindToPort error");
        
        return;
    }
    if (![_gcdAsyncUdpSocket beginReceiving:&error])
    {
        NSLog(@"beginReceiving error");
        
        return;
    }
    
    [self sendData];
}

- (void)sendData
{
    NSString *msg = [NSString stringWithFormat:@"pong %d", _tag];
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:data toHost:self.host port:self.port withTimeout:1 tag:_tag];
    
    _tag++;
}

#pragma mark -
#pragma mark send/receive data delegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
	// You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
	// You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
	NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
	if (msg)
	{
        NSLog(@"receive msg:%@", msg);
        
        if(_tag < kSendDataCount)   //发送数据的次数不够，继续发
        {
            [self sendData];
        }
        else    //已发送相应的次数，接收发送数据
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(sendDataDidEnd:port:)])
            {
                [self.delegate sendDataDidEnd:self.host port:self.port];
            }
        }
	}
	else
	{
		NSString *host = nil;
		uint16_t port = 0;
		[GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
        
        NSLog(@"receive unknown msg from host:%@, port:%d", host, port);
	}
}

@end
