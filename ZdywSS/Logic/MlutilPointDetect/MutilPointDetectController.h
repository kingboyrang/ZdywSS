//
//  MutilPointDetectController.h
//  WebServerCore
//
//  Created by dyn on 13-6-6.
//  Copyright (c) 2013年 dyn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddressPingHelper.h"
#import "ZdywServiceManager.h"

@protocol MutilPointDetectControllerDelegate <NSObject>

@optional
// 客户端关闭网络连接
- (void)appDidCloseWeb;

// 网络正常但无法接入http server
- (void)netDidNormal;

// 开始探测第几个接入点
- (void)startDetectPoint:(int)index;

// 结束探测第几个接入点,接入点是否有效
- (void)endDetectPoint:(int)index state:(BOOL)bFlag;

// 没有可用的接入点
- (void)failedDetectPoint;

@end

@interface MutilPointDetectController : NSObject <AddressPingHelperDelegate>
{
    NSMutableArray                  *_testNetHostNameArray;     //测试网络是否正常的外部网络地址
    
    NSMutableArray                  *_mutilPointAddress;        //多点接入的地址
    
    int                             _testNetIndex;              //测试网络状态的外部网络地址索引
    
    AddressPingHelper               *_addressPingHelper;        //ping 外部网络地址
    
    int                             _mutilPointIndex;           //多点接入地址的索引
    
    int                             _currentRequestState;       //当前测试http server请求的状态
    
    NSString                        *_mainHttpServer;           //主http server地址
}

@property(nonatomic, assign)id<MutilPointDetectControllerDelegate> delegate;

@property(copy)NSString *mainHttpServer;
//保存ping结果列表
@property (nonatomic,strong) NSMutableArray *pingHosts;
//保存默认服务器列表
@property (nonatomic,strong) NSMutableArray *defaultHosts;

// 单实例
+ (MutilPointDetectController*)shareInstance;

// 寻找有效的接入点
- (void)findValidHttpServer;

- (void)stopTestHttpServer;

@end
