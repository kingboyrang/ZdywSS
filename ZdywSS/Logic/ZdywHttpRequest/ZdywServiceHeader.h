//
//  ZdywServiceHeader.h
//  ZdywMini
//
//  Created by mini1 on 14-5-29.
//  Copyright (c) 2014年 Guoling. All rights reserved.
//


#define kAGWDataString              @"data"                             //data数据段
#define kAGWVersion                 @"1.0"

//请求方式
typedef enum
{
    ZdywRequestTypePost = 0, //post方式请求
    ZdywRequestTypeGet,      //get方式请求
}ZdywRequestType;


//业务类型
typedef enum
{
    ZdywServiceNone = 0,
    ZdywServiceRegister,                            //注册
    ZdywServiceRegisterCode,                        //验证码注册（手机验证）获取验证码
    ZdywServiceLogin,                               //登录
    ZdywServiceBackCall,                            //回拨
    ZdywServiceChangedPhone,                        //发起改绑手机请求(下发绑定手机验证码)
    ZdywServiceBindNewPhone,                        //确定绑定手机
    ZdywServiceSearchBalance,                       //查询余额
    ZdywServiceResetPwdSubmit,                      //重置密码
    ZdywServiceShowPhone,                           //来电显示
    ZdywServiceSysMessage,                          //系统公告
    CPCActiveType,                                  //CPC激活统计
    RecordInstallNumberType,                        //上传安装量统计
    ZdywServiceContactBackUpType,                   //通讯录备份
    ZdywServiceContactRecoveryType,                 //通讯录恢复
    ZdywServiceContactBackUpInfoType,               //通讯录备份信息
    ZdywServiceDefaultConfigType,                   //静态配置
    ZdywServiceTemplateConfigType,                  //模板配置
    ZdywServiceGetGoodsCgfType,                     //拉取商品列表
    ZdywServiceUserInfoType,                        //获取用户信息(如注册时间)
    ZdywServiceFindPwdType,                         //找回密码
    ZdywServiceFeedback,                            //用户反馈
    ZdywServiceRecharge,                            //充值卡充值
    ZdywServiceTokenReportType,                     //token上传
    ZdywServicepullmsg,                             //push拉取消息
    ZdywServicePushFeedback,                        //push消息阅读反馈
    ZdywServiceUpdateInfo,
    
    ZdywServiceRegisterGetCode,                     //新注册，获取验证码
    ZdywServiceResetPwdJudgeCodeType,               //重置密码验证验证码
    
    //Add enum
    ZdywServiceQueryIsRegister ,                     //查询用户是否注册
    ZdywServicePaycardReg       ,                     //使用卡密注册
    ZdywServiceGetVeriftyCode    ,                    //获取验证码
    ZdywServiceCheckVeriftyCode  ,                    //校验验证码
    ZdywServiceResetPSW                               //确认重置密码
    
}ZdywServiceType;


//http的请求完成的通知定义
#define  kNotificationResetPSW                      @"kNotificationResetPSW"                 // 确认重置密码
#define  kNotificationGetVeriftyCode                @"kNotificationGetVeriftyCode"           // 获取验证码
#define  kNotificationCheckVeriftyCode              @"kNotificationCheckVeriftyCode"           // 校验验证码
#define  kNotificationQueryIsRegister               @"kNotificationQueryIsRegister"           // 查询是否已经注册
#define  kNotificationPayCardReg                    @"kNotificationPayCardReg"                // 使用卡密注册
#define  kNotificationCPCActiveFinish               @"kNotificationCPCActiveFinish"           //CPC激活统计
#define  kNotificationRecordInstallNumberFinish     @"kNotificationRecordInstallNumberFinish" //上传安装量统计
#define  kNotificationPhoneRegisterFinish           @"kNotificationPhoneRegisterFinish"     //手机注册完成
#define  kNotificationPhoneLoginFinish              @"kNotificationPhoneLoginFinish" //登录(兼容uid/phone/email)
#define  kNotificationChangePhoneFinish             @"kNotificationChangePhoneFinish"      //发起改绑手机
#define  kNotificationBindNewPhoneFinish            @"kNotificationBindNewPhoneFinish"     //确定绑定手机

#define kNotificationContactBackUpFinish            @"kNotificationContactBackUpFinish"   //联系人备份
#define kNotificationContactRecoveryFinish          @"kNotificationContactRecoveryFinish"  //联系人恢复
#define kNotificationContactBackUpInfoFinish        @"kNotificationContactBackUpInfoFinish" //联系人备份信息

#define kNotificationDefaultConfigFinish            @"kNotificationDefaultConfig"          //静态配置
#define kNotificationTemplateConfigFinish           @"kNotificationTemplateConfig"         //模板配置
#define kNotificationThirtyminiutesFinish           @"kNotificationThirtyminiutes"         //30分钟时间监听
#define kNotificationSystemnoticeFinish             @"kNotificationSystemnotice"           //系统公告监听
#define kNotificationGetGoodsCGFFininsh             @"kNotificationGetGoodsCGFFininsh"     //拉取商品列表
#define kNotificationUpdateVersionFinish            @"kNotificationUpdateVersion"          //更新版本
#define kNotificationUserInfoFinish                 @"kNotificationUserInfoFinish"   //获取用户相关信息(如注册时间)
#define  kNotificationUpdateVPSArrayFinish          @"kNotificationUpdateVPSArray"         //更新多点接入数组
#define  kNotificationSignErrorEvent                @"kNotificationSignErrorEvent"         //sign错误事件
#define kNotificationResetPwdFinish                 @"kNotificationResetPwdFinish"         //重置密码结果
#define kNotificationRegisterGetCodeFinish          @"kNotificationRegisterGetCodeFinish"  //注册结束
#define kNotificationCallFinish                     @"kNotificationCallFinish"             //回拨电话结束
#define kNotificationFindPwdFinish                  @"kNotificationFindPwdFinish"          //找回密码

#define  kNotificationSearchBalanceFinish           @"kNotificationSearchBalanceFinish"    //查询余额
#define  kNotificationFeedbackFinish                @"kNotificationFeedbackFinish"         //用户反馈
#define  kNotificationRechargeFinish                @"kNotificationRechargeFinish"         //充值卡充值

#define  kNotificationTokenReportFininsh            @"kNotificationTokenReportFininsh"     //远程token上传监听
#define  kNotificationPushmsgFinish                 @"kNotificationPushmsgFinish"          //push消息监听
#define  kNotificationPushFeedbackFinish            @"kNotificationPushFeedbackFinish"     //push消息阅读反馈


#define kNotificationShowNoticeView                @"kNotificationShowNoticeView"          //显示主页面的公告视图
#define kNotificationBindPhoneView                 @"kNotificationBindPhoneView"           //显示绑定手机

#define kNotificationCallList                      @"kNotificationCallList"
