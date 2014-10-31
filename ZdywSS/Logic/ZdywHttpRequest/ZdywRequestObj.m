//
//  ZdywRequestObj.m
//  ZdywMini
//
//  Created by mini1 on 14-5-29.
//  Copyright (c) 2014年 Guoling. All rights reserved.
//

#import "ZdywRequestObj.h"
#import "Zdyw_md5.h"
#import "JSONKit.h"

@implementation ZdywRequestObj
@synthesize requestUserInfo;
@synthesize requestKey;
@synthesize requestHandle;
@synthesize reqServiceType;
@synthesize delegate;

- (void)dealloc
{
    self.delegate = nil;
    if (self.requestHandle)
    {
        [self.requestHandle clearDelegatesAndCancel];
    }
    self.requestHandle = nil;
    self.requestKey = nil;
    self.requestUserInfo = nil;
}

- (void)requestService:(ZdywServiceType)serviceType
              userInfo:(NSDictionary *)reqUserInfo
              postDict:(NSDictionary *)postDict
                   key:(NSString *)reqKey
              delegate:(id<ZdywRequestDelegate>)reqDelegate
{
    self.requestKey = reqKey;
    self.requestUserInfo = reqUserInfo;
    self.reqServiceType = serviceType;
    self.delegate = reqDelegate;
    [self startPostRequestWithPostDict:postDict];
}

//开始get请求
- (void)startGetRequest
{
    NSString *strURL = nil;
    if (self.reqServiceType == ZdywServicepullmsg)
    {
        NSString *brandID = [ZdywUtils getLocalStringDataValue:kZdywDataKeyBrandID];
        NSString *uid = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserID];
        strURL = [NSString stringWithFormat:@"http://117.121.21.84:9001/apnsproxy/pull_msg?brand_id=%@&uid=%@",brandID,uid];
        NSURL *url = [NSURL URLWithString:strURL];
        self.requestHandle = [ASIHTTPRequest requestWithURL:url];
        [self.requestHandle setShouldAttemptPersistentConnection:NO];
        [self.requestHandle setTimeOutSeconds:30];
        [self.requestHandle setDelegate:self];
        [self.requestHandle startAsynchronous];
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ZdywRequestFailed:error:)])
        {
            [self.delegate ZdywRequestFailed:self error:[NSError errorWithDomain:@"不存在该业务"
                                                                            code:-999
                                                                        userInfo:self.requestUserInfo]];
        }
    }
}

//开始post请求
- (void)startPostRequestWithPostDict:(NSDictionary *)postDict
{
    NSString *serverAddres = [ZdywUtils getLocalStringDataValue:kZdywDataKeyServerAddress];
    NSString *brandId = [ZdywUtils getLocalStringDataValue:kZdywDataKeyBrandID];

    NSString *baseUrl = [NSString stringWithFormat:@"%@/%@/%@",
                         serverAddres,
                         kAGWVersion,
                         brandId];
    NSString *strUrl = nil;
    
    switch (self.reqServiceType)
    {
        case ZdywServiceRegister:          //注册
            strUrl = [NSString stringWithFormat:@"%@/account/nobind_reg", baseUrl];
            break;
        case ZdywServiceBindNewPhone:      //绑定
            strUrl = [NSString stringWithFormat:@"%@/user/bind_phone", baseUrl];
            break;
        case ZdywServiceChangedPhone:{     //发起绑定手机请求
            strUrl = [NSString stringWithFormat:@"%@/user/bind_req", baseUrl];
            break;
        }
        case CPCActiveType:             //渠道
            strUrl = [NSString stringWithFormat:@"%@/statistic/cpc", baseUrl];
            break;
        case RecordInstallNumberType:   //安装量
            strUrl = [NSString stringWithFormat:@"%@/statistic/install", baseUrl];
            break;
        case ZdywServiceLogin:      //登录
            strUrl = [NSString stringWithFormat:@"%@/account/nobind_login", baseUrl];
            NSLog(@"登陆url=%@",strUrl);
            break;
        case ZdywServiceContactBackUpType:  //通讯录备份
            strUrl = [NSString stringWithFormat:@"%@/contacts/backup",baseUrl];
            break;
        case ZdywServiceContactRecoveryType:             //联系人恢复
            strUrl = [NSString stringWithFormat:@"%@/contacts/down",baseUrl];
            break;
        case ZdywServiceContactBackUpInfoType:            //联系人备份信息
            strUrl = [NSString stringWithFormat:@"%@/contacts/info",baseUrl];
            break;
        case ZdywServiceDefaultConfigType:              //拉取静态配置
            strUrl = [NSString stringWithFormat:@"%@/config/app",baseUrl];
            break;
        case ZdywServiceTemplateConfigType:              //获取模板配置
            strUrl = [NSString stringWithFormat:@"%@/config/tpl",baseUrl];
            break;
        case ZdywServiceSysMessage:                     //获取系统公告
            strUrl = [NSString stringWithFormat:@"%@/config/sysmsg",baseUrl];
            break;

        case ZdywServiceRegisterGetCode:             //新注册，获取验证码
        {
            strUrl = [NSString stringWithFormat:@"%@/account/reg_validate", baseUrl];
        }
            break;
        case ZdywServiceResetPwdSubmit:
        {
            strUrl = [NSString stringWithFormat:@"%@/user/change_pwd", baseUrl];
        }
            break;
        case ZdywServiceGetGoodsCgfType:                    //拉取商品列表
        {
            strUrl = [NSString stringWithFormat:@"%@/config/goods", baseUrl];
        }
            break;
        case ZdywServiceUserInfoType:{                      //用户信息
            strUrl = [NSString stringWithFormat:@"%@/user/info", baseUrl];
        }
            break;
        case ZdywServiceBackCall:                           //回拨请求
        {
            strUrl = [NSString stringWithFormat:@"%@/call", baseUrl];
        }
            break;
        case ZdywServiceFindPwdType:{                       //手机找回密码
            strUrl = [NSString stringWithFormat:@"%@/user/find_pwd", baseUrl];
        }
            break;
        case ZdywServiceSearchBalance:{                       //查询余额
            strUrl = [NSString stringWithFormat:@"%@/user/wallet", baseUrl];
        }
            break;
        case ZdywServiceFeedback:{
            strUrl = [NSString stringWithFormat:@"%@/statistic/feedback",baseUrl];
        }
            break;
        case ZdywServiceRecharge:{
            strUrl = [NSString stringWithFormat:@"%@/order/pay", baseUrl];
        }
            break;
        case ZdywServiceTokenReportType:{
            strUrl = [NSString stringWithFormat:@"%@/statistic/token", baseUrl];
        }
            break;
        case ZdywServicepullmsg:{
            strUrl = [NSString stringWithFormat:@"%@/statistic/pull_msg", baseUrl];
        }
            break;
        case ZdywServicePushFeedback:{
            strUrl = [NSString stringWithFormat:@"%@/client_feedback", baseUrl];
        }
            break;
        case ZdywServiceUpdateInfo:{
            strUrl = [NSString stringWithFormat:@"%@/config/update",baseUrl];
        }
            break;
        case ZdywServiceQueryIsRegister:    // 查询是否注册过
        {
            strUrl = [NSString stringWithFormat:@"%@/user/query_user",baseUrl];
        }
            break;
        case ZdywServicePaycardReg:         // 卡密注册（伪绑定）
        {
            strUrl = [NSString stringWithFormat:@"%@/account/nobind_paycard_reg",baseUrl];
        }
            break;
        case ZdywServiceGetVeriftyCode:     // 获取验证码
        {
            strUrl = [NSString stringWithFormat:@"%@/user/reset_pwd_apply",baseUrl];
        }
            break;
        case ZdywServiceCheckVeriftyCode:     // 校验验证码
        {
            strUrl = [NSString stringWithFormat:@"%@/user/reset_pwd_check",baseUrl];
        }
            break;
            
        case ZdywServiceResetPSW:     // 确认重置密码
        {
            strUrl = [NSString stringWithFormat:@"%@/user/reset_pwd",baseUrl];
        }
        break;
        default:
            break;
    }
    
    if (0 != [strUrl length])
    {
        NSData *postData = nil;
        
        postData = [self createPostData:postDict];
//        NSMutableString *str = strUrl;
//        NSString * postUrl = [[NSString alloc] initWithData:postData  encoding:NSUTF8StringEncoding];
//        NSString *str1 = [NSString stringWithFormat:@"%@?%@",str,postUrl];
//        NSLog(@"%@",str1);
        NSURL *url = [NSURL URLWithString:strUrl];
        NSLog(@"request (%d) url : %@",self.reqServiceType,url);
        self.requestHandle = [ASIHTTPRequest requestWithURL:url];
        [self.requestHandle appendPostData:postData];
        NSLog(@"request (%d) url : %@",self.reqServiceType,url);
        [self.requestHandle setRequestMethod:@"POST"];
        [self.requestHandle addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
        [self.requestHandle addRequestHeader:@"Content-Length" value:postLength];
        [self.requestHandle setTimeOutSeconds:30];
        self.requestHandle.delegate = self;
        [self.requestHandle startAsynchronous];
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ZdywRequestFailed:error:)])
        {
            [self.delegate ZdywRequestFailed:self error:[NSError errorWithDomain:@"不存在该业务"
                                                                            code:-999
                                                                        userInfo:self.requestUserInfo]];
        }
    }
}

//创建post数据
- (NSData *)createPostData:(NSDictionary *)postDict
{
    NSInteger signType = 0; //signType 1为uid签名 0为普通签名
    NSString *userID = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserID];
    NSString *userPwd = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPwd];
    
    if ([userID length] > 0 && [userPwd length] > 0)
    {
        signType = 1;
    }
    
    if (self.reqServiceType == ZdywServiceLogin)
    {
        signType = 0;
    }
    
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSString *strPhoneType = [ZdywUtils getLocalStringDataValue:kZdywDataKeyPlateVersion];   //pv
    if([strPhoneType length] > 0)
    {
        [tempDic setObject:strPhoneType forKey:@"pv"];
    }
    
    NSString *strVersion = [ZdywUtils getLocalStringDataValue:kZdywDataKeyVersion];       //version
    if([strVersion length] > 0)
    {
        [tempDic setObject:strVersion forKey:@"v"];
    }
    
    //获取unix时间戳
    NSDate *localDate = [NSDate date];
    NSString *strTimestamp = [NSString stringWithFormat:@"%ld", (long)[localDate timeIntervalSince1970]];
    if([strTimestamp length] > 0)
    {
        [tempDic setObject:strTimestamp forKey:@"ts"];
    }
    
    //获取随机数
    int i = abs(arc4random())%100000;
    NSString *strNonce = [NSString stringWithFormat:@"%@%d", strTimestamp, i];
    if([strNonce length] > 0)
    {
        [tempDic setObject:strNonce forKey:@"nonce"];
    }
    
    //获取渠道id
    NSString *strInvitedby = [ZdywUtils getLocalStringDataValue:kZdywDataKeyInviteNum];    //invitedby
    if([strInvitedby length] > 0)
    {
        [tempDic setObject:strInvitedby forKey:@"invitedby"];
    }
    
    //获取渠道类型
    NSString *strInvitedway = [ZdywUtils getLocalStringDataValue:kZdywDataKeyInviteWay];     //inbitedway
    if([strInvitedway length] > 0)
    {
        [tempDic setObject:strInvitedway forKey:@"invitedway"];
    }
    
    //获取认证签名方式
    NSString *strAuthType = @"key";
    if(signType == 1)
    {
        strAuthType = @"uid";
    }
    [tempDic setObject:strAuthType forKey:@"auth_type"];
    
    //获取data数据
    NSString *strData = [postDict objectForKey:kAGWDataString];
    if([strData length] > 0)
    {
        [tempDic setObject:strData forKey:@"data"];
        
        NSString *aStr = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                            (CFStringRef)strData,
                                                                            NULL,
                                                                            CFSTR(":/?#[]@!$&’()*+,;="),
                                                                            kCFStringEncodingUTF8));
        strData = [NSString stringWithFormat:@"%@",aStr];
    }
    else
    {
        strData = @"";
    }
    
    if([userID length] > 0)
    {
        [tempDic setObject:userID forKey:@"uid"];
    }
    
    NSString *strSign = nil;
    if(signType == 1)
    {
        strSign = [ZdywUtils getWldhUrlUidSign:tempDic
                                         agwAn:[ZdywUtils getLocalStringDataValue:kAGWAnType]
                                         agnKn:[ZdywUtils getLocalStringDataValue:kAGWKnType]
                                         agwTK:[ZdywUtils getLocalStringDataValue:kAGWTkType]
                                           pwd:userPwd];
    }
    else
    {
        strSign = [ZdywUtils getWldhUrlKeySign:tempDic
                                         agwAn:[ZdywUtils getLocalStringDataValue:kAGWAnType]
                                         agnKn:[ZdywUtils getLocalStringDataValue:kAGWKnType]
                                         agwTK:[ZdywUtils getLocalStringDataValue:kAGWTkType]];
    }
    
    NSString *post = [NSString stringWithFormat:@"pv=%@&v=%@&ts=%@&nonce=%@&invitedby=%@&invitedway=%@&sign=%@&auth_type=%@&data=%@&uid=%@",
                      strPhoneType,
                      strVersion,
                      strTimestamp,
                      strNonce,
                      strInvitedby,
                      strInvitedway,
                      strSign,
                      strAuthType,
                      strData,
                      userID];
    NSLog(@"post = %@", post);
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    
    return postData;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    
    JSONDecoder *jsonDecode = [[JSONDecoder alloc] init];
    NSDictionary *resultDict = [jsonDecode objectWithData:responseData];
    
//    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:responseData];
//    NSDictionary *myDictionary = [unarchiver decodeObjectForKey:@"Some"];
    NSLog(@"request (%d) finished : %@",self.reqServiceType,resultDict);
    
    if (resultDict == nil || [resultDict count] == 0)
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(ZdywRequestFailed:error:)])
        {
            [self.delegate ZdywRequestFailed:self error:[NSError errorWithDomain:@"返回数据为空"
                                                                            code:-999
                                                                        userInfo:self.requestUserInfo]];
        }
    }
    else
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(ZdywRequestFinished:resultDict:)])
        {
            [self.delegate ZdywRequestFinished:self resultDict:resultDict];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"request (%d) failed : %@",
          self.reqServiceType,
          [request error]);
    if(self.delegate && [self.delegate respondsToSelector:@selector(ZdywRequestFailed:error:)])
    {
        [self.delegate ZdywRequestFailed:self error:[request error]];
    }
}

/*
 功能：取消网络请求
 输入参数：无
 */
- (void)stopRequest
{
    [requestHandle cancel];
    [requestHandle clearDelegatesAndCancel];
}

@end
