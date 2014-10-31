//
//  RechargeViewController.m
//  ZdywXY
//
//  Created by zhongduan on 14-8-4.
//  Copyright (c) 2014年 zhongduan. All rights reserved.
//

#import "RechargeViewController.h"
#import "ZdywUtils.h"
#import "UIImage+Scale.h"
#import "ContactManager.h"
@interface RechargeViewController ()

@end

@implementation RechargeViewController

#pragma mark - liftCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self InitMainView];
    [self addObservers];
    [_jumpNextStepBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyZdywFontColor] forState:UIControlStateNormal];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.title = @"注册";
    [self performSelector:@selector(changeStatusBarStyle) withObject:nil afterDelay:0.1];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    [self removeObservers];
}

#pragma mark - observers
- (void)changeStatusBarStyle
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)addObservers
{

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePayCardResult:)
                                                 name:kNotificationPayCardReg
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePhoneRegResult:)
                                                 name:kNotificationPhoneRegisterFinish
                                               object:nil];

    
    
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationPayCardReg object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationPhoneRegisterFinish object:nil];
    
}

#pragma mark - HttpReceiveData

//手机+卡密直接注册
- (void)receivePayCardResult:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSLog(@"%@",userInfo);
    id result = [userInfo objectForKey:@"result"];
    NSString *strReason = [userInfo objectForKey:@"reason"];

    if ([result integerValue] == 0) // 注册成功
    {
        [ZdywUtils setLocalDataString:@"+86" key:kCurrentCountryCode];
        [ZdywUtils setLocalDataString:@"中国" key:kCurrentCountryName];
        [ZdywUtils setLocalDataBoolen:YES key:kIsChinaAcount];
        
        NSString *balance = [userInfo objectForKey:@"basicbalance"];
        if ([balance length])
        {
            balance = [userInfo objectForKey:@"balance"];
        }
        NSString *firstFlag = [userInfo objectForKey:@"first"];
        if(firstFlag)
        {
            [ZdywUtils setLocalDataString:firstFlag key:kNewAccountFirstLoginFlag];
        }
        [ZdywUtils setLocalDataString:balance key:kLoginBalance];

        
       NSString *publicKey=[ZdywCommonFun getAppConfigureInfoWithKey:kZdywDataKeyServerKey];
        NSString *userID = [userInfo objectForKey:@"uid"];
        NSString *userPSW =[userInfo objectForKey:@"password"];
        NSString* pwdStr = [Zdyw_rc4 RC4Decrypt:userPSW withKey:publicKey];
         // 服务器返回的密码是RC4加密的 所以要先用RC4解密再保存到本地
        [ZdywUtils setLocalDataString:userID key:kZdywDataKeyUserID];
        [ZdywUtils setLocalDataString:pwdStr key:kZdywDataKeyUserPwd];
        int DialModeType=[[ZdywCommonFun getAppConfigureInfoWithKey:kZdywDataKeyDialModelType] intValue];
        [ZdywUtils setLocalIdDataValue:[NSNumber numberWithInt:DialModeType]
                                   key:kDialModeType];// 设置默认拨打方式为回拨
        [[ContactManager shareInstance] createUserDataBaseWithUserID:userID];
        NSString *userPhone = [userInfo objectForKey:@"mobile"];
        if ([userPhone length])
        {
            [ZdywUtils setLocalDataString:userPhone key:kZdywDataKeyUserPhone];
        }
        else
        {
            [ZdywUtils setLocalDataString:_phoneNo.text key:kZdywDataKeyUserPhone];
        }
        [[ZdywAppDelegate appDelegate] afterClientActived];//重新拉取配置信息
        NSString * alertMsg = [NSString stringWithFormat:@"为了保证您的正常拨打，在您前三次拨打后,系统将提示您验证手机号.现在就去使用%@电话吧!",[ZdywCommonFun getAppConfigureInfoWithKey:kZdywDataKeyDisplayName]];
        UIAlertView *AlertView = [[UIAlertView alloc] initWithTitle:@"注册充值成功"
                                                            message:alertMsg
                                                           delegate:self
                                                  cancelButtonTitle:@"确认"
                                                  otherButtonTitles:nil, nil];
        AlertView.tag = 1003;
       [AlertView show];

    }
    else // 注册失败
    {
        [SVProgressHUD showInView:self.navigationController.view
                           status:@""
                 networkIndicator:NO
                             posY:-1
                         maskType:SVProgressHUDMaskTypeClear];
        [SVProgressHUD dismissWithError:strReason afterDelay:2];
    }
}

// 无卡手机直接注册
- (void)receivePhoneRegResult:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSLog(@"%@",userInfo);
    id result = [userInfo objectForKey:@"result"];
    NSString *strReason = [userInfo objectForKey:@"reason"];
    
    if ([result integerValue] == 0) //
    {
        [ZdywUtils setLocalDataString:@"+86" key:kCurrentCountryCode];
        [ZdywUtils setLocalDataString:@"中国" key:kCurrentCountryName];
        [ZdywUtils setLocalDataBoolen:YES key:kIsChinaAcount];
        
        NSString *balance = [userInfo objectForKey:@"basicbalance"];
        if ([balance length])
        {
            balance = [userInfo objectForKey:@"balance"];
        }
        NSString *firstFlag = [userInfo objectForKey:@"first"];
        if(firstFlag)
        {
            [ZdywUtils setLocalDataString:firstFlag key:kNewAccountFirstLoginFlag];
        }
        [ZdywUtils setLocalDataString:balance key:kLoginBalance];

        NSString *publicKey=[ZdywCommonFun getAppConfigureInfoWithKey:kZdywDataKeyServerKey];
        NSString *userID = [userInfo objectForKey:@"uid"];
        NSString *userPSW =[userInfo objectForKey:@"password"];
        // 服务器返回的密码是RC4加密的 所以要先用RC4解密再保存到本地
        NSString* pwdStr = [Zdyw_rc4 RC4Decrypt:userPSW withKey:publicKey];
        [ZdywUtils setLocalDataString:userID key:kZdywDataKeyUserID];
        [ZdywUtils setLocalDataString:pwdStr key:kZdywDataKeyUserPwd];
        int DialModeType=[[ZdywCommonFun getAppConfigureInfoWithKey:kZdywDataKeyDialModelType] intValue];
        [ZdywUtils setLocalIdDataValue:[NSNumber numberWithInt:DialModeType]
                                   key:kDialModeType];// 设置默认拨打方式为回拨
        [[ContactManager shareInstance] createUserDataBaseWithUserID:userID];
        //[ZdywUtils setLocalDataString:_phoneNo.text key:kZdywDataKeyUserPhone];
        NSString *userPhone = [userInfo objectForKey:@"mobile"];
        if ([userPhone length])
        {
            [ZdywUtils setLocalDataString:userPhone key:kZdywDataKeyUserPhone];
        }
        else
        {
            [ZdywUtils setLocalDataString:_phoneNo.text key:kZdywDataKeyUserPhone];
        }        
        [SVProgressHUD showInView:self.navigationController.view
                           status:@""
                 networkIndicator:NO
                             posY:-1
                         maskType:SVProgressHUDMaskTypeClear];
        [[ZdywAppDelegate appDelegate] afterClientActived];//重新拉取配置信息
        
        
        
        NSString *strData = @"account=%@&passwd=%@&ptype=%@&netmode=%@";
        NSString *passwordStr = [[Zdyw_md5 shareUtility] md5:pwdStr];
        [SVProgressHUD showInView:self.navigationController.view
                           status:@"正在登录..."
                 networkIndicator:NO
                             posY:-1
                         maskType:SVProgressHUDMaskTypeClear];
        //获取ptype(手机型号)
        NSString *strPType = [ZdywUtils getPlatformInfo];
        //获取netmode(网络类型)
        NSString *strNetMode = [ZdywUtils getCurrentPhoneNetMode];
        NSString *iphoneNo  = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPhone];
        strData = [NSString stringWithFormat:strData,iphoneNo, passwordStr, strPType, strNetMode];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
        [dic setObject:strData forKey:kAGWDataString];
        [[ZdywServiceManager shareInstance]requestService:ZdywServiceLogin
                                                 userInfo:nil
                                                 postDict:dic];

        
        
        [SVProgressHUD dismissWithSuccess:[NSString stringWithFormat:@"欢迎使用%@!",[ZdywCommonFun getAppConfigureInfoWithKey:kZdywDataKeyDisplayName]] afterDelay:2];
        [self performSelector:@selector(enterMainViewController) withObject:nil afterDelay:2];

   }
    else // 注册失败
    {
        [SVProgressHUD showInView:self.navigationController.view
                           status:@""
                 networkIndicator:NO
                             posY:-1
                         maskType:SVProgressHUDMaskTypeClear];
        [SVProgressHUD dismissWithError:strReason afterDelay:2];
    }
}

#pragma mark  -PrivateMethod
- (void)InitMainView
{
    
    _rechargeNoTextFieldBg.layer.borderColor = [UIColor colorWithRed:183.0/255 green:183.0/255 blue:183.0/255 alpha:1.0].CGColor;
    _rechargeNoTextFieldBg.layer.masksToBounds = YES;
    _rechargeNoTextFieldBg.layer.cornerRadius = 10.0;
    _rechargeNoTextFieldBg.layer.borderWidth = 1.0;
    
   _phoneNo.text = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPhone];
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldResponed:)];
    tapGr.delegate = self;
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:tapGr];
    
    UIImage * loginDefaultImage = [[[UIImage imageNamed:@"login_btn_default"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    UIImage * loginLightImage = [[[UIImage imageNamed:@"login_btn_light"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    
    [_submitBtn setBackgroundImage:loginDefaultImage forState:UIControlStateNormal];
    [_submitBtn setBackgroundImage:loginLightImage forState:UIControlStateHighlighted];
    [_submitBtn addTarget:self action:@selector(submitBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_jumpNextStepBtn addTarget:self action:@selector(jumpAction) forControlEvents:UIControlEventTouchUpInside];

}

- (void)enterMainViewController
{
    [[ZdywAppDelegate appDelegate] showSystemNoticeView];
    [[ZdywAppDelegate appDelegate] handleTokenReport];
    [self.navigationController.view removeFromSuperview];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    //通知登陆成功(基于ios8下帮助信息提示显示错误处理)
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoginSuccess object:nil];
}

- (void)textViewResignFirstResponse
{
    [_rechargeCardNo resignFirstResponder];
}

#pragma mark - textField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if ((range.location  ==4||range.location ==9||range.location  ==14||range.location ==19) && string.length>0)
    {
        textField.text = [NSString stringWithFormat:@"%@ ",textField.text];
    }
    return (range.location<24);
}

#pragma mark - btnAction

- (void)textFieldResponed:(UITapGestureRecognizer*)tapGr
{
    [self textViewResignFirstResponse];
}

- (void)submitBtnAction
{
    [self textViewResignFirstResponse];
    
    _rechargeCardText = [_rechargeCardNo.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *tipStr = nil;
    
//    if ([_rechargeCardNo.text length]<14)
//    {
//        tipStr = @"你输入卡密码位数有误,请重新输入";
//    }
    if([[ZdywUtils getCurrentPhoneNetMode ]isEqualToString:@""])
    {
        tipStr = @"网络连接有误,请检查网络";
    }
    if ([tipStr length])
    {
        UIAlertView *tipAlertView = [[UIAlertView alloc] initWithTitle:nil
                                                               message:tipStr
                                                              delegate:self
                                                     cancelButtonTitle:@"我知道了"
                                                     otherButtonTitles:nil, nil];
        [tipAlertView show];
        return;
    }
//    NSString * alertMsg = [NSString stringWithFormat:@"为了您的账户安全,请确认您的充值卡号:%@",_rechargeCardNo.text];
//    UIAlertView *AlertView = [[UIAlertView alloc] initWithTitle:@"说说提示"
//                                                        message:alertMsg
//                                                       delegate:self
//                                              cancelButtonTitle:@"返回修改"
//                                              otherButtonTitles:@"确认提交", nil];
//    [AlertView show];
    
    NSString *strData = @"phone=%@&cardkey=%@&device_id=%@&type=%d";
    strData = [NSString stringWithFormat:strData,_phoneNo.text,_rechargeCardText,[ZdywUtils getDeviceID],3];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance]requestService:ZdywServicePaycardReg
                                             userInfo:nil
                                             postDict:dic];


}

- (void)jumpAction
{

    NSString *strData = @"phone=%@&device_id=%@&ptype=%@&type=%d";
    strData = [NSString stringWithFormat:strData,_phoneNo.text,[ZdywUtils getDeviceID],[ZdywUtils getPlatformInfo],3];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance]requestService:ZdywServiceRegister
                                             userInfo:nil
                                             postDict:dic];

}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{


    if (alertView.tag == 1003)
    {
        [self performSelector:@selector(enterMainViewController) withObject:nil afterDelay:1];
    }
    else
    {
        if (buttonIndex != 0)
        {
            NSString *strData = @"phone=%@&cardkey=%@";
            strData = [NSString stringWithFormat:strData,_phoneNo.text,_rechargeCardText];
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
            [dic setObject:strData forKey:kAGWDataString];
            [[ZdywServiceManager shareInstance]requestService:ZdywServicePaycardReg
                                                 userInfo:nil
                                                 postDict:dic];

        }
    }
}

@end
