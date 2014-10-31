//
//  bindPhoneNumberViewController.m
//  WldhClient
//
//  Created by ddm on 4/30/14.
//  Copyright (c) 2014 guoling. All rights reserved.
//

#import "BindPhoneNumberViewController.h"
#import "UIImage+Scale.h"
#import "RegexKitLite.h"
#import "ZdywAppDelegate.h"
#import "NewModifyPwdViewController.h"

@interface BindPhoneNumberViewController ()

@property (nonatomic, assign) NSInteger captchaTime;
@property (nonatomic, assign) BOOL      isBindSuccess;

@end

#define ActivatTipView_Tag 10003

@implementation BindPhoneNumberViewController

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
    self.title = @"绑定手机";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _isBindSuccess = NO;
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    tapGr.delegate = self;
    [self.view addGestureRecognizer: tapGr];
    
    UISwipeGestureRecognizer *swipGrUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [swipGrUp setDirection:UISwipeGestureRecognizerDirectionUp];
    swipGrUp.delegate = self;
    [self.view addGestureRecognizer:swipGrUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    swipeDown.delegate = self;
    [self.view addGestureRecognizer:swipeDown];
    
    _captachaTextField.delegate = self;
    
    _captchaTime = 30;
    [self addObservers];
    _captchaBgImageView.layer.borderWidth = 1.0;
    _captchaBgImageView.layer.borderColor = [UIColor colorWithRed:185.0/255.0 green:185.0/255.0 blue:185.0/255.0 alpha:1.0].CGColor;
    _captchaBgImageView.layer.cornerRadius = 10.0;
    
    _numberBgImageView.layer.borderWidth = 1.0;
    _numberBgImageView.layer.borderColor = [UIColor colorWithRed:185.0/255.0 green:185.0/255.0 blue:185.0/255.0 alpha:1.0].CGColor;
    _numberBgImageView.layer.cornerRadius = 10.0;
    
    //[_captchaButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:25.0/255 green:151.0/255 blue:216.0/255 alpha:1.0]] forState:UIControlStateNormal];
    [_captchaButton setBackgroundImage:[UIImage createImageWithColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyZdywFontColor]] forState:UIControlStateNormal];
    _captchaButton.layer.cornerRadius = 10.0;
    _captchaButton.layer.masksToBounds = YES;
    _captchaButton.layer.borderColor = [UIColor colorWithRed:185.0/255.0 green:185.0/255.0 blue:185.0/255.0 alpha:1.0].CGColor;
    [_captchaButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_captchaButton addTarget:self action:@selector(captchaAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_bindPhoneButton setBackgroundImage:[UIImage createImageWithColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyZdywFontColor]] forState:UIControlStateNormal];
    _bindPhoneButton.layer.cornerRadius = 10.0;
    _bindPhoneButton.layer.masksToBounds = YES;
    [_bindPhoneButton setTitle:@"绑定手机号码" forState:UIControlStateNormal];
    [_bindPhoneButton addTarget:self action:@selector(bindPhoneNumberAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBarHidden = NO;
}

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self removeObservers];
}

#pragma mark - APIReceiveData

- (void)receiveGetIdentifyNumber:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    if ([[dic objectForKey:@"result"] intValue] == 0) {
        [SVProgressHUD dismissWithSuccess:[dic objectForKey:@"reason"]
                               afterDelay:1];
        [self countCaptachaTime];
    } else {
        [SVProgressHUD dismissWithError:[dic objectForKey:@"reason"]
    afterDelay:1];
        [_captchaButton setEnabled:YES];
    }
}

- (void)receiveBindNumberData:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    int result = [[dic objectForKey:@"result"] intValue];
    NSString *reason = [dic objectForKey:@"reason"];
    switch (result)
    {
        case 0:
        {
            [ZdywUtils setLocalDataString:self.phoneTextField.text
                                           key:kZdywDataKeyUserPhone];
            _isBindSuccess = YES;
            [SVProgressHUD dismiss];
            [self bindSuccess];
        }
            break;
        default:
        {
            _isBindSuccess = NO;
            [SVProgressHUD dismissWithError:reason afterDelay:2.0];
        }
            break;
    }
}

- (void)bindSuccess
{
    [[ZdywAppDelegate appDelegate] afterClientActived];
    [[ZdywAppDelegate appDelegate] handleTokenReport];
    [[ZdywAppDelegate appDelegate] showSystemNoticeView];
    [ZdywAppDelegate appDelegate].userIsLogined = YES;
    NewModifyPwdViewController *newModifyPwdView = [[NewModifyPwdViewController alloc] initWithNibName:NSStringFromClass([NewModifyPwdViewController class]) bundle:nil];
    [self.navigationController pushViewController:newModifyPwdView animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _captachaTextField) {
        [_bindPhoneButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    return YES;
}

#pragma mark - privateMethod

-(void)viewTapped:(UITapGestureRecognizer*)tapGr
{
    [_captachaTextField resignFirstResponder];
    [_phoneTextField resignFirstResponder];
}

- (void)captchaAction{
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
    [_captchaButton setEnabled:NO];
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

- (void)countCaptachaTime{
    if (_captchaTime > 0) {
        _captchaTime--;
        NSString * getCaptchaTimeStr = [NSString stringWithFormat:@"重新获取(%d)",_captchaTime];
        [_captchaButton setTitle:getCaptchaTimeStr forState:UIControlStateDisabled];
        [self performSelector:@selector(countCaptachaTime) withObject:nil afterDelay:1.0];
    } else {
        _captchaButton.enabled = YES;
        _captchaTime = 30;
        [_captchaButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(countCaptachaTime) object:nil];
    }
}

- (void)bindPhoneNumberAction{
    if (self.phoneTextField.text.length == 0)
    {
        UIAlertView *callAlert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入手机号码"
                                                           delegate:nil cancelButtonTitle:@"我知道了"
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
    if (![_captachaTextField.text length]>0)
    {
        UIAlertView *callAlert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"请输入验证码"                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil];
        [callAlert show];
        return;
    }
    [self.captachaTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
    NSString *strData = @"new_phone=%@&code=%@";
    
    //获取new_phone(新改绑的手机号)
    NSString *strNewPhone = self.phoneTextField.text;
    
    //获取code(短信验证码)
    NSString *strCode = self.captachaTextField.text;
    
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

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

@end
