//
//  ZdywRequestObj.h
//  ZdywMini
//  保存在NSUserDefaults中数据的key
//  Created by mini1 on 14-5-29.
//  Copyright (c) 2014年 Guoling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ZdywServiceHeader.h"
@class ZdywRequestObj;

@protocol ZdywRequestDelegate <NSObject>

- (void)ZdywRequestFinished:(ZdywRequestObj *)requestObj resultDict:(NSDictionary *)resultDict;

- (void)ZdywRequestFailed:(ZdywRequestObj *)requestObj error:(NSError *)error;

@end

@interface ZdywRequestObj : NSObject
<ASIHTTPRequestDelegate>

@property(nonatomic,strong) NSDictionary *requestUserInfo;  //请求信息，请求完成之后原样返回
@property(nonatomic,strong) NSString     *requestKey;       //标识请求的唯一键值
@property(nonatomic,strong) ASIHTTPRequest *requestHandle;        //请求
@property(nonatomic,assign) ZdywServiceType reqServiceType;
@property(nonatomic,assign) id<ZdywRequestDelegate> delegate;

- (void)requestService:(ZdywServiceType)serviceType
              userInfo:(NSDictionary *)reqUserInfo
              postDict:(NSDictionary *)postDict
                   key:(NSString *)reqKey
              delegate:(id<ZdywRequestDelegate>)reqDelegate;

- (void)stopRequest;

@end
