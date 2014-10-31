//
//  VerifyViewController.m
//  ZdywXY
//
//  Created by zhongduan on 14-8-6.
//  Copyright (c) 2014年 zhongduan. All rights reserved.
//

#import "VerifyViewController.h"
#import "UIImage+Scale.h"
#import "VerifyErrorViewController.h"
@interface VerifyViewController ()
{
    NSInteger  _count;
    BOOL       _firstReqVerifyNo;
}

@end

@implementation VerifyViewController

#pragma mark - liftCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    _count = 30;
    [self InitMainView];
    [self addObservers];
    
    [_checkVerfityBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyZdywFontColor] forState:UIControlStateNormal];
    [_unReceiveMsgBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyZdywFontColor] forState:UIControlStateNormal];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    if (!_showType && !_firstReqVerifyNo)
    {
        self.title = @"修改密码";
        [self performSelector:@selector(getVerifyNoReq) withObject:nil afterDelay:0.1];
    }
    else if(_showType && !_firstReqVerifyNo)
    {
        self.title = @"验证手机号";
        [self performSelector:@selector(getBindReqVerifyNo) withObject:nil afterDelay:0.1];
    }
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
            //[SVProgressHUD dismissWithSuccess:str afterDelay:2.0];
            NSString *userPhoneNo =  [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPhone];
            NSString *str = [NSString stringWithFormat:@"验证码已经发到%@手机上，请注意查收短信",userPhoneNo];
            [SVProgressHUD dismissWithSuccess:str afterDelay:2.0];
            [self onSuccess];
            break;
        }
        default:
        {
            [SVProgressHUD dismissWithError:str afterDelay:2.0];
            [_verfityNoBtn setEnabled:YES];
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
            //[SVProgressHUD dismissWithSuccess:str afterDelay:2.0];
            NSString *str = [NSString stringWithFormat:@"验证码已经发到%@手机上，请注意查收短信",_userPhoneNo];
            [SVProgressHUD dismissWithSuccess:str afterDelay:2.0];
            [self onSuccess];
        }
        break;
        default:
        {
            [SVProgressHUD dismissWithError:str afterDelay:2.0];
            [_verfityNoBtn setEnabled:YES];
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
            [_verfityNoBtn setEnabled:YES];
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
            [_verfityNoBtn setEnabled:YES];
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
//        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
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
- (void)getBindReqVerifyNo
{
    _firstReqVerifyNo = YES;
    [_verfityNoBtn setEnabled:NO];
    
    NSString *strData = @"new_phone=%@&type=%d&passwd=%@";
    //获取passwd(密码要md5)
    NSString *strPwd = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPwd];
    strPwd = [[Zdyw_md5 shareUtility] md5:strPwd];
    
    //获取手机号(绑定手机号)
    NSString *strPhone = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPhone];
    
    strData = [NSString stringWithFormat:strData, strPhone,0,strPwd]; // type为 0短信验证码 1 语音验证码
    
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

- (void)getVerifyNoReq
{
    _firstReqVerifyNo = YES;
    [_verfityNoBtn setEnabled:NO];
    NSString *strData = @"account=%@&issue_typt=%d";
    //获取手机号
    strData = [NSString stringWithFormat:strData, _userPhoneNo,0];// typt为 0短信验证码 1 语音验证码
    
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
    __verifyNoTextFieldBg.layer.borderColor = [UIColor colorWithRed:183.0/255 green:183.0/255 blue:183.0/255 alpha:1.0].CGColor;
    __verifyNoTextFieldBg.layer.masksToBounds = YES;
    __verifyNoTextFieldBg.layer.cornerRadius = 10.0;
    __verifyNoTextFieldBg.layer.borderWidth = 1.0;
    
    if (!_showType)
    {
        _phoneNo.text = [NSString stringWithFormat:@"请输入短信中的验证码"];
        [_checkVerfityBtn setTitle:@"确认提交"forState:UIControlStateNormal];
    }
    else
    {
        NSString * strPhoneNo = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPhone];
        _phoneNo.text = [NSString stringWithFormat:@"系统已向您的注册手机号:          %@以短信形式发送了验证码，请查收并输入",strPhoneNo];
    }
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldResponed:)];
    tapGr.delegate = self;
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:tapGr];
    
    UIImage * loginDefaultImage = [[[UIImage imageNamed:@"login_btn_default"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    UIImage * loginLightImage = [[[UIImage imageNamed:@"login_btn_light"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    
    UIImage * oldUserDefaultImage = [[[UIImage imageNamed:@"登陆-常规"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    UIImage * oldUseLightImage = [[[UIImage imageNamed:@"登陆-down"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    
    _verfityNoBtn.titleLabel.numberOfLines = 0;
    [_verfityNoBtn setBackgroundImage:loginDefaultImage forState:UIControlStateNormal];
    [_verfityNoBtn setBackgroundImage:loginLightImage forState:UIControlStateHighlighted];
    [_verfityNoBtn addTarget:self action:@selector(verfityNoBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_checkVerfityBtn setBackgroundImage:oldUserDefaultImage forState:UIControlStateNormal];
    [_checkVerfityBtn setBackgroundImage:oldUseLightImage forState:UIControlStateHighlighted];
    [_checkVerfityBtn addTarget:self action:@selector(checkVerfityBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_unReceiveMsgBtn addTarget:self action:@selector(unReceiveMsgAction) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)textViewResignFirstResponse
{
    [_verifyNoText resignFirstResponder];
}

- (void)onSuccess
{
    if (_count > 0)
    {
        [_verfityNoBtn setEnabled:NO];
        [self performSelector:@selector(onSuccess) withObject:nil afterDelay:1.0];
        NSString *timeLableStr = [NSString stringWithFormat:@"(%ds)",_count];
        [_verfityNoBtn setTitle:@"正在获取     " forState:UIControlStateDisabled];
        _timeLableText.text = timeLableStr;
        _count--;
    }
    else
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onSuccess) object:nil];
        _count = 30;
        [_verfityNoBtn setEnabled:YES];
        [_verfityNoBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        _timeLableText.text = @"";
    }
    
}
#pragma mark - btnAction

-(void)verfityNoBtnAction
{
    [self.view endEditing:TRUE];
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
-(void)unReceiveMsgAction
{
    VerifyErrorViewController * verifyErrorView   = [[VerifyErrorViewController alloc] initWithNibName:NSStringFromClass([VerifyErrorViewController class]) bundle:nil];
    if (!_showType)
    {
        verifyErrorView.userNewPSW = _userNewPSW;
        verifyErrorView.userPhoneNo = _userPhoneNo;
    }
    verifyErrorView.showType = _showType;
    [self.navigationController pushViewController:verifyErrorView animated:YES];
}
- (void)textFieldResponed:(UITapGestureRecognizer*)tapGr
{
    [self textViewResignFirstResponse];
}

#pragma mark - textField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return (range.location<4);
}
@end
