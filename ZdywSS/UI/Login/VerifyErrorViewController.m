//
//  VerifyErrorViewController.m
//  ZdywXY
//
//  Created by zhongduan on 14-8-6.
//  Copyright (c) 2014年 zhongduan. All rights reserved.
//

#import "VerifyErrorViewController.h"
#import "UIImage+Scale.h"
@interface VerifyErrorViewController ()

@end

@implementation VerifyErrorViewController
{
    NSInteger  _count;
}


#pragma mark - liftCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    _count = 30;
    [self InitMainView];
    [self addObservers];
    [_checkVerfityBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyZdywFontColor] forState:UIControlStateNormal];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    if (!_showType)
    {
        self.title = @"修改密码";
    }
    else
    {
        self.title = @"验证失败";
    }
    [self performSelector:@selector(changeStatusBarStyle) withObject:nil afterDelay:0.1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveGetIdentifyNumber:)
                                                 name:kNotificationGetVeriftyCode
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveCheckIdentifyNumber:)
                                                 name:kNotificationCheckVeriftyCode
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveResetPassWord:)
                                                 name:kNotificationResetPSW
                                               object:nil];
    
    //添加绑定手机号和获取验证码通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveBindNumberData:)
                                                 name:kNotificationBindNewPhoneFinish
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveGetBindReqIdentifyNo:)
                                                 name:kNotificationChangePhoneFinish
                                               object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationGetVeriftyCode object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationCheckVeriftyCode object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationResetPSW object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationBindNewPhoneFinish object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationChangePhoneFinish object:nil];
}

#pragma mark - HttpReceiveData

- (void)receiveBindNumberData:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    int result = [[dic objectForKey:@"result"] intValue];
    NSString *str = [dic objectForKey:@"reason"];
    switch (result)
    {
        case 0:
        {
            str= @"验证手机成功！现在去拨打电话吧！";
            [SVProgressHUD dismissWithSuccess:str afterDelay:2.0];
            [self performSelector:@selector(BacktoRootView) withObject:nil afterDelay:2];
        }
            break;
        default:
        {
            [SVProgressHUD dismissWithError:str afterDelay:2.0];
        }
            break;
    }
}

- (void)receiveGetBindReqIdentifyNo:(NSNotification *)notification
{
    
    NSDictionary *dic = [notification userInfo];
    int result = [[dic objectForKey:@"result"] intValue];
    NSString *str = [dic objectForKey:@"reason"];
    
    switch (result)
    {
        case 0:
        {
            [SVProgressHUD dismissWithSuccess:str afterDelay:2.0];
            [self onSuccess];
            break;
        }
        default:
        {
            [SVProgressHUD dismissWithError:str afterDelay:2.0];
            [_verifyNoBtn setEnabled:YES];
        }
            break;
    }
    
}
- (void)receiveGetIdentifyNumber:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    int result = [[dic objectForKey:@"result"] intValue];
    NSString *str = [dic objectForKey:@"reason"];
    switch (result)
    {
        case 0:
        {
            [SVProgressHUD dismissWithSuccess:str afterDelay:2.0];
            [self onSuccess];
        }
            break;
        default:
        {
            [SVProgressHUD dismissWithError:str afterDelay:2.0];
            [_verifyNoBtn setEnabled:YES];
        }
            break;
    }
}

- (void)receiveCheckIdentifyNumber:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    int result = [[dic objectForKey:@"result"] intValue];
    NSString *str = [dic objectForKey:@"reason"];
    switch (result)
    {
        case 0:
        {
            str =@"验证码正确!";
            [SVProgressHUD dismissWithSuccess:str afterDelay:2.0];
            [self onSuccess];
            
        }
            break;
        default:
        {
            [SVProgressHUD dismissWithError:str afterDelay:2.0];
            [_verifyNoBtn setEnabled:YES];
        }
            break;
    }
    
}

- (void)receiveResetPassWord:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    int result = [[dic objectForKey:@"result"] intValue];
    NSString *str = [dic objectForKey:@"reason"];
    switch (result)
    {
        case 0:
        {
            str =@"密码修改成功,请牢记密码!";
            
            NSString * strPhoneNo = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPhone];
            if ([strPhoneNo length]>0)
            {
                [ZdywUtils setLocalDataString:_userNewPSW key:kZdywDataKeyUserPwd];
                [[ZdywAppDelegate appDelegate] afterClientActived];//重新拉取配置信息
            }
            [SVProgressHUD dismissWithSuccess:str afterDelay:2.0];
            [self performSelector:@selector(BacktoRootView) withObject:nil afterDelay:2];
        }
            break;
        default:
        {
            [SVProgressHUD dismissWithError:str afterDelay:2.0];
            [_verifyNoBtn setEnabled:YES];
        }
            break;
    }
    
}


#pragma mark  -PrivateMethod

- (void)BacktoRootView
{
    if(_showType == 1)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        
        for (UIViewController *temp in self.navigationController.viewControllers)
        {
            if ([temp.title isEqualToString:@"登录"] || [temp.title isEqualToString:@"设置"])
            {
                [self.navigationController popToViewController:temp animated:YES];
            }
        }

        //[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    }

}

- (void)BindPhoneNoReq
{
    NSString *strData = @"phone=%@&code=%@";
    
    //获取手机号(绑定手机号)
    NSString *strPhone = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPhone];
    
    //获取code(短信验证码)
    NSString *strCode = _verifyNoText.text;
    
    strData = [NSString stringWithFormat:strData, strPhone, strCode];
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceBindNewPhone
                                              userInfo:nil
                                              postDict:dic];
    [SVProgressHUD showInView:self.view
                       status:@"数据提交中，请稍候..."
             networkIndicator:NO
                         posY:-1
                     maskType:SVProgressHUDMaskTypeClear];
    
}
// 获取语音验证码
- (void)getBindReqVerifyNo
{
    [_verifyNoBtn setEnabled:NO];
    NSString *strData = @"new_phone=%@&type=%d&passwd=%@";
    //获取passwd(密码要md5)
    NSString *strPwd = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPwd];
    strPwd = [[Zdyw_md5 shareUtility] md5:strPwd];
    
    //获取手机号(绑定手机号)
    NSString *strPhone = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPhone];
    
    strData = [NSString stringWithFormat:strData, strPhone,1,strPwd]; // type为 0短信验证码 1 语音验证码
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceChangedPhone
                                              userInfo:nil
                                              postDict:dic];
    [SVProgressHUD showInView:self.view
                       status:@"数据提交中，请稍候..."
             networkIndicator:NO
                         posY:-1
                     maskType:SVProgressHUDMaskTypeClear];
    
}

// 获取语音验证码
- (void)getVerifyNoReq
{
    [_verifyNoBtn setEnabled:NO];
    NSString *strData = @"account=%@&issue_typt=%d";
    //获取手机号
    strData = [NSString stringWithFormat:strData, _userPhoneNo,1]; // typt为 0短信验证码 1 语音验证码
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceGetVeriftyCode
                                              userInfo:nil
                                              postDict:dic];
    [SVProgressHUD showInView:self.view
                       status:@"数据提交中，请稍候..."
             networkIndicator:NO
                         posY:-1
                     maskType:SVProgressHUDMaskTypeClear];
    
}

-(void)checkVerifyReq
{
    NSString *strData = @"account=%@&code=%@";
    
    strData = [NSString stringWithFormat:strData, _userPhoneNo,_verifyNoText.text];
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceCheckVeriftyCode
                                              userInfo:nil
                                              postDict:dic];
    [SVProgressHUD showInView:self.view
                       status:@"数据提交中，请稍候..."
             networkIndicator:NO
                         posY:-1
                     maskType:SVProgressHUDMaskTypeClear];
    
}
-(void)resetUserPSW
{
    NSString *publicKey=[ZdywCommonFun getAppConfigureInfoWithKey:kZdywDataKeyServerKey];
    NSString *strData = @"account=%@&code=%@&passwd=%@";
    //用户重置密码（rc4加密）
    NSString *strUserPSW = [Zdyw_rc4 RC4Encrypt:_userNewPSW withKey:publicKey];
    //NSString *strUserPSW = [[Zdyw_md5 shareUtility] md5:_userNewPSW];
    strData = [NSString stringWithFormat:strData, _userPhoneNo,_verifyNoText.text,strUserPSW];
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceResetPSW
                                              userInfo:nil
                                              postDict:dic];
    [SVProgressHUD showInView:self.view
                       status:@"数据提交中，请稍候..."
             networkIndicator:NO
                         posY:-1
                     maskType:SVProgressHUDMaskTypeClear];
    
}

- (void)InitMainView
{
    
    
    [_callServiceBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:86.0/255 green:193.0/255 blue:3.0/255 alpha:1.0]] forState:UIControlStateNormal];
    _callServiceBtn.layer.cornerRadius = 10.0;
    _callServiceBtn.layer.borderWidth = 1.0;
    _callServiceBtn.layer.masksToBounds = YES;
    _callServiceBtn.layer.borderColor = [UIColor clearColor].CGColor;
    [_callServiceBtn addTarget:self action:@selector(callServiceNum) forControlEvents:UIControlEventTouchUpInside];

    if (!_showType)
    {
        [_checkVerfityBtn setTitle:@"确认提交"forState:UIControlStateNormal];
    }

   
    // 页面1
    if (kZdywClientIsIphone5)
    {
       self.mainScrollView.contentSize = CGSizeMake(0, 568*2);
        _voiceView.frame = CGRectMake(0, 568+1, 320, _mainScrollView.frame.size.height);
    }
    else
    {
        self.mainScrollView.contentSize = CGSizeMake(0, 480*2);
        _voiceView.frame = CGRectMake(0, 480+1, 320, _mainScrollView.frame.size.height);
    }
    self.mainScrollView.scrollEnabled = NO;
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
    //[self.mainScrollView addSubview:_voiceView];
    
     
    _verifyNoTextBg.layer.borderColor = [UIColor colorWithRed:183.0/255 green:183.0/255 blue:183.0/255 alpha:1.0].CGColor;
    _verifyNoTextBg.layer.masksToBounds = YES;
    _verifyNoTextBg.layer.cornerRadius = 10.0;
    _verifyNoTextBg.layer.borderWidth = 1.0;
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldResponed:)];
    tapGr.delegate = self;
    [self.mainScrollView setUserInteractionEnabled:YES];
    [self.mainScrollView addGestureRecognizer:tapGr];
    
    UIImage * loginDefaultImage = [[[UIImage imageNamed:@"login_btn_default"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    UIImage * loginLightImage = [[[UIImage imageNamed:@"login_btn_light"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    
    UIImage * oldUserDefaultImage = [[[UIImage imageNamed:@"登陆-常规"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    UIImage * oldUseLightImage = [[[UIImage imageNamed:@"登陆-down"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];

    
    _verifyNoBtn.titleLabel.numberOfLines = 0;
    [_verifyNoBtn setBackgroundImage:loginDefaultImage forState:UIControlStateNormal];
    [_verifyNoBtn setBackgroundImage:loginLightImage forState:UIControlStateHighlighted];
    [_verifyNoBtn addTarget:self action:@selector(verfityNoBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_checkVerfityBtn setBackgroundImage:oldUserDefaultImage forState:UIControlStateNormal];
    [_checkVerfityBtn setBackgroundImage:oldUseLightImage forState:UIControlStateHighlighted];
    [_checkVerfityBtn addTarget:self action:@selector(checkVerfityBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)textViewResignFirstResponse
{
    [_verifyNoText resignFirstResponder];
}
- (void)changeStatusBarStyle
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}
- (void)onSuccess
{

    if (_count > 0)
    {
        [_verifyNoBtn setEnabled:NO];
        [self performSelector:@selector(onSuccess) withObject:nil afterDelay:1.0];
        NSString *timeLableStr = [NSString stringWithFormat:@"(%ds)",_count];
        [_verifyNoBtn setTitle:@"等待来电    " forState:UIControlStateDisabled];
        _timeLableText.text = timeLableStr;
        _count--;
    }
    else
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onSuccess) object:nil];
        _count = 30;
        [_verifyNoBtn setEnabled:YES];
        [_verifyNoBtn setTitle:@"获取语音验证码" forState:UIControlStateNormal];
        _timeLableText.text = @"";
    }
    

}
#pragma mark - btnAction


- (void)textFieldResponed:(UITapGestureRecognizer*)tapGr
{
    [self textViewResignFirstResponse];
}

-(void)verfityNoBtnAction
{
    [self.mainScrollView endEditing:TRUE];
    if (_showType)
    {
        [self getBindReqVerifyNo];
    }
    else
    {
        [self getVerifyNoReq];
    }
}
-(void)checkVerfityBtnAction
{

    if (![_verifyNoText.text length]>0)
    {
        UIAlertView *callAlert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"请输入验证码"                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil];
        [callAlert show];
        return;
    }
    [self.verifyNoText resignFirstResponder];
    if (_showType)
    {
        [self BindPhoneNoReq];
    }
    else
    {
        [self resetUserPSW];
    }

}

- (void)callServiceNum
{
    NSString *strphone = [ZdywCommonFun getCustomerPhone];
    NSString *strURL = [NSString stringWithFormat:@"tel://%@", strphone];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:strURL]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strURL]];
    }
}



#pragma mark - textField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return (range.location<4);
}
@end
