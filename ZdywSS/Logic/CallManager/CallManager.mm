//
//  CallManager.m
//  CallManager
//
//  Created by mini1 on 13-6-14.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import "CallManager.h"
#import "VoGoEngine.h"
#import "TGo.h"

static CallManager *g_callManager = nil;
static void sp_callback_fun(int ev_type, int ev_state, const char* something, int code);

gl_media_engine::VoGoEngine      *g_pMediaEngine;     //媒体引擎

@interface CallManager()

//直拨错误码规整
- (NSString *)errMsgWithErrorCode:(int)errCode;

@end

@implementation CallManager
@synthesize platform = _platform, name = _name, version = _version;
@synthesize server_addr = _server_addr, userId = _userId, userPwd = _userPwd, userDisplay = _userDisplay, bRegisterFlag = _bRegisterFlag;
@synthesize callNumber;
@synthesize isCalling;
@synthesize ringFilePath = _ringFilepath;

//获取单例
+ (CallManager *)shareInstance
{
    @synchronized(self)
    {
        if (g_callManager == nil)
        {
            g_callManager = [[CallManager alloc] init];
        }
    }
    
    return g_callManager;
}

-(id)init
{
    self = [super init];
    
    if(self)
    {
        self.platform = nil;
        self.name = nil;
        self.version = nil;
        
        self.server_addr = nil;
        self.userId = nil;
        self.userPwd = nil;
        self.userDisplay = nil;
        self.bRegisterFlag = 1;
        
        self.isCalling = NO;
        
        g_pMediaEngine = NULL;
    }
    
    return self;
}

-(void)dealloc
{
    
    
    self.ringFilePath = nil;
    
}

/*
 函数描述：加载sp组件
 输入参数：N/A
 输出参数：N/A
 返 回 值：BOOL 是否加载成功
 作    者：刘斌
 */
- (BOOL)sp_start
{
    int ret = -1;
    
#if !(TARGET_IPHONE_SIMULATOR)
    g_pMediaEngine = new VoGoEngine;
    ret = TGo_load_media_engine(g_pMediaEngine);
    
    if(ret != 0)
    {
        NSLog(@"媒体引擎加载失败，请检查！");
        
        return NO;
    }
    
    //设置回调函数，加载sp组件
    ret = TGo_callback_register(sp_callback_fun);
    
    const char *u_platform = [self.platform UTF8String];
    const char *u_name = [self.name UTF8String];
    const char *u_version = [self.version UTF8String];
    
    ret = TGo_init(NULL,u_platform, u_name, u_version);
    
    NSString *ringFilePath = [[NSBundle mainBundle] pathForResource:@"CallDailling" ofType:@"mp3"];
    NSLog(@"ringFilePath:%@",ringFilePath);
    [self setRingFilePath:ringFilePath];
#endif
    
    return (ret == 0);
}

/*
 函数描述：开启关闭静音
 输入参数：bFlag  是否开启
 输出参数：N/A
 返 回 值：BOOL 是否设置成功
 作    者：刘斌
 */
- (BOOL)sp_set_mute:(BOOL)bFlag
{
    int ret = -1;
    
#if !(TARGET_IPHONE_SIMULATOR)
    ret = TGo_set_mic_mute(bFlag);
#endif
    
    return (ret == 0);
}

/*
 函数描述：设置是否开启免提
 输入参数：bFlag  是否开启
 输出参数：N/A
 返 回 值：BOOL 是否设置成功
 作    者：刘斌
 */
- (BOOL)sp_set_handsfree:(BOOL)bFlag
{
    _isLoudSpeak = bFlag;
    AudioSessionSetActive(true);
    UInt32 route;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    
    route = bFlag?kAudioSessionOverrideAudioRoute_Speaker:kAudioSessionOverrideAudioRoute_None;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(route), &route);
    return YES;
}

/*
 函数描述：注册登入函数
 输入参数：N/A
 输出参数：N/A
 返 回 值：BOOL 是否设置成功
 作    者：刘斌
 */
- (BOOL)sp_register_login
{
    int ret = -1;
    
#if !(TARGET_IPHONE_SIMULATOR)
    const char *server_addr = [self.server_addr UTF8String];
    const char *u_id = [self.userId UTF8String];
    const char *u_pwd = [self.userPwd UTF8String];
    const char *u_display = [self.userDisplay UTF8String];
    int flag = self.bRegisterFlag;
    
    NSLog(@"server_addr = %s, u_id = %s, u_pwd = %s, u_display = %s, flag = %d", server_addr, u_id, u_pwd, u_display, flag);
    
    ret = TGo_register(server_addr, u_id, u_pwd, u_display, flag);
#endif
    
    return (ret == 0);
}

/*
 函数描述：判断是否已经注册
 输入参数：N/A
 输出参数：N/A
 返 回 值：BOOL 是否注册
 作    者：刘斌
 */
- (BOOL)sp_is_registered
{
    BOOL bFlag = NO;
    
    int ret = -1;
    
#if !(TARGET_IPHONE_SIMULATOR)
    ret = TGo_get_register_state();
    
    if(eTGo_USTATE_REG_OK == ret)
    {
        bFlag = YES;
    }
#endif
    
    return bFlag;
}

/*
 函数描述：发起呼叫请求
 输入参数：strPhoneNum   呼叫的电话号码
 输出参数：N/A
 返 回 值：BOOL 是否操作成功
 作    者：刘斌
 */
- (BOOL)sp_call_phone:(NSString *)strPhoneNum
{
    if ([strPhoneNum length] == 0)
    {
        [self tcpDirectCallErrorWithNotifyName:kNotifyCallFailed
                                    reasonCode:-1
                                   description:@"号码格式错误"];
        return NO;
    }
    
    self.callNumber = strPhoneNum;
    
    if ([self sp_is_registered])
    {
        int ret = -1;
        
#if !(TARGET_IPHONE_SIMULATOR)
        [self performSelectorOnMainThread:@selector(openOrCloseRing:)
                               withObject:[NSNumber numberWithBool:YES]
                            waitUntilDone:YES];
        
        self.isCalling = YES;
        
        const char *phone_number = [strPhoneNum UTF8String];
        
        ret = TGo_request_call(phone_number);
#endif
        
        return (ret == 0);
    }
    else
    {
        BOOL ret = [self sp_register_login];
        if (ret)
        {
            self.isCalling = YES;
        }
        else
        {
            self.isCalling = NO;
            [self tcpDirectCallErrorWithNotifyName:kNotifyCallFailed
                                        reasonCode:-1
                                       description:@"呼叫失败"];
        }
        return ret;
    }
}

/*
 函数描述：终止会话
 输入参数：N/A
 输出参数：N/A
 返 回 值：BOOL 操作是否成功
 作    者：刘斌
 */
- (BOOL)sp_hangup_call
{
    self.isCalling = NO;
    int ret =-1;
    
#if !(TARGET_IPHONE_SIMULATOR)
    ret = TGo_hangup_call();
#endif
    
    return (ret == 0);
}

/*
 函数描述：发送DTMF
 输入参数：mDigit   dtmf字符
 输出参数：N/A
 返 回 值：BOOL 操作是否成功
 作    者：刘斌
 */
- (BOOL)sp_send_DTMF:(char)mDigit
{
    int ret = -1;
    
#if !(TARGET_IPHONE_SIMULATOR)
    ret = TGo_send_DTMF(mDigit);
#endif
    
    return (ret == 0);
}

/*
 函数描述：注销
 输入参数：N/A
 输出参数：N/A
 返 回 值：BOOL 操作是否成功
 作    者：刘斌
 */
- (BOOL)sp_unregister
{
    if ([self sp_is_registered])
    {
        int ret = -1;
        
#if !(TARGET_IPHONE_SIMULATOR)
        ret = TGo_unregister();
#endif
        
        return (ret == 0);
    }
    return YES;
}

/*
 函数描述：销毁sp组件
 输入参数：N/A
 输出参数：N/A
 返 回 值：BOOL 操作是否成功
 作    者：刘斌
 */
- (BOOL)sp_destory
{
    int ret = -1;
    
#if !(TARGET_IPHONE_SIMULATOR)
    ret = TGo_destroy();
    
    TGo_unload_media_engine();
    if(NULL != g_pMediaEngine)
    {
        delete g_pMediaEngine;
        g_pMediaEngine = NULL;
    }
#endif
    
    return (ret == 0);
}

/*
 函数描述：设置sp组件的log日志
 输入参数：level     日志等级
 logoPath   日志存放路径
 输出参数：N/A
 返 回 值：BOOL 操作是否成功
 作    者：刘斌
 */
- (BOOL)sp_set_logLevel:(int)level path:(NSString *)logpath
{
    int ret = -1;
#if !(TARGET_IPHONE_SIMULATOR)
    eTGo_TGo_TraceLevel fileLv = (eTGo_TGo_TraceLevel)level;
    ret = TGo_set_log_file(fileLv, [logpath UTF8String]);
#endif
    return (ret == 0);
}

//设置铃声文件路径
- (void)setRingFilePath:(NSString *)ringFilePath
{
    if (_ringFilepath)
    {
        _ringFilepath = nil;
    }
    
    _ringFilepath = ringFilePath;
    
    if (_audioPlayer)
    {
        if ([_audioPlayer isPlaying])
        {
            [_audioPlayer stop];
        }
        _audioPlayer = nil;
    }
    
    if (0 != _ringFilepath)
    {
        NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:ringFilePath];
        
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl
                                                              error:NULL];
        _audioPlayer.volume = 1.0;
        [_audioPlayer prepareToPlay];
        _audioPlayer.numberOfLoops = -1;
    }
}

//是否播放铃声
- (void)openOrCloseRing:(NSNumber *)isOpen
{
    if (_audioPlayer)
    {
        if ([isOpen boolValue])
        {
            _audioPlayer.volume = 1.0;
            _audioPlayer.numberOfLoops = -1;
            if (![_audioPlayer isPlaying])
            {
                [_audioPlayer play];
            }
        }
        else
        {
            if ([_audioPlayer isPlaying])
            {
                [_audioPlayer stop];
            }
        }
    }
}

//错误码规整
- (NSString *)errMsgWithErrorCode:(int)errCode
{
    switch (errCode)
    {
        case 480:
            return @"您拨的号码暂时未能接通，请稍后重新拨打。";
        case 408:
            return @"您拨的号码暂时未能接通，请稍后重新拨打。";
        case 403:
            return @"服务器拒绝，请稍后重新拨打。";
        case 404:
            return @"请检查被叫号码，请稍后重新拨打。";
        case 486:
            return @"您拨打的用户正忙，请稍后重新拨打。";
        case 500:
            return @"您拨打的号码未能接通，请稍后重新拨打。";
        case 503:
            return @"您拨打的号码未能接通，请稍后重新拨打。";
        case 603:
            return @"您拨打的号码未能接通，请稍后重新拨打。";
        case 402:
            return @"您当前账户余额不足.";
        case 487:
            return @"您已经取消了呼叫。";
        case 488:
            return @"您拨打的号码未能接通，请稍后重新拨打。";
        case 502:
            return @"您的账户已被冻结，请联系客服。";
        case 530:
            return @"您拨打的号码未能接通，请稍后重新拨打。";
        case 407:
            return @"您的账户或密码错误，请查证之后再拨。";
        default:
            return @"您拨打的号码未能接通，请稍后重新拨打。";
    }
}
//直拨错误统一处理
- (void)tcpDirectCallErrorWithNotifyName:(NSString *)ntfName reasonCode:(int)reason description:(NSString *)desc
{
    if (desc == nil || [desc length] == 0)
    {
        desc = [self errMsgWithErrorCode:reason];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ntfName
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [NSNumber numberWithInt:reason],@"reason",
                                                                desc,@"desc",
                                                                nil]];
}

@end

#pragma mark -
#pragma mark call back interface
void sp_callback_fun(int ev_type, int ev_state, const char* something, int code)
{
    @autoreleasepool {
    
        NSString *strDescription = [NSString stringWithCString: something encoding: NSUTF8StringEncoding];
        
        NSLog(@"event_type = %d, event_state = %d, strDescription = %@, reason = %d",
              ev_type,
              ev_state,
              strDescription,
              code);
        
        if(ev_type == eTGo_REGISTER_EV)       //注册
        {
            switch (code)
            {
                case eTGo_REG_OK_200:    //注册成功
                    break;
                    
                case eTGo_REG_ERR_403:   //账号或密码错误
                case eTGo_REG_ERR_408:   //注册超时
                case eTGo_REG_ERR_503:   //服务器异常
                {
                    [[CallManager shareInstance] tcpDirectCallErrorWithNotifyName:kNotifyCallRegisterFailed
                                                                       reasonCode:code
                                                                      description:@"注册失败"];
                }
                    break;
                    
                default:
                    break;
            }
        }
        else if(ev_type == eTGo_DIALCALL_EV)  //拨打
        {
            switch (code)
            {
                case eTGo_CALL_CONTECTING_183:   //正在接通
                    break;
                    
                case eTGo_CALL_RINGING_180:      //响铃中
                {
                    [[CallManager shareInstance] performSelectorOnMainThread:@selector(openOrCloseRing:)
                                                                  withObject:[NSNumber numberWithBool:NO]
                                                               waitUntilDone:YES];
                    [[CallManager shareInstance] tcpDirectCallErrorWithNotifyName:kNotifyCallRing
                                                                       reasonCode:code
                                                                      description:@"连接中..."];
                }
                    break;
                    
                case eTGo_CALL_CONNECTED_200:    //呼叫成功
                {
                    [[CallManager shareInstance] performSelectorOnMainThread:@selector(openOrCloseRing:)
                                                                  withObject:[NSNumber numberWithBool:NO]
                                                               waitUntilDone:YES];
                    [[CallManager shareInstance] tcpDirectCallErrorWithNotifyName:kNotifyCallConnect
                                                                       reasonCode:code
                                                                      description:@"通话建立"];
                }
                    break;
                    
                case eTGo_CALLER_NOBALANCE_402:  //余额不足
                case eTGo_CALLEE_FORBIDDEN_403:  //被叫号码被禁呼
                case eTGo_CALLER_PROXYAUTH_407:  //鉴权失败
                case eTGo_CALLEE_NOTFIND_404:    //被叫不在线
                case eTGo_CALLEE_NORESPONSE_408: //呼叫超时
                case eTGo_CALLEE_REJECT_480:     //被叫拒绝接听
                case eTGo_CALLEE_ISBUSY_486:     //对方忙
                case eTGo_CALLER_CANCEL_487:     //主动取消呼叫
                case eTGo_CALLER_NOTACCEP_488:   //服务不受理
                case eTGo_CALLER_FREEZE_502:     //账号冻结
                case eTGo_CALLER_EXPIRED_503:    //账号已过期
                case eTGo_CALLEE_DISABLED_530:   //服务器繁忙
                {
                    [[CallManager shareInstance] performSelectorOnMainThread:@selector(openOrCloseRing:)
                                                                  withObject:[NSNumber numberWithBool:NO]
                                                               waitUntilDone:YES];
                    [[CallManager shareInstance] tcpDirectCallErrorWithNotifyName:kNotifyCallFailed
                                                                       reasonCode:code
                                                                      description:nil];
                }
                    break;
                case eTGo_CALLEE_FORBIDDEN_405:
                {
                    [[CallManager shareInstance] performSelectorOnMainThread:@selector(openOrCloseRing:)
                                                                  withObject:[NSNumber numberWithBool:NO]
                                                               waitUntilDone:YES];
                    if ([strDescription rangeOfString:@"Need to bind phone"].location != NSNotFound)
                    {
                        strDescription = @"您超过体验拨打次数，请绑定手机再拨打";
                    }
                    [[CallManager shareInstance] tcpDirectCallErrorWithNotifyName:kNotifyCallFailed
                                                                       reasonCode:code
                                                                      description:strDescription];
                }
                    break;
                    
                default:
                {
                    [[CallManager shareInstance] performSelectorOnMainThread:@selector(openOrCloseRing:)
                                                                  withObject:[NSNumber numberWithBool:NO]
                                                               waitUntilDone:YES];
                    [[CallManager shareInstance] tcpDirectCallErrorWithNotifyName:kNotifyCallFailed
                                                                       reasonCode:code
                                                                      description:nil];
                }
                    break;
            }
        }
        else if(ev_type == eTGo_HANDUP_EV)    //挂断
        {
            switch (code)
            {
                case eTGo_CALL_HANDUP_BY_CALLER:     //主叫挂断
                    break;
                    
                case eTGo_CALL_HANDUP_BY_CALLEE:     //被叫挂断
                case eTGo_CALL_HANDUP_BY_RTPTIMEOUT: //RTP超时挂断
                case eTGo_CALL_HANDUP_BY_NOBALANCE:  //余额不足
                {
                    [[CallManager shareInstance] performSelectorOnMainThread:@selector(openOrCloseRing:)
                                                                  withObject:[NSNumber numberWithBool:NO]
                                                               waitUntilDone:YES];
                    [CallManager shareInstance].isCalling = NO;
                    [[CallManager shareInstance] tcpDirectCallErrorWithNotifyName:kNotifyCallFailed
                                                                       reasonCode:code
                                                                      description:nil];
                }
                    break;
                    
                default:
                    break;
            }
        }
        else if(ev_type == eTGo_UNREGISTER_EV)    //注销
        {
            
        }
    
    }
}
