//
//  FindPwdViewController.m
//  ZdywClient
//
//  Created by ddm on 6/12/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "FindPwdViewController.h"
#import "UIImage+Scale.h"
#import "FindPwdErrorViewController.h"
#import "RegexKitLite.h"
#import "ZdywServiceManager.h"
#import "SVProgressHUD.h"

@interface FindPwdViewController ()
{
    NSInteger _count;
}

@end

@implementation FindPwdViewController

#pragma mark - LifeCycle

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
    _count = 30;
    [self addObservers];
    // Do any additional setup after loading the view from its nib.
    _phoneTextFieldBg.layer.borderColor = [UIColor colorWithRed:183.0/255 green:183.0/255 blue:183.0/255 alpha:1.0].CGColor;
    _phoneTextFieldBg.layer.masksToBounds = YES;
    _phoneTextFieldBg.layer.cornerRadius = 10.0;
    _phoneTextFieldBg.layer.borderWidth = 1.0;
    
    [_findPwdBtn setBackgroundImage:[UIImage createImageWithColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyZdywFontColor]] forState:UIControlStateNormal];
    _findPwdBtn.layer.cornerRadius = 10.0;
    _findPwdBtn.layer.masksToBounds = YES;
    _findPwdBtn.layer.borderColor = [UIColor colorWithRed:185.0/255.0 green:185.0/255.0 blue:185.0/255.0 alpha:1.0].CGColor;
    [_findPwdBtn addTarget:self action:@selector(findPwdBackAction) forControlEvents:UIControlEventTouchUpInside];
    [_findPwdErrorBtn addTarget:self action:@selector(findPwdErrorAction) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldResponed:)];
    tapGr.delegate = self;
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:tapGr];
    
    _findPwdTipView.layer.cornerRadius = 10.0;
    _findPwdTipView.layer.masksToBounds = YES;
    _findPwdTipView.layer.borderColor = [UIColor colorWithRed:132.0/255 green:132.0/255 blue:132.0/255 alpha:1.0].CGColor;
    _findPwdTipView.layer.borderWidth = 1.0;
    _findPwdTipView.hidden = YES;
    
    [_findPwdErrorBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyZdywFontColor] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.title = @"找回密码";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self removeObservers];
}

- (void)textFieldResponed:(UITapGestureRecognizer*)tapGr{
    [_phoneTextField resignFirstResponder];
}

#pragma mark - obsersAction

- (void)addObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findPwdServiceBack:) name:kNotificationFindPwdFinish object:nil];
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationFindPwdFinish object:nil];
}

#pragma mark - BtnAction

- (void)findPwdBackAction{
    if (![_phoneTextField.text isMatchedByRegex:@"^\\d{11}$"])
    {
        UIAlertView *callAlert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"请输入绑定的手机号码"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil];
        [callAlert show];
        return;
    }
    [_phoneTextField resignFirstResponder];
    NSString *strData = @"account=%@";
    //获取account(手机号)
    NSString *strAccount = _phoneTextField.text;
    strData = [NSString stringWithFormat:strData, strAccount];
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceFindPwdType userInfo:nil postDict:dic];
    [SVProgressHUD showInView:self.view
                       status:@"数据提交中，请稍候..."
             networkIndicator:NO
                         posY:-1
                     maskType:SVProgressHUDMaskTypeClear];
}

- (void)findPwdErrorAction{
    FindPwdErrorViewController *findPwdErrorView = [[FindPwdErrorViewController alloc] initWithNibName:NSStringFromClass([FindPwdErrorViewController class]) bundle:nil];
    [self.navigationController pushViewController:findPwdErrorView animated:YES];
}

#pragma mark - PrivateMethod

- (void)findPwdServiceBack: (NSNotification *)notic{
    NSDictionary *dic = [notic userInfo];
    
    if([dic objectForKey:@"result"] )
    {
        int nRet = [[dic objectForKey:@"result"] intValue];
        NSString *str = [dic objectForKey:@"reason"];
        
        switch (nRet)
        {
            case 0:
            {
                [SVProgressHUD dismissWithSuccess:str afterDelay:2.0];
                
                [self performSelector:@selector(onSuccess) withObject:nil afterDelay:2.0];
            }
                break;
                
            default:
            {
                [SVProgressHUD dismissWithError:str afterDelay:2.0];;
            }
                break;
        }
    }
}
- (void)onSuccess{
    if (_count > 0) {
        [_findPwdBtn setEnabled:NO];
        [self performSelector:@selector(onSuccess) withObject:nil afterDelay:1.0];
        NSString *pwdStr = [NSString stringWithFormat:@"%d秒后重新找回",_count];
        [_findPwdBtn setTitle:pwdStr forState:UIControlStateDisabled];
        _count--;
    }else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onSuccess) object:nil];
        _count = 30;
        [_findPwdBtn setEnabled:YES];
        [_findPwdBtn setTitle:@"找回密码" forState:UIControlStateNormal];
    }
    
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
