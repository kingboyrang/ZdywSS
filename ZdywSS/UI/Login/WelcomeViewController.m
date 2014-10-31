//
//  WelcomeViewController.m
//  ZdywXY
//
//  Created by zhongduan on 14-8-1.
//  Copyright (c) 2014年 zhongduan. All rights reserved.
//

#import "WelcomeViewController.h"
#import "UIImage+Scale.h"
#import "UserServiceViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

#pragma mark - liftCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [self InitMainView];
    
    [self.oldUserBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyZdywFontColor] forState:UIControlStateNormal];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.title = @"返回";
    [self performSelector:@selector(changeStatusBarStyle) withObject:nil afterDelay:0.1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - observers
- (void)changeStatusBarStyle
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}
#pragma mark  -PrivateMethod
- (void)InitMainView
{
    UIImage * loginDefaultImage = [[[UIImage imageNamed:@"login_btn_default"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    UIImage * loginLightImage = [[[UIImage imageNamed:@"login_btn_light"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    
    UIImage * oldUserDefaultImage = [[[UIImage imageNamed:@"登陆-常规"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    UIImage * oldUseLightImage = [[[UIImage imageNamed:@"登陆-down"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    
    [_theNewUserbtn setBackgroundImage:loginDefaultImage forState:UIControlStateNormal];
    [_theNewUserbtn setBackgroundImage:loginLightImage forState:UIControlStateHighlighted];
    [_theNewUserbtn addTarget:self action:@selector(newUserAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_oldUserBtn setBackgroundImage:oldUserDefaultImage forState:UIControlStateNormal];
    [_oldUserBtn setBackgroundImage:oldUseLightImage forState:UIControlStateHighlighted];
    [_oldUserBtn addTarget:self action:@selector(oldUserAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_showServiceBtn addTarget:self action:@selector(showServiceTermView) forControlEvents:UIControlEventTouchUpInside];
   
}

#pragma mark -btnAction
- (void)newUserAction
{

    RegisterViewController * loginView   = [[RegisterViewController alloc] initWithNibName:NSStringFromClass([RegisterViewController class]) bundle:nil];
    [self.navigationController pushViewController:loginView animated:YES];
}

- (void)oldUserAction
{
    LoginViewController * loginView   = [[LoginViewController alloc] initWithNibName:NSStringFromClass([LoginViewController class]) bundle:nil];
    [self.navigationController pushViewController:loginView animated:YES];

}
- (void)showServiceTermView
{
    UserServiceViewController *serviceTermView = [[UserServiceViewController alloc] initWithNibName:NSStringFromClass([UserServiceViewController class]) bundle:nil];
    [self.navigationController pushViewController:serviceTermView animated:YES];
}
@end
