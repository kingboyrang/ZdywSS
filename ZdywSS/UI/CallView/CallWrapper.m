//
//  CallWrapper.m
//  WldhClient
//
//  Created by zhouww on 13-8-3.
//  Copyright (c) 2013年 guoling. All rights reserved.
//

#import "CallWrapper.h"
#import "ZdywAppDelegate.h"
#import "CallInfoNode.h"
#import "ContactManager.h"
#import "DirectCallViewController.h"
#import "ZdywBaseNavigationViewController.h"
#import "SVProgressHUD.h"
#import "CallBackViewController.h"

#define CallBackTipView_Tag 102

static CallWrapper *g_callWrapper = nil;

@interface CallWrapper(){
    NSTimer                         *_backDismissTimer;     //回拨视图消失计时器
}

@property (nonatomic, strong) DirectCallViewController *directCallView;
@property (nonatomic, strong) UINavigationController   *navigation;
@property (nonatomic, strong) CallBackViewController   *callBackView;

@end

@implementation CallWrapper
@synthesize isCalling;

// 单实例
+ (CallWrapper *)shareCallWrapper
{
    if(g_callWrapper == nil)
    {
        g_callWrapper = [[CallWrapper alloc] init];
    }
    
    return g_callWrapper;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        
    }
    
    return self;
}

#pragma mark - handle call phone
//展示呼叫界面
- (void)showCallView
{
    self.isCalling = YES;
//    if (_directCallView)
//    {
//        _directCallView =nil;
//    }
    DirectCallViewController * directCallView = [[DirectCallViewController alloc] initWithNibName:NSStringFromClass([DirectCallViewController class]) bundle:nil];
    _navigation = [[UINavigationController alloc] initWithRootViewController:directCallView];
    [[ZdywAppDelegate appDelegate].window addSubview:_navigation.view];
    [directCallView startCall:self.myCallInfoNode];
}

- (void)showCallBackView{
    self.isCalling = YES;
    _callBackView = [[CallBackViewController alloc] initWithNibName:NSStringFromClass([CallBackViewController class]) bundle:nil];
    _navigation = [[UINavigationController alloc] initWithRootViewController:_callBackView];
    [[ZdywAppDelegate appDelegate].window addSubview:_navigation.view];
    [_callBackView startCall:self.myCallInfoNode];
}

//弹出手动设置拨号方式弹出框
- (void)showSetUpCallModel
{
    UIActionSheet *acSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                         delegate:self
                                                cancelButtonTitle:@"取消"
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:@"回拨",
                              @"直拨",nil];
    [acSheet showInView:[ZdywAppDelegate appDelegate].window];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        switch (buttonIndex)
        {
            case ZdywCallBackType: {//回拨
                self.myCallInfoNode.calltype = ZdywCallBackType;
                [self showCallBackView];
            }
                break;
            case ZdywDirectCallType:{//直拨
                self.myCallInfoNode.calltype = ZdywDirectCallType;
                [self performSelectorOnMainThread:@selector(showCallView) withObject:nil waitUntilDone:YES];
            }
                break;
            default:{
                self.myCallInfoNode.calltype = ZdywDirectCallType;
                [self performSelectorOnMainThread:@selector(showCallView) withObject:nil waitUntilDone:YES];
            }
                break;
        }
    }
}

//处理电话号码区号
//处理电话号码，判断是否加上区号
- (NSString *)dealZoneWithPhoneNumbe:(NSString *)phoneNum
{
    NSString *resutlNumber = [NSString stringWithFormat:@"%@",phoneNum];
    if ([ZdywUtils getLocalDataBoolen:kIsChinaAcount])
    {
        //如果不是手机号 第一位是非零 = 座机
        BOOL isMobile = [ZdywUtils isMobileNumber:phoneNum];
        if(!isMobile)
        {
            int h = [[phoneNum substringWithRange:NSMakeRange(0,1)] intValue];
            if (h != 0)
            {
                NSString *userID = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserID];
                NSString *aKey = [NSString stringWithFormat:@"%@_%@",
                                  userID,
                                  kUserDefaultZone];
                NSString *defaultZone = [ZdywUtils getLocalStringDataValue:aKey];
                if ([defaultZone length] > 0)
                {
                    resutlNumber = [NSString stringWithFormat:@"%@%@", defaultZone, phoneNum];
                }
            }
        }
    }
    return resutlNumber;
}

// 发起呼叫
- (void)initiatingCall:(CallInfoNode *)callInfoNode
{
    //判断当前是否有网络
    PhoneNetType currentNetType = [ZdywUtils getCurrentPhoneNetType];
    
    if(currentNetType == PNT_UNKNOWN)
    {
        NSString *strMessage=[NSString stringWithFormat:@"您当前网络不支持%@拨打，请检查网络",[ZdywCommonFun getAppConfigureInfoWithKey:kZdywDataKeyDisplayName]];
        //NSString *strMessage = @"您当前网络不支持说说拨打，请检查网络";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                             message:strMessage
                                                            delegate:self
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:@"确定", nil] ;
        [alertView show];
        return;
    }
    
    self.myCallInfoNode = callInfoNode;
    
    //获取呼叫方式
    int dialModel = [[ZdywUtils getLocalIdDataValue:kDialModeType] intValue];
    NSString *callBackTipStr = nil;
    if (ZdywDialModeManual != dialModel)
    {
        switch (dialModel)
        {
            case ZdywDialModeCallBack: {//回拨
                self.myCallInfoNode.calltype = ZdywCallBackType;
                callBackTipStr = @"现在处于回拨模式，您将收到一个系统来电，请放心接听";
            }
                break;
             //直拨 ss不存在直拨此种情况 只有回拨和智能拨打两种
            case ZdywDialModeDirect:
                self.myCallInfoNode.calltype = ZdywDirectCallType;
                break;
            case ZdywDialModeSmart: //智能拨打
            {
                //获取网络状态
                PhoneNetType currentNetType = [ZdywUtils getCurrentPhoneNetType];
                if (currentNetType == PNT_WIFI)
                {
                    self.myCallInfoNode.calltype = ZdywDirectCallType;
                }
                else if (currentNetType == PNT_2G3G)
                {
                    self.myCallInfoNode.calltype = ZdywCallBackType;
                    callBackTipStr = @"系统已自动为您匹配回拨模式，您将收到一个系统来电，请放心接听";
                }
                else
                {
                    self.myCallInfoNode.calltype = ZdywCallBackType;
                    callBackTipStr = @"系统已自动为您匹配回拨模式，您将收到一个系统来电，请放心接听";
                }
            }
                break;
            default:
                self.myCallInfoNode.calltype = ZdywCallNoneType;
                break;
        }
    }
    else
    {
        self.myCallInfoNode.calltype = ZdywCallNoneType;
    }
    
    
    if (self.myCallInfoNode.calltype == ZdywCallNoneType)
    {
        [self performSelectorOnMainThread:@selector(showSetUpCallModel) withObject:nil waitUntilDone:YES];
    }
    else
    {
        if (self.myCallInfoNode.calltype == ZdywDirectCallType) {
            //show呼叫界面
            [self showCallView];
        } else {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kCallBackIsTip] != YES) {
                NSString *callBackCount = [[NSUserDefaults standardUserDefaults] objectForKey:kCallBackCount];
                if (callBackCount == nil) {
                    callBackCount = @"1";
                    [[NSUserDefaults standardUserDefaults] setObject:callBackCount forKey:kCallBackCount];
                    [self showTipview:callBackTipStr];
                } else {
                    NSInteger count = [callBackCount integerValue];
                    if (count < 3) {
                        count = count+1;
                        callBackCount = [NSString stringWithFormat:@"%d",count];
                        [[NSUserDefaults standardUserDefaults] setObject:callBackCount forKey:kCallBackCount];
                        [self showTipview:callBackTipStr];
                    } else {
                        [self showCallBackView];
                    }
                }
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                [self showCallBackView];
            }
        }
    }
}

- (void)showTipview:(NSString*)resultStr{
    CustomPointView *tipView = [[CustomPointView alloc]initWithFrame:[[ZdywAppDelegate appDelegate].window frame]];
    [tipView setTag:CallBackTipView_Tag];
    [tipView setDelegate:self];
    [tipView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8]];
    tipView.tipLable.text = resultStr;
    [tipView.tipLable sizeToFit];
    tipView.tipTitle.text = @"回拨提示";
    [tipView.backButton setTitle:@"我知道了" forState:UIControlStateNormal];
    [tipView.backButton setTitleColor:[UIColor colorWithRed:5.0/255 green:146.0/255 blue:215.0/255 alpha:1.0] forState:UIControlStateNormal];
    [tipView.backButton setBackgroundColor:[UIColor whiteColor]];
    [[ZdywAppDelegate appDelegate].window addSubview:tipView];
}

#pragma mark - CustomPointViewDelegate

- (void)dismissCustomPointView{
    [self showCallBackView];
}

@end
