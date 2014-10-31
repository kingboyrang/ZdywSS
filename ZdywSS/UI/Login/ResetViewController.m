//
//  ResetViewController.m
//  ZdywXY
//
//  Created by zhongduan on 14-8-7.
//  Copyright (c) 2014年 zhongduan. All rights reserved.
//

#import "ResetViewController.h"
#import "UIImage+Scale.h"
#import "VerifyViewController.h"

@interface ResetViewController ()
{
    NSString *   _phoneText;
}

@end

@implementation ResetViewController

#pragma mark - liftCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self InitMainView];
    [self addObservers];
        // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.title = @"修改密码";
    [self performSelector:@selector(changeStatusBarStyle) withObject:nil afterDelay:0.1];
    if (!kZdywClientIsIphone5 && _showType)
    {
        if(IOS7)
        {
            [self.mainScrollView setContentOffset:CGPointMake(0, -50)];
        }
        else
        {
            [self.mainScrollView setContentOffset:CGPointMake(0, -100)];
        }
            
    }
    else if(!kZdywClientIsIphone5&&!_showType)
    {
        [self.mainScrollView setContentOffset:CGPointMake(0, -50)];
    }

    if (kZdywClientIsIphone5)
    {
        [self.mainScrollView setContentOffset:CGPointMake(0, 50)];
    }
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
    [[NSNotificationCenter defaultCenter ] addObserver:self
                                              selector:@selector(receiveDataForModifyPwd:)
                                                  name:kNotificationResetPwdFinish
                                                object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationChangePhoneFinish object:nil];
}

#pragma mark - HttpReceiveData

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
                str = [NSString stringWithFormat:@"验证码已经发到%@手机上，请注意查收短信",_phoneText];
                [SVProgressHUD dismissWithSuccess:str afterDelay:2.0];
                [self performSelector:@selector(showVerifyView) withObject:nil afterDelay:2];
                
            }
                break;
            default:
            {
                [SVProgressHUD dismissWithError:str afterDelay:2];
            }
                break;
        }
    }
}

#pragma mark  -PrivateMethod

- (void)showVerifyView
{
    VerifyViewController * verifyView   = [[VerifyViewController alloc] initWithNibName:NSStringFromClass([VerifyViewController class]) bundle:nil];
    verifyView.userNewPSW = _userPSWText.text;
    verifyView.userPhoneNo = _phoneText;
    [self.navigationController pushViewController:verifyView animated:YES];
}

- (void)InitMainView
{
    if (!_showType)
    {
        _lableText.hidden = YES;
        NSString * strPhone = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPhone];
        if ([strPhone length] >0)
        {
            NSString * TextPhone =[NSString stringWithFormat:@"%@ %@ %@",[strPhone substringWithRange:NSMakeRange(0,3)],[strPhone substringWithRange:NSMakeRange(3,4)],[strPhone substringWithRange:NSMakeRange(7,4)]];
            _phoneNoText.text = TextPhone;

        }
    }
    _phoneNoBg.layer.borderColor = [UIColor colorWithRed:183.0/255 green:183.0/255 blue:183.0/255 alpha:1.0].CGColor;
    _phoneNoBg.layer.masksToBounds = YES;
    _phoneNoBg.layer.cornerRadius = 10.0;
    _phoneNoBg.layer.borderWidth = 1.0;
    
    _userPSWTextBg.layer.borderColor = [UIColor colorWithRed:183.0/255 green:183.0/255 blue:183.0/255 alpha:1.0].CGColor;
    _userPSWTextBg.layer.masksToBounds = YES;
    _userPSWTextBg.layer.cornerRadius = 10.0;
    _userPSWTextBg.layer.borderWidth = 1.0;
    
    _checkNewPSWTextBg.layer.borderColor = [UIColor colorWithRed:183.0/255 green:183.0/255 blue:183.0/255 alpha:1.0].CGColor;
    _checkNewPSWTextBg.layer.masksToBounds = YES;
    _checkNewPSWTextBg.layer.cornerRadius = 10.0;
    _checkNewPSWTextBg.layer.borderWidth = 1.0;
    

    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldResponed:)];
    tapGr.delegate = self;
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:tapGr];
    
    UIImage * loginDefaultImage = [[[UIImage imageNamed:@"login_btn_default"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    UIImage * loginLightImage = [[[UIImage imageNamed:@"login_btn_light"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    
    _nextStepBtn.titleLabel.numberOfLines = 0;
    [_nextStepBtn setBackgroundImage:loginDefaultImage forState:UIControlStateNormal];
    [_nextStepBtn setBackgroundImage:loginLightImage forState:UIControlStateHighlighted];
    [_nextStepBtn addTarget:self action:@selector(nextStepBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    
}
- (void)textViewResignFirstResponse
{
    if (!kZdywClientIsIphone5&&_showType)
    {
        [self.mainScrollView setContentOffset:CGPointMake(0, -100)];
    }
    else if(!kZdywClientIsIphone5&&!_showType)
    {
        [self.mainScrollView setContentOffset:CGPointMake(0, -50)];
    }
    [_phoneNoText resignFirstResponder];
    [_userPSWText resignFirstResponder];
    [_checkNewPSWText resignFirstResponder];
}
#pragma mark - btnAction

-(void)nextStepBtnAction
{
    
    [self textViewResignFirstResponse];
     _phoneText = [_phoneNoText.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *tipStr = nil;
    
    if ([_phoneNoText.text length]<13)
    {
        tipStr = @"你输入的手机位数有误,请输入11位手机号码";
    }
    else if (![_phoneNoText.text hasPrefix:@"1"])
    {
        tipStr = @"你输入的号码格式有误";
    }
    else if ([_userPSWText.text length]<6)
    {
        tipStr = @"密码位数有误，请输入6-16位新密码";
    }
    else if (![_userPSWText.text isEqualToString:_checkNewPSWText.text])
    {
        tipStr = @"两次输入的密码不一致";
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
    [self performSelector:@selector(showVerifyView) withObject:nil afterDelay:0.1];
    

}

- (void)textFieldResponed:(UITapGestureRecognizer*)tapGr
{
    [self textViewResignFirstResponse];


}

#pragma mark - textField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    if (textField == _phoneNoText)
    {
        if ((range.location ==3 ||range.location ==8) && string.length>0)
        {
            textField.text = [NSString stringWithFormat:@"%@ ",textField.text];
        }
    }
    else
    {
        return (range.location<16);

    }
    return (range.location<13);
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!kZdywClientIsIphone5)
    {
        [self.mainScrollView setContentOffset:CGPointMake(0, -15)];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self textViewResignFirstResponse];
    return YES;
}
@end
