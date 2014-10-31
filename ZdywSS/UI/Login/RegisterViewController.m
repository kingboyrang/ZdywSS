//
//  RegisterViewController.m
//  ZdywXY
//
//  Created by zhongduan on 14-8-1.
//  Copyright (c) 2014年 zhongduan. All rights reserved.
//

#import "RegisterViewController.h"
#import "UIImage+Scale.h"
#import "ZdywUtils.h"
#import "RechargeViewController.h"
#import "LoginViewController.h"
@interface RegisterViewController ()

@end

@implementation RegisterViewController

#pragma mark - liftCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self InitMainView ];
    [self addObservers];
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
#pragma mark  -PrivateMethod
- (void)InitMainView
{
    
    _phoneNoTextBg.layer.borderColor = [UIColor colorWithRed:183.0/255 green:183.0/255 blue:183.0/255 alpha:1.0].CGColor;
    _phoneNoTextBg.layer.masksToBounds = YES;
    _phoneNoTextBg.layer.cornerRadius = 10.0;
    _phoneNoTextBg.layer.borderWidth = 1.0;
    
    _phoneNoCheckTextBg.layer.borderColor = [UIColor colorWithRed:183.0/255 green:183.0/255 blue:183.0/255 alpha:1.0].CGColor;
    _phoneNoCheckTextBg.layer.masksToBounds = YES;
    _phoneNoCheckTextBg.layer.cornerRadius = 10.0;
    _phoneNoCheckTextBg.layer.borderWidth = 1.0;

    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldResponed:)];
    tapGr.delegate = self;
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:tapGr];
    
    UIImage * loginDefaultImage = [[[UIImage imageNamed:@"login_btn_default"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    UIImage * loginLightImage = [[[UIImage imageNamed:@"login_btn_light"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    
    [_nextStepBtn setBackgroundImage:loginDefaultImage forState:UIControlStateNormal];
    [_nextStepBtn setBackgroundImage:loginLightImage forState:UIControlStateHighlighted];
    [_nextStepBtn addTarget:self action:@selector(nextStepAction) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark -btnAction
- (void)nextStepAction
{
    [self textViewResignFirstResponse];
    _phoneNoText = [_phoneNo.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *tipStr = nil;
  
    if ([_phoneNo.text length]<13 || [_phoneNoCheck.text length]<13)
    {
        tipStr = @"你输入的手机位数有误,请输入11位手机号码";
    }
    else if (![_phoneNo.text isEqualToString:_phoneNoCheck.text])
    {
        tipStr = @"两次输入的手机号不一致";
    }
    else if (![_phoneNo.text hasPrefix:@"1"])
    {
        tipStr = @"你输入的号码格式有误";
    }
    else if([[ZdywUtils getCurrentPhoneNetMode ]isEqualToString:@""])
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
//    
//    NSString * alertMsg = [NSString stringWithFormat:@"为了您的账户安全,请确认您的手机号:%@",_phoneNoText];
//    UIAlertView *AlertView = [[UIAlertView alloc] initWithTitle:nil
//                                                           message:alertMsg
//                                                          delegate:self
//                                                 cancelButtonTitle:@"返回修改"
//                                                 otherButtonTitles:@"确认提交", nil];
//     AlertView.tag = 1001;
//    [AlertView show];
    //禁用button
    //self.nextStepBtn.enabled=NO;
    //self.nextStepBtn.userInteractionEnabled=NO;
    NSString *strData = @"account=%@";
    strData = [NSString stringWithFormat:strData,_phoneNoText];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance]requestService:ZdywServiceQueryIsRegister
                                             userInfo:nil
                                             postDict:dic];


}

- (void)textFieldResponed:(UITapGestureRecognizer*)tapGr
{
    [self textViewResignFirstResponse];
}

- (void)textViewResignFirstResponse
{
    [_phoneNo resignFirstResponder];
    [_phoneNoCheck resignFirstResponder];
}
#pragma mark - observers

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveQueryData:)
                                                 name:kNotificationQueryIsRegister
                                               object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationQueryIsRegister object:nil];
}

- (void)changeStatusBarStyle
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}
#pragma mark - HttpReceiveData

- (void)receiveQueryData:(NSNotification *)notification
{
    //self.nextStepBtn.enabled=YES;//启用
    //self.nextStepBtn.userInteractionEnabled=YES;
    NSDictionary *userInfo = [notification userInfo];
    NSString *strReason = [userInfo objectForKey:@"reason"];

    id result = [userInfo objectForKey:@"result"];
    if ([result integerValue] == 39) // 未注册的用户（新用户）
    {
        [ZdywUtils setLocalDataString:_phoneNoText key:kZdywDataKeyUserPhone];
        RechargeViewController * loginView   = [[RechargeViewController alloc] initWithNibName:NSStringFromClass([RechargeViewController class]) bundle:nil];
        [self.navigationController pushViewController:loginView animated:YES];
        
    }
    else if([result integerValue] == 0) // 老用户直接跳到登陆界面
    {
        NSString * alertMsg = [NSString stringWithFormat:@"您已经是老用户,无需注册请直接登录"];
        UIAlertView *AlertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:alertMsg
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"登录", nil];
        AlertView.tag = 1002;
        [AlertView show];

    }
    else
    {
        [SVProgressHUD showInView:self.navigationController.view
                           status:@""
                 networkIndicator:NO
                             posY:-1
                         maskType:SVProgressHUDMaskTypeClear];
        
        [SVProgressHUD dismissWithError:strReason afterDelay:2];

    }
}

#pragma mark - textField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    if ((range.location ==3 ||range.location ==8) && string.length>0)
    {
        textField.text = [NSString stringWithFormat:@"%@ ",textField.text];
    }
    return (range.location<13);
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001)
    {
        if (buttonIndex != 0)
        {
            
            NSString *strData = @"account=%@";
            strData = [NSString stringWithFormat:strData,_phoneNoText];
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
            [dic setObject:strData forKey:kAGWDataString];
            [[ZdywServiceManager shareInstance]requestService:ZdywServiceQueryIsRegister
                                                     userInfo:nil
                                                     postDict:dic];
        }

    }
    else
    {
         if (buttonIndex != 0)
         {
             LoginViewController * loginView   = [[LoginViewController alloc] initWithNibName:NSStringFromClass([LoginViewController class]) bundle:nil];
             [self.navigationController pushViewController:loginView animated:YES];

         }
    }
}
@end
