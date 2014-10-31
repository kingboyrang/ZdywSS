//
//  ModifyPWDViewController.m
//  UXinClient
//
//  Created by Liam Peng on 11-11-18.
//  Copyright (c) 2011年 D-TONG-TELECOM. All rights reserved.
//

#import "ModifyPWDViewController.h"
#import "CallManager.h"
#import "ZdywAppDelegate.h"
#import "ZdywServiceManager.h"
#import "UIImage+Scale.h"
#import "FindPwdViewController.h"

@interface ModifyPWDViewController ()

@end

@implementation ModifyPWDViewController

#pragma mark - liftCycle

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad 
{
    [super viewDidLoad];
    [_modifyPwdBtn setTitle:@"确认修改" forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter ] addObserver:self
                                              selector:@selector(receiveDataForModifyPwd:)
                                                  name:kNotificationResetPwdFinish
                                                object:nil];
    self.title = @"修改密码";
    
    _pTextFiledNewPwd.delegate = self;
    _pTextFiledOldPwd.delegate = self;
    _pTextFiledNewPwdConfire.delegate = self;
    
    [self.view setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dissKeyBoard)];
    tapGr.delegate = self;
    [self.view addGestureRecognizer:tapGr];
    
    UISwipeGestureRecognizer *swipGrUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dissKeyBoard)];
    [swipGrUp setDirection:UISwipeGestureRecognizerDirectionUp];
    swipGrUp.delegate = self;
    [self.view addGestureRecognizer:swipGrUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dissKeyBoard)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    swipeDown.delegate = self;
    [self.view addGestureRecognizer:swipeDown];
    
    _textFieldBg.layer.masksToBounds = YES;
    _textFieldBg.layer.cornerRadius = 10.0;
    _textFieldBg.layer.borderWidth = 1.0;
    _textFieldBg.layer.borderColor = [UIColor colorWithRed:197.0/255 green:197.0/255 blue:197.0/255 alpha:1.0].CGColor;
    
    _pwdBg.layer.masksToBounds = YES;
    _pwdBg.layer.cornerRadius = 10.0;
    _pwdBg.layer.borderWidth = 1.0;
    _pwdBg.layer.borderColor = [UIColor colorWithRed:197.0/255 green:197.0/255 blue:197.0/255 alpha:1.0].CGColor;
    
    _pwdConfireBg.layer.masksToBounds = YES;
    _pwdConfireBg.layer.cornerRadius = 10.0;
    _pwdConfireBg.layer.borderWidth = 1.0;
    _pwdConfireBg.layer.borderColor = [UIColor colorWithRed:197.0/255 green:197.0/255 blue:197.0/255 alpha:1.0].CGColor;
    
    _modifyPwdBtn.layer.masksToBounds = YES;
    _modifyPwdBtn.layer.cornerRadius = 10.0;
    [_modifyPwdBtn setBackgroundImage:[UIImage createImageWithColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyZdywFontColor]] forState:UIControlStateNormal];
    
    [_findPwdBtn addTarget:self action:@selector(findOldPwd) forControlEvents:UIControlEventTouchUpInside];
    
    [_findPwdBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyZdywFontColor] forState:UIControlStateNormal];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - action

- (void)dissKeyBoard{
    [_pTextFiledOldPwd resignFirstResponder];
    [_pTextFiledNewPwd resignFirstResponder];
    [_pTextFiledNewPwdConfire resignFirstResponder];
}

- (void)findOldPwd{
    FindPwdViewController *findPwdView = [[FindPwdViewController alloc] initWithNibName:NSStringFromClass([FindPwdViewController class]) bundle:nil];
    [self.navigationController pushViewController:findPwdView animated:YES];
    [findPwdView.findPwdErrorBtn setTitleColor:[UIColor colorWithRed:25.0/255 green:151.0/255 blue:216.0/255 alpha:1.0] forState:UIControlStateNormal];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _pTextFiledOldPwd) {
        [_pTextFiledNewPwd becomeFirstResponder];
    } else if (textField == _pTextFiledNewPwd){
        [_pTextFiledNewPwdConfire becomeFirstResponder];
    } else {
        [self dissKeyBoard];
    }
    return YES;
}

// 重新设置输入焦点，弹出输入键盘
- (void) onReSetInput
{
    [_pTextFiledNewPwd becomeFirstResponder];
}

- (void)textFieldDidChange:(UITextField *)TextField
{
    if([_pTextFiledOldPwd.text length] >=6 &&
       [_pTextFiledNewPwd.text length] >= 6 &&
       [_pTextFiledNewPwdConfire.text length] >= 6)
    {
        _modifyPwdBtn.enabled = YES;
    }
}

#pragma mark handle modify pwd

// 确定修改密码
- (IBAction)clickModify:(id)sender;
{
    NSString *strOldPwd = _pTextFiledOldPwd.text;
    NSString *strNewPwd = _pTextFiledNewPwd.text;
    NSString *strNewPwdConfire = _pTextFiledNewPwdConfire.text;
    if (![strOldPwd isEqualToString:[ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPwd]]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"密码错误"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if (0 == [strOldPwd length])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"旧密码不能为空。"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
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
    if (0 == [strNewPwdConfire length])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"请再次输入新密码。"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if (![strNewPwdConfire isEqualToString:strNewPwd])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"两次输入的新密码不一致。"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        _pTextFiledNewPwd.text = @"";
        _pTextFiledNewPwdConfire.text = @"";
        [_pTextFiledNewPwd becomeFirstResponder];
        return;
    }
    if ([strOldPwd isEqualToString:strNewPwd])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"新密码与旧密码一致，无需修改。"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        _pTextFiledNewPwd.text = @"";
        _pTextFiledNewPwdConfire.text = @"";
        return;
    }
    if ([strNewPwdConfire length] < 6 ||  [strNewPwdConfire length] > 16)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"请输入6-16位新密码"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil, nil];
        [alertView show];;
        _pTextFiledNewPwd.text = @"";
        _pTextFiledNewPwdConfire.text = @"";
        return;
    }
    [self.view endEditing:YES];
    [SVProgressHUD showInView:self.view
                       status:@"数据提交中，请稍候..."
             networkIndicator:NO
                         posY:-1
                     maskType:SVProgressHUDMaskTypeClear];
    NSString *strData = @"old_passwd=%@&new_passwd=%@";
    NSString *publicKey=[ZdywCommonFun getAppConfigureInfoWithKey:kZdywDataKeyServerKey];
    //获取老密码
    strOldPwd = [Zdyw_rc4 RC4Encrypt:strOldPwd withKey:publicKey];
    //获取新mim
    strNewPwd = [Zdyw_rc4 RC4Encrypt:strNewPwd withKey:publicKey];
    strData = [NSString stringWithFormat:strData, strOldPwd, strNewPwd];
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceResetPwdSubmit
                                              userInfo:nil
                                              postDict:dic];
}

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
                NSString *strNewPwd = _pTextFiledNewPwd.text;
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

- (void)onSuccess
{
    if([[CallManager shareInstance] sp_is_registered])
    {
        [[CallManager shareInstance] sp_unregister];
    }
    [self.navigationController popViewControllerAnimated:YES];
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
