//
//  CallManager.h
//  CallManager
//
//  Created by mini1 on 13-6-14.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define kNotifyCallRegisterFailed     @"callRegisterFailed"    //sip注册失败
#define kNotifyCallRing               @"callRing"             //响铃中
#define kNotifyCallConnect            @"callConnect"          //通话建立
#define kNotifyCallFailed             @"callFailed"           //通话失败

@interface CallManager : NSObject
{
    NSString                            *_platform;         //平台
    NSString                            *_name;             //品牌
    NSString                            *_version;          //版本号
    
    NSString                            *_server_addr;      //服务器地址
    NSString                            *_userId;           //用户名
    NSString                            *_userPwd;          //密码
    NSString                            *_userDisplay;      //用户昵称
    int                                 _bRegisterFlag;     //注册登入执行标志
    
    BOOL                                _isLoudSpeak;       //扬声器是否开启了
    AVAudioPlayer                       *_audioPlayer;      //铃声播放器
    NSString                            *_ringFilepath;     //铃声路径
}

@property(copy)NSString *platform;
@property(copy)NSString *name;
@property(copy)NSString *version;

@property(copy)NSString *server_addr;
@property(copy)NSString *userId;
@property(copy)NSString *userPwd;
@property(copy)NSString *userDisplay;
@property(assign)int bRegisterFlag;

@property(nonatomic,assign) BOOL       isCalling;      //是否正在通话
@property(nonatomic,strong) NSString   *callNumber;     //呼叫的号码
@property(nonatomic,strong) NSString   *ringFilePath;   //铃声文件路径

//获取单例
+ (CallManager *)shareInstance;

/*
 函数描述：加载sp组件
 输入参数：N/A
 输出参数：N/A
 返 回 值：BOOL 是否加载成功
 作    者：刘斌
 */
- (BOOL)sp_start;

/*
 函数描述：开启关闭静音
 输入参数：bFlag  是否开启
 输出参数：N/A
 返 回 值：BOOL 是否设置成功
 作    者：刘斌
 */
- (BOOL)sp_set_mute:(BOOL)bFlag;

/*
 函数描述：设置是否开启免提
 输入参数：bFlag  是否开启
 输出参数：N/A
 返 回 值：BOOL 是否设置成功
 作    者：刘斌
 */
- (BOOL)sp_set_handsfree:(BOOL)bFlag;

/*
 函数描述：注册登入函数
 输入参数：N/A
 输出参数：N/A
 返 回 值：BOOL 是否设置成功
 作    者：刘斌
 */
- (BOOL)sp_register_login;

/*
 函数描述：判断是否已经注册
 输入参数：N/A
 输出参数：N/A
 返 回 值：BOOL 是否注册
 作    者：刘斌
 */
- (BOOL)sp_is_registered;

/*
 函数描述：发起呼叫请求
 输入参数：strPhoneNum   呼叫的电话号码
 输出参数：N/A
 返 回 值：BOOL 是否操作成功
 作    者：刘斌
 */
- (BOOL)sp_call_phone:(NSString *)strPhoneNum;

/*
 函数描述：终止会话
 输入参数：N/A
 输出参数：N/A
 返 回 值：BOOL 操作是否成功
 作    者：刘斌
 */
- (BOOL)sp_hangup_call;

/*
 函数描述：发送DTMF
 输入参数：mDigit   dtmf字符
 输出参数：N/A
 返 回 值：BOOL 操作是否成功
 作    者：刘斌
 */
- (BOOL)sp_send_DTMF:(char)mDigit;

/*
 函数描述：注销
 输入参数：N/A
 输出参数：N/A
 返 回 值：BOOL 操作是否成功
 作    者：刘斌
 */
- (BOOL)sp_unregister;

/*
 函数描述：销毁sp组件
 输入参数：N/A
 输出参数：N/A
 返 回 值：BOOL 操作是否成功
 作    者：刘斌
 */
- (BOOL)sp_destory;

/*
 函数描述：设置sp组件的log日志
 输入参数：level     日志等级
 logoPath   日志存放路径
 输出参数：N/A
 返 回 值：BOOL 操作是否成功
 作    者：刘斌
 */
- (BOOL)sp_set_logLevel:(int)level path:(NSString *)logpath;

//是否播放铃声
- (void)openOrCloseRing:(NSNumber *)isOpen;

//直拨错误统一处理
- (void)tcpDirectCallErrorWithNotifyName:(NSString *)ntfName reasonCode:(int)reason description:(NSString *)desc;

@end
