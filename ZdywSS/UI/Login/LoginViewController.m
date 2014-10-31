//
//  LoginViewController.m
//  ZdywClient
//
//  Created by ddm on 6/12/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "LoginViewController.h"
#import "UIImage+Scale.h"
#import "ZdywUtils.h"
#import "ContactManager.h"
#import "FindPwdViewController.h"
#import "BindPhoneNumberViewController.h"
#import "UserServiceViewController.h"
#import "NewModifyPwdViewController.h"
#import "ResetViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

#pragma mark - liftCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self InitMainView];
    [self addObservers];
    
    [_findPwdBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyZdywFontColor] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self performSelector:@selector(changeStatusBarStyle) withObject:nil afterDelay:0.1];
    self.title = @"登录";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - observers

- (void)changeStatusBarStyle{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)addObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoginData:)
                                                 name:kNotificationPhoneLoginFinish
                                               object:nil];
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationPhoneLoginFinish object:nil];
}

#pragma mark - HttpReceiveData

- (void)receiveLoginData:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    id result = [userInfo objectForKey:@"result"];
    NSString *strReason = [userInfo objectForKey:@"reason"];
    if (result)
    {
        NSInteger resultCode = [result integerValue];
        if (resultCode == 0)
        {
            [ZdywUtils setLocalDataString:@"+86"
                                      key:kCurrentCountryCode];
            [ZdywUtils setLocalDataString:@"中国"
                                      key:kCurrentCountryName];
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
            NSString *userID = [userInfo objectForKey:@"uid"];
            [ZdywUtils setLocalDataString:userID key:kZdywDataKeyUserID];
            [ZdywUtils setLocalDataString:_pwdTextField.text key:kZdywDataKeyUserPwd];
            
            
            int DialModeType=[[ZdywCommonFun getAppConfigureInfoWithKey:kZdywDataKeyDialModelType] intValue];
            
            [ZdywUtils setLocalIdDataValue:[NSNumber numberWithInt:DialModeType]
                                       key:kDialModeType]; // 设置默认拨打方式为回拨
            [[ContactManager shareInstance] createUserDataBaseWithUserID:userID];
            NSString *userPhone = [userInfo objectForKey:@"mobile"];
            [[NSNotificationCenter defaultCenter] postNotificationName:KLoginSuccess object:nil userInfo:nil];
            //if ([userPhone length])
            {
                [ZdywUtils setLocalDataString:userPhone key:kZdywDataKeyUserPhone];
                //重新获取一些配置信息
                [[ZdywAppDelegate appDelegate] afterClientActived];
                [SVProgressHUD dismissWithSuccess:@"登录成功" afterDelay:2.0];
                [self performSelector:@selector(loginSuccess) withObject:nil afterDelay:2];
            //} else {
            //    [SVProgressHUD dismissWithSuccess:@"登录成功" afterDelay:2.0];
            //    [self performSelector:@selector(showBindPhoneNumber) withObject:nil afterDelay:2];
            }
        }
        else
        {
            [SVProgressHUD dismissWithError:strReason afterDelay:2];
        }
    }
    else
    {
        [SVProgressHUD dismissWithError:@"登录失败" afterDelay:2];
    }
}

#pragma mark - PrivateMethod

- (void)loginSuccess{
    [[ZdywAppDelegate appDelegate] showSystemNoticeView];
    [[ZdywAppDelegate appDelegate] handleTokenReport];
    [self.navigationController.view removeFromSuperview];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    //通知登陆成功(基于ios8下帮助信息提示显示错误处理)
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoginSuccess object:nil];
}

- (void)showBindPhoneNumber{
    BindPhoneNumberViewController *bindPhoneNumber = [[BindPhoneNumberViewController alloc] initWithNibName:NSStringFromClass([BindPhoneNumberViewController class]) bundle:nil];
    [self.navigationController pushViewController:bindPhoneNumber animated:YES];
}

- (void)InitMainView{
    _textFieldBg.layer.cornerRadius = 15.0;
    _textFieldBg.layer.borderColor = [UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0].CGColor;
    _textFieldBg.layer.borderWidth = 1.0;
    _textFieldBg.layer.masksToBounds = YES;
    
    _pwdTextField.delegate = self;
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldResponed:)];
    tapGr.delegate = self;
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:tapGr];
    
    UISwipeGestureRecognizer *swipGrUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldResponed:)];
    [swipGrUp setDirection:UISwipeGestureRecognizerDirectionUp];
    swipGrUp.delegate = self;
    [self.view addGestureRecognizer:swipGrUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldResponed:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    swipeDown.delegate = self;
    [self.view addGestureRecognizer:swipeDown];
    
    UIImage * loginDefaultImage = [[[UIImage imageNamed:@"login_btn_default"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    UIImage * loginLightImage = [[[UIImage imageNamed:@"login_btn_light"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    [_loginBtn setBackgroundImage:loginDefaultImage forState:UIControlStateNormal];
    [_loginBtn setBackgroundImage:loginLightImage forState:UIControlStateHighlighted];
    
    [_showServiceBtn addTarget:self action:@selector(showServiceTermView) forControlEvents:UIControlEventTouchUpInside];
    [_loginBtn addTarget:self action:@selector(loginBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_findPwdBtn addTarget:self action:@selector(findPwdBtnAction) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - BtnAction

- (void)textFieldResponed:(UITapGestureRecognizer*)tapGr{
    [self textViewResignFirstResponse];
}

- (void)textViewResignFirstResponse{
    [_phoneTextField resignFirstResponder];
    [_pwdTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (_pwdTextField == textField) {
        [self textViewResignFirstResponse];
    }
    return YES;
}

- (void)getactivityInfo
{
    NSString *strData = @"";
    NSString *strFlag = [ZdywUtils getLocalStringDataValue:kDefaultConfigSameFlag];
    if([strFlag length] > 0)
    {
        strData = [NSString stringWithFormat:@"flag=%@", strFlag];
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setValue:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceSysMessage
                                              userInfo:nil
                                              postDict:dic];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowNoticeView
                                                        object:nil
                                                      userInfo:nil];

    
}

- (void)loginBtnAction{
    [_phoneTextField resignFirstResponder];
    [_pwdTextField resignFirstResponder];
    NSString *tipStr = nil;
    NSString *accountStr = nil;
    NSString *pwdStr = nil;
    if (![_phoneTextField.text length]) {
        tipStr = @"请输入账号";
    } else if (![_pwdTextField.text length]) {
        tipStr = @"请输入密码";
    } else if ([_pwdTextField.text length] <6 || [_pwdTextField.text length] > 16){
        tipStr = @"请输入6到16位密码";
    }
    if ([tipStr length]) {
        UIAlertView *tipAlertView = [[UIAlertView alloc] initWithTitle:nil
                                                               message:tipStr
                                                              delegate:self
                                                     cancelButtonTitle:@"我知道了"
                                                     otherButtonTitles:nil, nil];
        [tipAlertView show];
        return;
    }
    accountStr = _phoneTextField.text;
    pwdStr = _pwdTextField.text;
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
    strData = [NSString stringWithFormat:strData,accountStr, passwordStr, strPType, strNetMode];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance]requestService:ZdywServiceLogin
                                             userInfo:nil
                                             postDict:dic];
    [self getactivityInfo];
    

}

- (void)findPwdBtnAction{
//    FindPwdViewController *findPwdViewController = [[FindPwdViewController alloc] initWithNibName:NSStringFromClass([FindPwdViewController class]) bundle:nil];
//    [self.navigationController pushViewController:findPwdViewController animated:YES];
    ResetViewController *modifyPwdView = [[ResetViewController alloc] initWithNibName:NSStringFromClass([ResetViewController class]) bundle:nil];
    modifyPwdView.showType = 1;
    [self.navigationController pushViewController:modifyPwdView animated:YES];
}

- (void)showServiceTermView{
    UserServiceViewController *serviceTermView = [[UserServiceViewController alloc] initWithNibName:NSStringFromClass([UserServiceViewController class]) bundle:nil];
    [self.navigationController pushViewController:serviceTermView animated:YES];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

#pragma mark - textField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (textField == _phoneTextField)
    {
        return (range.location<11);
    }
    return (range.location<16);

}
@end
