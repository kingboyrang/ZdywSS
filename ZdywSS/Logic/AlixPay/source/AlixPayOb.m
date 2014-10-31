//
//  AlixPayOb.m
//  AlixPayCore
//
//  Created by dyn on 12-8-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AlixPayOb.h"
#import "AlixPayOrder.h"
#import "ChargeDefine.h"
#import "AlixPay.h"
#import "DataSigner.h"
#import "DataVerifier.h"
@implementation AlixPayOb
-(NSInteger)requestAlixPay:(NSString*)moneyStr schemaStr:(NSString*)schemaStr orderIdStr:(NSString*)orderidStr;

{
	/*
	 *生成订单信息及签名
	 *由于demo的局限性，本demo中的公私钥存放在AlixPayDemo-Info.plist中,外部商户可以存放在服务端或本地其他地方。
	 */
	//将商品信息赋予AlixPayOrder的成员变量
	AlixPayOrder *order = [[AlixPayOrder alloc] init];
	order.partner = ALIXPAY_PARTNER;
	order.seller = ALIXPAY_SELLER;
	order.tradeNO = orderidStr; //订单ID（由商家自行制定）
	order.productName = @"充值"; //商品标题
	order.productDescription = [NSString stringWithFormat:@"充值%@",moneyStr]; //商品描述
	//order.amount = [NSString stringWithFormat:@"%d", [moneyStr intValue]]; //商品价格
    order.amount = moneyStr; //商品价格
	order.notifyURL =  @"http://epay.keepc.com/epay/gateway/alipay_security.act"; //回调URL
	
	//应用注册scheme,在Info.plist定义URL types,用于安全支付成功后重新唤起商户应用
	NSString *appScheme = schemaStr; 
	 
	//将商品信息拼接成字符串
	NSString *orderSpec = [order description];
	NSLog(@"orderSpec = %@",orderSpec);
	
	//获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
	id<DataSigner> signer = CreateRSADataSigner(ALIXPAY_RSAPRIVATEKEY);
	NSString *signedString = [signer signString: orderSpec];
	
	//将签名成功字符串格式化为订单字符串,请严格按照该格式
	NSString *orderString = nil;
	if (signedString != nil)
    {
		orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
	}
	//获取安全支付单例并调用安全支付接口
	AlixPay * alixpay = [AlixPay shared];
	int ret = [alixpay pay:orderString applicationScheme:appScheme];
	
	if (ret == kSPErrorAlipayClientNotInstalled)
    {
        return kSPErrorAlipayClientNotInstalled;
	}
	else if (ret == kSPErrorSignError)
    {
        return kSPErrorSignError;
	}
    return kSPErrorOK;
}
-(NSString*)handleOpenAppWithURL:(NSURL*)url{
    AlixPay *alixpay = [AlixPay shared];
    AlixPayResult  *result = [alixpay handleOpenURL:url];
    NSString * returnStr = @"";
    if (result)
    {
		//是否支付成功
		if (9000 == result.statusCode)
        {
			/*
			 *用公钥验证签名
			 */
			id<DataVerifier> verifier = CreateRSADataVerifier(ALIXPAY_RSAPUBLICKEY);
			if ([verifier verifyString:result.resultString withSign:result.signString])
            {
                returnStr =  @"正在为您核实支付情况，请在2分钟后查询余额";
			}
            //验签错误
			else
            {
				returnStr= @"签名错误";
																
            }
		}
		//如果支付失败,可以通过result.statusCode查询错误码
		else
        {
			returnStr = result.statusMessage;
		}
	}
    return returnStr;

}

@end
