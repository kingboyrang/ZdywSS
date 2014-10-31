//
//  ZdywServiceManager.m
//  ZdywMini
//
//  Created by mini1 on 14-5-29.
//  Copyright (c) 2014年 Guoling. All rights reserved.
//

#import "ZdywServiceManager.h"

static ZdywServiceManager *stat_serviceManager = nil;

@implementation ZdywServiceManager

+ (ZdywServiceManager *)shareInstance
{
    if (stat_serviceManager == nil)
    {
        stat_serviceManager = [[ZdywServiceManager alloc] init];
    }
    
    return stat_serviceManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _requestDict = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    return self;
}

- (void)requestService:(ZdywServiceType)serviceType
              userInfo:(NSDictionary *)userInfo
              postDict:(NSDictionary *)postDict
{
    @synchronized(_requestDict)
    {
        NSString *requestKey = [NSString stringWithFormat:@"%d_%@",
                                serviceType,
                                [NSDate date]];
        ZdywRequestObj *requestObj = [[ZdywRequestObj alloc] init];
        [_requestDict setObject:requestObj forKey:requestKey];
        [requestObj requestService:serviceType
                          userInfo:userInfo
                          postDict:postDict
                               key:requestKey
                          delegate:self];
    }
}

- (void)ZdywRequestFailed:(ZdywRequestObj *)requestObj error:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSDictionary * dic=[NSDictionary dictionaryWithObjectsAndKeys:
                        @"请检查您的网络后重试",@"reason",
                        @"9999",@"result",nil];
    [self ZdywRequestFinished:requestObj resultDict:dic];
}

//停止请求
- (void)stopRequestWithType:(ZdywServiceType)serviceType
{
    @synchronized(_requestDict)
    {
        ZdywRequestObj *tempRequest = [_requestDict objectForKey:[NSString stringWithFormat:@"%d",serviceType]];
        if(tempRequest)
        {
            [tempRequest stopRequest];
            [_requestDict removeObjectForKey:[NSString stringWithFormat:@"%d",serviceType]];
        }
    }
}

- (void)ZdywRequestFinished:(ZdywRequestObj *)requestObj resultDict:(NSDictionary *)resultDict
{
    NSDictionary *userInfo = [[NSDictionary alloc] initWithDictionary:resultDict];
    [_requestDict removeObjectForKey:requestObj.requestKey];
    
    switch (requestObj.reqServiceType)
    {
        case ZdywServiceQueryIsRegister:     // 查询是否注册
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationQueryIsRegister
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case ZdywServicePaycardReg:          // 卡密注册
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPayCardReg
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case ZdywServiceGetVeriftyCode:          // 获取验证码
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGetVeriftyCode
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case ZdywServiceCheckVeriftyCode:          // 校验验证码
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCheckVeriftyCode
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case ZdywServiceResetPSW:          // 确认重置密码
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationResetPSW
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case ZdywServiceRegister:                       //手机注册
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPhoneRegisterFinish
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case CPCActiveType:                             //CPC渠道
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCPCActiveFinish
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case RecordInstallNumberType:                   //安装量
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRecordInstallNumberFinish
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case ZdywServiceLogin:                      //登录
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPhoneLoginFinish
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case ZdywServiceContactBackUpType:          //通讯录备份
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationContactBackUpFinish
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case ZdywServiceContactBackUpInfoType:        //通讯录备份信息
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationContactBackUpInfoFinish
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case ZdywServiceContactRecoveryType:            //通讯录恢复
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationContactRecoveryFinish
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;

        case ZdywServiceDefaultConfigType:          //静态配置
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDefaultConfigFinish
                                                                object:nil
                                                              userInfo:userInfo];
            
           
            break;
        case ZdywServiceTemplateConfigType:          //获取模板配置
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTemplateConfigFinish
                                                                object:nil
                                                              userInfo:userInfo];
            break;
        case ZdywServiceSysMessage:          //获取系统公告
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSystemnoticeFinish
                                                                object:nil
                                                              userInfo:userInfo];
            break;
        case ZdywServiceResetPwdSubmit:  //重置密码提交
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationResetPwdFinish
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case ZdywServiceRegisterGetCode:   //登录获取验证码
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRegisterGetCodeFinish
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case ZdywServiceBackCall:           //回拨
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCallFinish
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case ZdywServiceUserInfoType:{      //获取用户信息
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUserInfoFinish
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case ZdywServiceFindPwdType:{       //找回密码
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFindPwdFinish
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case ZdywServiceSearchBalance:{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSearchBalanceFinish
                                                                object:nil
                                                              userInfo:userInfo];
        }
        case ZdywServiceChangedPhone:{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationChangePhoneFinish
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case ZdywServiceBindNewPhone:{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBindNewPhoneFinish
                                                                object:nil
                                                              userInfo:userInfo];
            break;
        }
        case ZdywServiceFeedback:{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFeedbackFinish
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case ZdywServiceRecharge:{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRechargeFinish
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case ZdywServiceGetGoodsCgfType:{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGetGoodsCGFFininsh
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case ZdywServiceTokenReportType:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTokenReportFininsh
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case ZdywServicepullmsg:{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPushmsgFinish
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case ZdywServicePushFeedback:{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPushFeedbackFinish
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        case ZdywServiceUpdateInfo:{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateVersionFinish
                                                                object:nil
                                                              userInfo:userInfo];
        }
            break;
        default:
            break;
    }
    //403错误特殊处理(sign错误)
    if([[userInfo objectForKey:@"result"] intValue] == 403)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSignErrorEvent
                                                            object:nil
                                                          userInfo:userInfo];
    }
}

@end
