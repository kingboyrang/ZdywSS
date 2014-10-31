//
//  NewModifyPwdViewController.m
//  ZdywClient
//
//  Created by ddm on 6/20/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "NewModifyPwdViewController.h"
#import "UIImage+Scale.h"
#import "CallManager.h"

@interface NewModifyPwdViewController ()

@end

@implementation NewModifyPwdViewController

#pragma mark - lifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"修改密码";
    
    _secretTextField.delegate = self;
    _sureNewPwdTextField.delegate = self;
    
    _textFieldBg.layer.cornerRadius = 15.0;
    _textFieldBg.layer.borderColor = [UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0].CGColor;
    _textFieldBg.layer.borderWidth = 1.0;
    _textFieldBg.layer.masksToBounds = YES;
    
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
    
    [_modifyBtn setBackgroundImage:[UIImage createImageWithColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyZdywFontColor]] forState:UIControlStateNormal];
    _modifyBtn.layer.cornerRadius = 10.0;
    _modifyBtn.layer.masksToBounds = YES;
    [_modifyBtn setTitle:@"更改密码" forState:UIControlStateNormal];
    [_modifyBtn addTarget:self action:@selector(modifyPwd) forControlEvents:UIControlEventTouchUpInside];
    
    [_skipBtn addTarget:self action:@selector(skipAction) forControlEvents:UIControlEventTouchUpInside];
    [_skipBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyZdywFontColor] forState:UIControlStateNormal];
    [self addObservers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBarHidden = NO;
}

- (void)dealloc{
    [self removeObservers];
}

#pragma mark - observers

- (void)addObservers{
    [[NSNotificationCenter defaultCenter ] addObserver:self
                                              selector:@selector(receiveDataForModifyPwd:)
                                                  name:kNotificationResetPwdFinish
                                                object:nil];
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationResetPwdFinish
                                                  object:nil];
}

#pragma mark - PrivateMethod

- (void)receiveDataForModifyPwd:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    
    if([dic objectForKey:@"result"] )
    {
        int nRet = [[dic objectForKey:@"result"] intValue];
        NSString *str = [dic objectForKey:@"reason"];
        
        switch (nRet)
        {
            case 0:
            {
                [SVProgressHUD dismissWithSuccess:str afterDelay:2];
                NSString *strNewPwd = _secretTextField.text;
                [ZdywUtils setLocalDataString:strNewPwd key:kZdywDataKeyUserPwd];
                [self performSelector:@selector(onSuccess) withObject:nil afterDelay:2];
                [[ZdywAppDelegate appDelegate] afterClientActived];
                //重新获取一些配置信息
            }
                break;
            default:
            {
                [SVProgressHUD dismissWithError:str afterDelay:2];
                [self performSelector:@selector(onReSetInput) withObject:nil afterDelay:2];
            }
                break;
        }
    }
}

#pragma mark - ButtonAction

// 重新设置输入焦点，弹出输入键盘
- (void) onReSetInput
{
    [_secretTextField becomeFirstResponder];
}

- (void)onSuccess
{
    if([[CallManager shareInstance] sp_is_registered])
    {
        [[CallManager shareInstance] sp_unregister];
    }
    [self.navigationController.view removeFromSuperview];
}

- (void)skipAction{
    [self.navigationController.view removeFromSuperview];
}

- (void)textFieldResponed:(UITapGestureRecognizer*)tapGr
{
    [self textViewResignFirstResponse];
}

- (void)textViewResignFirstResponse
{
    [_secretTextField resignFirstResponder];
    [_sureNewPwdTextField resignFirstResponder];
}

- (void)modifyPwd{
    NSString *strNewPwd = _secretTextField.text;
    NSString *strSureNewPwd = _sureNewPwdTextField.text;
    if (0 == [strNewPwd length])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"新密码不能为空。"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if (0 == [strSureNewPwd length])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"请再次输入新密码。"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if (![strSureNewPwd isEqualToString:strNewPwd])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"两次输入的新密码不一致，请重新输入。"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        _secretTextField.text = @"";
        _sureNewPwdTextField.text = @"";
        return;
    }
    if ([[ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPwd] isEqualToString:strNewPwd])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"新密码与旧密码一致，无需修改。"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        _secretTextField.text = @"";
        _sureNewPwdTextField.text = @"";
        return;
    }
    if ([strSureNewPwd length] < 6 ||  [strSureNewPwd length] > 16)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"密码长度小于6位或超过16位，请重新输入。"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil, nil];
        [alertView show];;
        _secretTextField.text = @"";
        _sureNewPwdTextField.text = @"";
        return;
    }
    [self.view endEditing:YES];
    [SVProgressHUD showInView:self.view
                       status:@"数据提交中，请稍候..."
             networkIndicator:NO
                         posY:-1
                     maskType:SVProgressHUDMaskTypeClear];
    NSString *strData = @"old_passwd=%@&new_passwd=%@";
    NSString *strOldPwd = nil;
    NSString *publicKey=[ZdywCommonFun getAppConfigureInfoWithKey:kZdywDataKeyServerKey];
    //获取老密码
    strOldPwd = [Zdyw_rc4 RC4Encrypt:[ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPwd] withKey:publicKey];
    //获取新mim
    strNewPwd = [Zdyw_rc4 RC4Encrypt:strNewPwd withKey:publicKey];
    strData = [NSString stringWithFormat:strData, strOldPwd, strNewPwd];
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceResetPwdSubmit
                                              userInfo:nil
                                              postDict:dic];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_secretTextField resignFirstResponder];
    [_sureNewPwdTextField resignFirstResponder];
    return YES;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

@end
