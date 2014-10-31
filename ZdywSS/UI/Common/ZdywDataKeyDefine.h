//
//  ZdywDataKeyDefine.h
//  ZdywMini
//  保存在NSUserDefaults中数据的key
//  Created by mini1 on 14-5-29.
//  Copyright (c) 2014年 Guoling. All rights reserved.
//

#ifndef ZdywMini_ZdywDataKeyDefine_h
#define ZdywMini_ZdywDataKeyDefine_h


// 拨打方式设置类型
typedef enum
{
    ZdywDialModeDirect,         //直拨方式
    ZdywDialModeCallBack,       //回拨方式
    ZdywDialModeSmart,          //智能拨打方式
    ZdywDialModeManual,         //手动选择
}ZdywDialModeType;

// 拨打方式
typedef enum
{
    ZdywCallBackType=0,                //回拨
    ZdywDirectCallType,                //直拨
    ZdywSmartCallType,              //智能拨打
    ZdywSystemCallType,             //系统拨打
    ZdywCallNoneType
}ZdywCallType;

typedef enum {
    FuncMenuType_Message,
    FuncMenuType_Balance,
    FuncMenuType_Recharge,
    FuncMenuType_Account,
    FuncMenuType_Setup,
    FuncMenuType_Help,
    FuncMenuType_Feedback
}FuncMenuType;

#define Init(a,Obj)         {if (!Obj) {a = @"";}\
else if([ Obj isKindOfClass:[NSNull class]]){a= @"";}\
else {a = Obj;}}

#define kAGWAnType                  @"kAGWAnType"                       //算法编码
#define kAGWKnType                  @"kAGWKnType"                       //key编码
#define kAGWTkType                  @"kAGWTkType"                       //临时key

#define kNowSelectRechargeType          @"kNowSelectRechargeType"   //目前选择的充值方式
#define kNowPayMoneyString              @"kNowPayMoneyString"       //目前选择的充值方式的已支付金额
#define kNowSelectGoodId                @"kNowSelectGoodId"     //用户目前选择的充值产品id

#define kZdywDataKeyServiceHosts        @"ios_server_hosts"  //配置服务地址列表key
/**************系统颜色配置***************/
#define kZdywDataKeyColorInfo                    @"ios_color_info"  //系统颜色配置key
#define kZdywDataKeyNavBarBgColor                @"kNavigationBarBgColor" //导航背景
#define kZdywDataKeyNavBarBackGroundColor        @"kNavigationBarBackGroundColor" //导航栏返回字体颜色
#define kZdywDataKeyNavBarTitleFontColor         @"kNavigationBarTitleFontColor" //导航栏标题字体颜色
#define kZdywDataKeyNavBarTitleFontSize          @"kNavigationBarTitleFontSize" //导航栏标题字体大小
#define kZdywDataKeyNavBarTitleHasShadow         @"kNavigationBarTitleHasShadow" //导航栏标题是否有阴影
#define kZdywDataKeyNavBarTitleShadowColor       @"kNavigationBarTitleShadowColor" //导航栏标题阴影颜色

#define kZdywDataKeyZdywFontColor                @"kZdywFontColor" //项目中字体颜色
#define kZdywDataKeyMainSelectedFontColor        @"kZdywMainSelectedFontColor" //通话记录与联系人选中时的颜色
#define kZdywDataKeyMainNormalFontColor          @"kZdywMainNormalFontColor" //通话记录与联系人未选中时的颜色
/**************基本信息配置***************/
#define kZdywDataKeySoftWareInfo        @"ios_software_info" //配置基本信息key
#define kZdywDataKeyBrandID             @"kZdywBrandID"  //bid 品牌
#define kZdywDataKeyDisplayName         @"kZdywAlertDisplayName"  //bid 品牌
#define kZdywDataKeyAppID               @"kZdywAppleID"  //apple id kZdywAlertDisplayName
#define kZdywDataKeyVersion             @"kZdywDataKeyVersion"   //版本号
#define kZdywDataKeyServerAddress       @"kZdywHttpServer"  //服务器地址
#define kZdywDataKeyServerKey           @"kZdywPublicKey"   //品牌key
#define kZdywDataKeyPlateVersion        @"kZdywPhoneType"   //pv
#define kZdywDataKeyInviteNum           @"kInvite"   //渠道号
#define kZdywDataKeyInviteWay           @"kZdywDataKeyInviteWay"   //渠道类型
#define kZdywDataKeyAppStoreVersion     @"kAppStoreVersion"     //是否为appstore版本
#define kZdywDataKeyPaySource           @"kPaySource"
#define kZdywDataKeyCustomerServiceQQ   @"kCustomerServiceQQ"   //客服QQ
#define kZdywDataKeyMaxFeelCPhoneCount  @"kMaxFeelCPhoneCount"   //最大拨打次数后手机验证
#define kZdywDataKeyCustomerPhone       @"kCustomerServicePhone" //客服电话
#define kZdywDataKeyServiceTime         @"kCustomerServiceTime"  //客服服务时间
#define kZdywDataKeyBagMonthOrYear      @"kZdywHasBagMonthOrYear"  //有无包月/年套餐
#define kZdywDataKeyDialModelType       @"kDialModelType"  //默认拨打设置



#define kNotificationAlixPayRechargeFininsh     @"kNotificationAlixPayRechargeFininsh"      //支付宝支付返回
#define kNotificationReceiveNewPushMsg          @"kNotificationReceiveNewPushMsg"           //获取新消息通知

#define kZdywDataKeyMoPhone       @"kZdywDataKeyMoPhone"
#define kZdywDataKeyUserID        @"kZdywDataKeyUserID"  //用户ID
#define kZdywDataKeyUserPwd       @"kZdywDataKeyUserPwd" //用户密码
#define kZdywDataKeyUserPhone     @"kZdywDataKeyUserPhone" //用户手机号
#define kZdywDataKeyUserEmail     @"kZdywDataKeyUserEmail" //用户邮箱
#define kNewAccountFirstLoginFlag       @"kNewAccountFirstLoginFlag"    //新用户第一次登录标记
#define kCurrentCountryCode       @"kCurrentCountryCode"   //城市编码
#define kUserDefaultZone          @"kUserDefaultZone" //用户默认区号
#define kCurrentCountryName       @"kCurrentCountryName"

#define kRemotePushDeviceToken          @"kRemotePushDeviceToken"       //remote push token
#define kRemotePushTokenReportFlag      @"kRemotePushTokenReportFlag"   //remote push token report flag
#define kRemotePushTokenState           @"kRemotePushTokenState"        //remote push token state
#define kPushMessageArray               @"kPushMessageArray"            //存储push获取到得数据

#define kCallBackCount                  @"kCallBackCount"               //回拨使用次数
#define kCallBackIsTip                  @"kCallBackIsTip"               //回拨是否需要在提醒

#define kZdywDataKeyVPSIPList     @"kZdywDataKeyVPSIPList"    //直拨ip地址列表
#define kZdywDataKeyVPSPortList   @"kZdywDataKeyVPSPortList"  //直拨port列表
#define kZdywDataKeyVPSIP         @"kZdywDataKeyVPSIP"        //最优的直拨ip
#define kZdywDataKeyVPSPort       @"kZdywDataKeyVPSPort"      //最优的直拨port
#define kIsGetInviteWay           @"kIsGetInviteWay"          //首次安装上传mac地址的同时请求inviteway（CPC)
#define kUserBindRewardTips             @"kUserBindRewardTips"          //用户绑定手机奖励

#define kZdywGetSysMessageFlag      @"kZdywGetSysMessageFlag"           //系统公告上次请求标记
#define kTemeplateConfigSameFlag    @"kTemeplateConfigSameFlag"         //模板配置上次请求标记
#define kDefaultConfigSameFlag      @"kDefaultSameFlag"                 //静态配置上次请求标记
#define kGetGoodsCgfFlag            @"kGetGoodsCgfFlag"                 //商品列表上次请求标记

#define kZdywDataString           @"data"                                 //data数据段
#define kAGWDataString            @"data"                                 //data数据段
#define kRecordInstall            @"IsRecordInstall"                      //是否统计过装机量

#define kShowHiddenFunction         @"kShowHiddenFunction"              //显示隐藏的功能

#define kIsChinaAcount                          @"kIsChinaAcount"                   //是否为中国用户
#define kZdywDialTipsInfo                   @"kZdywDialTipsInfo"                //拨号盘tips
//qq相关配置信息

#define kRecommandMoneyName                     @"kRecommandMoneyName"              //充值页推荐套餐名字
#define kLastShowRechargeTipTime                @"kLastShowRechargeTipTime"         //充值页顶部文字最后一次出现时间

#define kUpdateMandatory            @"kUpdateMandatory"                 //更新版本的方式
#define kUpdateVersion              @"kUpdateVersion"                   //当前升级版本号
#define kUpdateAddress              @"kUpdateAddress"                   //更新地址
#define kUpdateInfo                 @"kUpdateInfo"                      //更新信息
#define KUpdateTipNumber            @"KUpdateTipNumber"                 //跟新提醒次数
#define KUpdateTipDate              @"KUpdateTipDate"                   //跟新的日期
#define KUpdateIsNumber             @"KUpdateIsNumber"                  //已经提醒的更新次数

#define kVersionUpdateUrl           @"kVersionUpdateUrl"                //跳转到更新页面
#define kCerExpirationDate          @"kCerExpirationDate"               //证书过期前15天时间
#define kExpirationDateTip          @"kExpirationDateTip"               //证书过期前15天每天提醒一次

//保存系统公告的相关信息
#define kPayInfo                        @"kPayInfo"                     //优惠信息
#define kFavourableInfo                 @"kFavourableInfo"              //最新优惠

//充值相关配置
#define kAppstoreRechargeShow       @"kAppstoreRechargeShow"            //是否显示官方充值
#define kAppstoreRechargeListArray  @"kAppstoreRechargeListArray"       //静态配置下发的官方充值列表

#define kGoodsRechargeListArray     @"kGoodsRechargeListArray"          //商品系统下发的充值列表

#define kNeedReloadRechargeData     @"kNeedReloadRechargeData"          //是否需要刷新充值界面数据
#define kRechargeListNodeArray      @"kRechargeListNodeArray"           //充值列表界面数据
#define kRechargePayTypeArray       @"kRechargePayTypeArray"            //充值方式数组

#define KZdywAppFristLaunch         @"KZdywAppFristLaunch"              //应用第一次启动加载引导页面

#define kAccountDetailWebURL        @"kAccountDetailWebURL"             //收支明细
#define kAccountPayListWebURL       @"kAccountPayListWebURL"            //查询话单

//拨号相关配置
#define kDialModeType                   @"kDialModeType"                //用户设置的拨打方式
#define kDialModeSetup                  @"kDialModeSetup"               //用户设置的拨打模式（手动/自动）
#define kDialModelDirectFee             @"kDialModelDirectFee"          //直拨资费
#define kDialModelCallBackFee           @"kDialModelCallBackFee"        //回拨资费
#define kDialModelDirectRate            @"kDialModelDirectRate"
#define kDialModelCallBackRate          @"kDialModelCallBackRate"
#define kDialModelTips                  @"kDialModelTips"

#define kLoginBalance                   @"kLoginBalance"                //登录时用户余额



#define KLoginSuccess                   @"KLoginSuccess"                //登录成功，重新拉取通话记录
#define kDialSoundFlag                  @"kDialSoundFlag"               //键盘音是否打开

#define kSystemNoticeShowDate           @"kSystemNoticeShowDate"        //系统公告展示时间

#define kUserCallPhoneCount             @"kUserCallPhoneCount"          //保存用户通话次数

#define kUserLoginSuccess               @"kUserLoginSuccess"          //用户登陆成功
#endif
