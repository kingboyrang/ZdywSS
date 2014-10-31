//
//  ChangeBindPhoneViewController.m
//  ZdywClient
//
//  Created by ddm on 6/21/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "FindPwdViewController.h"
#import "ChangeBindPhoneViewController.h"
#import "RegexKitLite.h"
#import "UIImage+Scale.h"

@interface ChangeBindPhoneViewController (){
    NSInteger _captchaTime;
}

@end

@implementation ChangeBindPhoneViewController

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
   _oldPwdTextBg.hidden  =YES;
   _oldPwdTextField.hidden =YES;
    _findPwdBtn.hidden =YES;
    // Do any additional setup after loading the view from its nib.
    self.title = @"改绑手机号";
    [self adjustUI];
    _captchaTime = 30;
    [self.view setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dissmissKeyBoard)];
    tapGr.delegate = self;
    [self.view addGestureRecognizer:tapGr];
    
    UISwipeGestureRecognizer *swipGrUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dissmissKeyBoard)];
    [swipGrUp setDirection:UISwipeGestureRecognizerDirectionUp];
    swipGrUp.delegate = self;
    [self.view addGestureRecognizer:swipGrUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dissmissKeyBoard)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    swipeDown.delegate = self;
    [self.view addGestureRecognizer:swipeDown];
    
    [self addObservers];
    
     [_findPwdBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyZdywFontColor] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self removeObservers];
}

#pragma mark - Observers

- (void)addObservers{
    //添加绑定手机号和获取验证码通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveBindNumberData:)
                                                 name:kNotificationBindNewPhoneFinish
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveGetIdentifyNumber:)
                                                 name:kNotificationChangePhoneFinish
                                               object:nil];
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationChangePhoneFinish object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationBindNewPhoneFinish object:nil];
}

#pragma mark - PrivateMethod

- (void)adjustUI{
    [_findPwdBtn addTarget:self action:@selector(findOldPwd) forControlEvents:UIControlEventTouchUpInside];
    _phoneLable.text = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPhone];
    
    [_oldPwdTextField setDelegate:self];
    [_phoneTextField setDelegate:self];
    [_verificaTextField setDelegate:self];
    
    _oldPwdTextBg.layer.masksToBounds = YES;
    _oldPwdTextBg.layer.cornerRadius = 10.0;
    _oldPwdTextBg.layer.borderWidth = 1.0;
    _oldPwdTextBg.layer.borderColor = [UIColor colorWithRed:197.0/255 green:197.0/255 blue:197.0/255 alpha:1.0].CGColor;
    
    _pwdTextBg.layer.masksToBounds = YES;
    _pwdTextBg.layer.cornerRadius = 10.0;
    _pwdTextBg.layer.borderWidth = 1.0;
    _pwdTextBg.layer.borderColor = [UIColor colorWithRed:197.0/255 green:197.0/255 blue:197.0/255 alpha:1.0].CGColor;
    
    _verificaTextBg.layer.masksToBounds = YES;
    _verificaTextBg.layer.cornerRadius = 10.0;
    _verificaTextBg.layer.borderWidth = 1.0;
    _verificaTextBg.layer.borderColor = [UIColor colorWithRed:197.0/255 green:197.0/255 blue:197.0/255 alpha:1.0].CGColor;
    UIImage * loginDefaultImage = [[[UIImage imageNamed:@"login_btn_default"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    UIImage * loginLightImage = [[[UIImage imageNamed:@"login_btn_light"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    
    _sendVericaBtn.layer.masksToBounds = YES;
    _sendVericaBtn.layer.cornerRadius = 10.0;
    [_sendVericaBtn setBackgroundImage:loginDefaultImage forState:UIControlStateNormal];
    [_sendVericaBtn setBackgroundImage:loginLightImage forState:UIControlStateHighlighted];

    //[_sendVericaBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:25.0/255 green:151.0/255 blue:216.0/255 alpha:1.0]] forState:UIControlStateNormal];
    [_sendVericaBtn addTarget:self action:@selector(captchaAction) forControlEvents:UIControlEventTouchUpInside];
    
    _changPhoneBtn.layer.masksToBounds = YES;
    _changPhoneBtn.layer.cornerRadius = 10.0;
    [_changPhoneBtn setBackgroundImage:loginDefaultImage forState:UIControlStateNormal];
    [_changPhoneBtn setBackgroundImage:loginLightImage forState:UIControlStateHighlighted];
    //[_changPhoneBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:25.0/255 green:151.0/255 blue:216.0/255 alpha:1.0]] forState:UIControlStateNormal];
    [_changPhoneBtn addTarget:self action:@selector(bindPhoneNumberAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)countCaptachaTime
{
    if (_captchaTime > 0)
    {
        [_sendVericaBtn setEnabled:NO];
        _captchaTime--;
        NSString * getCaptchaTimeStr = [NSString stringWithFormat:@"(%ds)",_captchaTime];
        [_sendVericaBtn setTitle:@"正在获取      " forState:UIControlStateDisabled];
         _timeLableText.text = getCaptchaTimeStr;
        [self performSelector:@selector(countCaptachaTime) withObject:nil afterDelay:1.0];
    }
    else
    {
        _sendVericaBtn.enabled = YES;
        _captchaTime = 30;
        [_sendVericaBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(countCaptachaTime) object:nil];
        _timeLableText.text = @"";
    }
}

- (void)BacktoRootView
{
    for (UIViewController *temp in self.navigationController.viewControllers)
    {
        if ([temp.title isEqualToString:@"设置"])
        {
            [self.navigationController popToViewController:temp animated:YES];
        }
    }
}

#pragma mark - APIReceiveData

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
            [self countCaptachaTime];
            break;
        }
        default:
        {
            [SVProgressHUD dismissWithError:str afterDelay:2.0];
            [_sendVericaBtn setEnabled:YES];
        }
            break;
    }
}

- (void)receiveBindNumberData:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    int result = [[dic objectForKey:@"result"] intValue];
    NSString *str = [dic objectForKey:@"reason"];
    switch (result)
    {
        case 0:
        {
            [ZdywUtils setLocalDataString:self.phoneTextField.text
                                      key:kZdywDataKeyUserPhone];
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

#pragma mark - TouchAction

- (void)findOldPwd{
    FindPwdViewController *findPwdView = [[FindPwdViewController alloc] initWithNibName:NSStringFromClass([FindPwdViewController class]) bundle:nil];
    [self.navigationController pushViewController:findPwdView animated:YES];
    [findPwdView.findPwdErrorBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyZdywFontColor] forState:UIControlStateNormal];
}

- (void)captchaAction
{
//    if (_oldPwdTextField.text.length == 0) {
//        UIAlertView *callAlert = [[UIAlertView alloc] initWithTitle:nil
//                                                            message:@"请输入密码"
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"我知道了"
//                                                  otherButtonTitles:nil];
//        [callAlert show];
//        return;
//    }
//    if (![_oldPwdTextField.text isEqualToString:[ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPwd]]) {
//        UIAlertView *callAlert = [[UIAlertView alloc] initWithTitle:nil
//                                                            message:@"密码错误"
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"我知道了"
//                                                  otherButtonTitles:nil];
//        [callAlert show];
//        return;
//    }
    if (self.phoneTextField.text.length == 0)
    {
        UIAlertView *callAlert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"请输入新手机号码"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil];
        [callAlert show];
        return;
    }
    else
    {
        if(![self.phoneTextField.text isMatchedByRegex:@"^\\d{11}$"])
        {
            UIAlertView *callAlert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"请输入有效的手机号码"
                                                               delegate:nil
                                                      cancelButtonTitle:@"我知道了"
                                                      otherButtonTitles:nil];
            [callAlert show];
            return;
        }
    }
    [self.view endEditing:TRUE];
    [_sendVericaBtn setEnabled:NO];
    NSString *strData = @"passwd=%@&new_phone=%@";
    //获取passwd(密码要md5)
    NSString *strPwd = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPwd];
    strPwd = [[Zdyw_md5 shareUtility] md5:strPwd];
    
    //获取new_phone(新绑定的手机号)
    NSString *strNewPhone = self.phoneTextField.text;
    
    strData = [NSString stringWithFormat:strData, strPwd, strNewPhone];
    
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

- (void)bindPhoneNumberAction{
//    if ([_oldPwdTextField.text length] == 0) {
//        UIAlertView *callAlert = [[UIAlertView alloc] initWithTitle:nil
//                                                            message:@"请输入密码"
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"我知道了"
//                                                  otherButtonTitles:nil];
//        [callAlert show];
//        return;
//    }
//    if (![_oldPwdTextField.text isEqualToString:[ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPwd]]) {
//        UIAlertView *callAlert = [[UIAlertView alloc] initWithTitle:nil
//                                                            message:@"密码错误"
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"我知道了"
//                                                  otherButtonTitles:nil];
//        [callAlert show];
//        return;
//    }
    if (self.phoneTextField.text.length == 0)
    {
        UIAlertView *callAlert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"请输入新手机号码"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil];
        [callAlert show];
        return;
    } else {
        if(![self.phoneTextField.text isMatchedByRegex:@"^\\d{11}$"])
        {
            UIAlertView *callAlert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"请输入有效的手机号码"
                                                               delegate:nil
                                                      cancelButtonTitle:@"我知道了"
                                                      otherButtonTitles:nil];
            [callAlert show];
            return;
        }
    }
    if (![_verificaTextField.text length]>0)
    {
        UIAlertView *callAlert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"请输入验证码"                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil];
        [callAlert show];
        return;
    }
    [self dissmissKeyBoard];
    NSString *strData = @"phone=%@&code=%@";
    
    //获取new_phone(新改绑的手机号)
    NSString *strNewPhone = self.phoneTextField.text;
    
    //获取code(短信验证码)
    NSString *strCode = self.verificaTextField.text;
    
    strData = [NSString stringWithFormat:strData, strNewPhone, strCode];
    
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

- (void)dissmissKeyBoard{
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0) {
        [self.mianScrollView setContentOffset:CGPointMake(0, -64)];
    } else {
        [self.mianScrollView setContentOffset:CGPointMake(0, 0)];
    }
    [_oldPwdTextField resignFirstResponder];
    [_phoneTextField resignFirstResponder];
    [_verificaTextField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if ((textField == _phoneTextField)||(textField == _verificaTextField)) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0) {
            [self.mianScrollView setContentOffset:CGPointMake(0, 60)];
        }else {
            [self.mianScrollView setContentOffset:CGPointMake(0, 100)];
        }
    } else {
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0) {
        [self.mianScrollView setContentOffset:CGPointMake(0, -64)];
        }else {
            [self.mianScrollView setContentOffset:CGPointMake(0, 0)];
        }
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (textField == _verificaTextField)
    {
        return (range.location<4);
    }
    return (range.location<11);
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _oldPwdTextField) {
        [_phoneTextField becomeFirstResponder];
    } else if (textField == _phoneTextField){
        [self dissmissKeyBoard];
    }else if (_verificaTextField == textField){
        [_changPhoneBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
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
