//
//  AlixPayOb.h
//  AlixPayCore
//
//  Created by dyn on 12-8-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlixPay.h"
//返回值定义
enum {
	kSPErrorOK,//正常
	kSPErrorAlipayClientNotInstalled,//用户未安装支付宝
	kSPErrorSignError,//证书签名错误
};

#define AlixPay_appStore_URL        @"http://itunes.apple.com/cn/app/id333206289?mt=8"］
@interface AlixPayOb : NSObject
//支付保充值接口
-(NSInteger)requestAlixPay:(NSString*)moneyStr schemaStr:(NSString*)schemaStr orderIdStr:(NSString*)orderidStr;
//充值结果返回接口。在UIAppLicaiton的delegate中调用,返回提示语内容
-(NSString*)handleOpenAppWithURL:(NSURL*)url;
@end
