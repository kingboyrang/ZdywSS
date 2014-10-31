//
//  MutilPointDetectController.m
//  3GClient
//
//  Created by zhouww on 13-4-24.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import "MutilPointDetectController.h"
#import <UIKit/UIKit.h>
#import "SimplePingHelper.h"
static MutilPointDetectController *g_mutilPointDetectCtl = nil;

@interface MutilPointDetectController (Private)<SimplePingHelperDelegate>

// 初始化测试网络是否正常的外部网络地址
- (void)buildTestNetDataModel;

// 初始化多点接入的http server地址
- (void)buildMutilPointDataModel;

// 测试http server是否可用
- (void)testHttpServerAction:(int)state;

@end


@implementation MutilPointDetectController

@synthesize delegate = _delegate;
@synthesize mainHttpServer = _mainHttpServer;

// 单实例
+ (MutilPointDetectController*)shareInstance
{
    @synchronized(self)
    {
        if(g_mutilPointDetectCtl == nil)
        {
            g_mutilPointDetectCtl = [[MutilPointDetectController alloc] init];
        }
        
        return g_mutilPointDetectCtl;
    }
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        _testNetIndex = 0;
        self.pingHosts=[NSMutableArray array];
        
        [self setMainHttpServer:nil];
        
        //初始化测试网络是否正常的外部网络地址
        [self buildTestNetDataModel];
        
        //初始化多点接入的http server地址
        [self buildMutilPointDataModel];
        
        // 监听客户端的激活
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appActivedAction) name:UIApplicationDidBecomeActiveNotification object:nil];
        
       
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveTestHttpServerData:)
                                                     name:kNotificationDefaultConfigFinish
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)buildTestNetDataModel
{
    _testNetHostNameArray = [[NSMutableArray alloc] initWithCapacity:0];
    [_testNetHostNameArray addObject:@"www.baidu.com"];
//    [_testNetHostNameArray addObject:@"www.qq.com"];
}

- (void)buildMutilPointDataModel
{
    _mutilPointAddress = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSMutableArray *hosts=[NSMutableArray array];
    NSArray *serviceHosts=[ZdywUtils getLocalIdDataValue:kZdywDataKeyServiceHosts];
    if (serviceHosts) {
        [hosts addObjectsFromArray:serviceHosts];
    }else{
        NSString *cfgFilePath = [[NSBundle mainBundle] pathForResource:@"ZdywConfigure"                                                       ofType:@"plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:cfgFilePath]){
            NSDictionary *cfgDictionary=[[NSDictionary alloc] initWithContentsOfFile:cfgFilePath];
            [hosts addObjectsFromArray:[cfgDictionary objectForKey:kZdywDataKeyServiceHosts]];
        }
    }
    NSString *defaultServiceHttp=[ZdywUtils getLocalIdDataValue:kZdywDataKeyServerAddress];
    if ([defaultServiceHttp length]>0) {
        if (![hosts containsObject:defaultServiceHttp]) {
            [hosts addObject:defaultServiceHttp];
        }
    }
    self.defaultHosts=hosts;
    
    [_mutilPointAddress addObjectsFromArray:self.defaultHosts];
    /***
     NSArray * mutilPointDomains = [NSArray arrayWithObjects:@"http://agw.shuodh.com",@"http://agw1.shuodh.com",@"http://agw2.shuodh.com",@"http://agw3.shuodh.com",@"http://agw4.shuodh.com",nil];
     NSArray * mutilPointPort = [NSArray arrayWithObjects:@"2001",@"2002",@"2003",@"2004",@"2005",nil];
     for (NSString *domainsStr in mutilPointDomains) {
     for (NSString *portStr in mutilPointPort) {
     NSLog(@"%@",[NSString stringWithFormat:@"%@:%@",domainsStr,portStr]);
     [_mutilPointAddress addObject:[NSString stringWithFormat:@"%@:%@",domainsStr,portStr]];
     }
     }
     ***/
}

// 停止测试http server
- (void)stopTestHttpServer
{
    [[ZdywServiceManager shareInstance] stopRequestWithType:ZdywServiceDefaultConfigType];
}

#pragma  mark -
#pragma mark AddressPingHelperDelegate

// 监听客户端激活的操作，并检查http server是否可用
- (void)appActivedAction
{
    [self handleAppActivedAction];
    // [self performSelectorInBackground:@selector(handleAppActivedAction) withObject:nil];
}

- (void)handleAppActivedAction
{
    PhoneNetType  netType = [ZdywUtils getCurrentPhoneNetType];
    
    if(netType == PNT_UNKNOWN)
    {
        //用户为开启网络，提示用户开启网络
        if(self.delegate && [self.delegate respondsToSelector:@selector(appDidCloseWeb)])
        {
            [self.delegate appDidCloseWeb];
        }
    }
    else
    {
        //ping多个服务器
        [self testPingHosts];
        //[self performSelectorInBackground:@selector(testPingHosts) withObject:nil];
        
        //用户已开启网络，开始尝试请求一次数据
        //[self testHttpServerAction:0];
    }
}

#pragma mark -
#pragma mark test http server

// 测试http server是否可用
- (void)testHttpServerAction:(int)state
{
    _currentRequestState = state;
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceDefaultConfigType
                                              userInfo:nil
                                              postDict:nil];
}

// 解析test http server返回的数据
- (void)receiveTestHttpServerData:(NSNotification*)notification
{
    NSDictionary *dic = [notification userInfo];
    
    if([dic objectForKey:@"result"])
    {
        int nRet = [[dic objectForKey:@"result"] intValue];
        
        if(nRet == 0)
        {
            if(_currentRequestState == 0)
            {

                NSLog(@"http server normal");
                
                return;
            }
            else
            {
                //探测接入点成功
                if(self.delegate && [self.delegate respondsToSelector:@selector(endDetectPoint:state:)])
                {
                    [self.delegate endDetectPoint:_mutilPointIndex+1 state:YES];
                }
                
                return;
            }
        }
    }
    
    NSLog(@"http server failed");
    
    if(_currentRequestState == 0)
    {
        //检测网络是否正常
        [self testNetState];
    }
    else
    {
        //探测上个接入点失败
        if(self.delegate && [self.delegate respondsToSelector:@selector(endDetectPoint:state:)])
        {
            [self.delegate endDetectPoint:_mutilPointIndex+1 state:NO];
        }
        
        //探测下个接入点
        [self findNextValidHttpServer];
    }
}

#pragma mark -
#pragma mark test net normal?

- (void)testNetState
{
    //初始化变量
    _testNetIndex = 0;
    
    //ping操作
    if(_testNetIndex < [_testNetHostNameArray count])
    {
        NSString *strHostName = [_testNetHostNameArray objectAtIndex:_testNetIndex];
        
        _addressPingHelper = [[AddressPingHelper alloc] init];
        _addressPingHelper.delegate = self;
        [_addressPingHelper pingHostName:strHostName];
    }
}

// 网络异常
- (void)testNetDidAbnormal
{
    _testNetIndex++;
    
    if(_testNetIndex < [_testNetHostNameArray count])
    {
        NSString *strHostName = [_testNetHostNameArray objectAtIndex:_testNetIndex];
        
        _addressPingHelper = [[AddressPingHelper alloc] init];
        _addressPingHelper.delegate = self;
        [_addressPingHelper pingHostName:strHostName];
    }
    else
    {
        NSLog(@"net abnormal");
    }
   
}

// 网络正常
- (void)testNetDidNormal
{
    NSLog(@"net normal");
    //网络正常但无法接入http server
    if(self.delegate && [self.delegate respondsToSelector:@selector(netDidNormal)])
    {
        [self.delegate netDidNormal];
    }
}
#pragma mark -
#pragma mark find valid http server

// 寻找有效的接入点
- (void)findValidHttpServer
{
    [self testPingHosts];
    //[self performSelectorInBackground:@selector(testPingHosts) withObject:nil];
    //[self performSelectorInBackground:@selector(handleFindValidHttpServer) withObject:nil];
}

- (void)handleFindValidHttpServer
{
    _mutilPointIndex = 0;
    
    NSString *strTemp = [ZdywUtils getLocalStringDataValue:kZdywDataKeyServerAddress];
    [self setMainHttpServer:strTemp];
   
    //探测可用的http server
    if(_mutilPointIndex < [_mutilPointAddress count])
    {
        NSString *strHttpServer = [_mutilPointAddress objectAtIndex:_mutilPointIndex];
        
        [ZdywUtils setLocalDataString:strHttpServer key:kZdywDataKeyServerAddress];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(startDetectPoint:)])
        {
            [self.delegate startDetectPoint:_mutilPointIndex+1];
        }
        
        [self testHttpServerAction:1];
    }
}

- (void)findNextValidHttpServer
{
    _mutilPointIndex++;
    
    //探测可用的http server
    if(_mutilPointIndex < [_mutilPointAddress count])
    {
        NSString *strHttpServer = [_mutilPointAddress objectAtIndex:_mutilPointIndex];
        
        [ZdywUtils setLocalDataString:strHttpServer key:kZdywDataKeyServerAddress];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(startDetectPoint:)])
        {
            [self.delegate startDetectPoint:_mutilPointIndex+1];
        }
        
        [self testHttpServerAction:1];
    }
    else
    {
       
        //找不到可用的http server
        if(self.delegate && [self.delegate respondsToSelector:@selector(failedDetectPoint)])
        {
            [self.delegate failedDetectPoint];
        }
        
    }
}
//ping多个主机
- (void)testPingHosts
{
    if (self.pingHosts&&[self.pingHosts count]>0) {
        [self.pingHosts removeAllObjects];
    }
    for (NSString *item in self.defaultHosts)
    {
        [SimplePingHelper ping:item delegate:self];
    }
}
#pragma mark -ping结果保存
- (void)simplePingHelperResult:(SimplePingResult*)result{
    [self.pingHosts addObject:result];
    if ([self.pingHosts count]==[self.defaultHosts count]) {
        //ping结果快慢的排序
        NSArray *results= [self.pingHosts sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            SimplePingResult *mod1=(SimplePingResult*)obj1;
            SimplePingResult *mod2=(SimplePingResult*)obj2;
            if (mod1.pingHostStatus<=mod2.pingHostStatus&&mod1.timeInterval<=mod2.timeInterval) {
                return NSOrderedAscending;  // 降序
            }
            return  NSOrderedDescending; // 升序
        }];
        
        if (results&&[results count]>0) {
            //判断是否全部超时
            BOOL  boo=NO;
            for (SimplePingResult *item in results) {
                if (item.pingHostStatus!=PingHostAddressStatusTimeOut) {
                    boo=YES;
                    break;
                }
            }
            if(!boo)return;
            [_mutilPointAddress removeAllObjects];
            //保存ping排序后的服务器地址列表
            for (SimplePingResult *item in results) {
                NSLog(@"hostName=%@,time=%f,success=%d",item.hostName,item.timeInterval,item.pingHostStatus);
                [_mutilPointAddress addObject:item.hostName];
            }
            [self.pingHosts removeAllObjects];
            //对排序后的ping重新探测保存
            [self performSelectorInBackground:@selector(handleFindValidHttpServer) withObject:nil];
            
        }
    }
}

@end
