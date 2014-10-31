//
//  FindPwdErrorViewController.m
//  ZdywClient
//
//  Created by ddm on 6/16/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "FindPwdErrorViewController.h"
#import "UIImage+Scale.h"
#import "ZdywCommonFun.h"

@interface FindPwdErrorViewController ()

@end

@implementation FindPwdErrorViewController

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
    // Do any additional setup after loading the view from its nib.
    _serviceLable.text = [ZdywCommonFun getCustomerPhone];
    _serviceTimeLable.text =  [NSString stringWithFormat:@"客服时间：%@",[ZdywCommonFun getServiceTime]];
    [_callServiceBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:86.0/255 green:193.0/255 blue:3.0/255 alpha:1.0]] forState:UIControlStateNormal];
    _callServiceBtn.layer.cornerRadius = 10.0;
    _callServiceBtn.layer.borderWidth = 1.0;
    _callServiceBtn.layer.masksToBounds = YES;
    _callServiceBtn.layer.borderColor = [UIColor clearColor].CGColor;
    [_callServiceBtn addTarget:self action:@selector(callServiceNum) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.title = @"找回密码出错";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BtnAction

- (void)callServiceNum{
    NSString *strphone = [ZdywCommonFun getCustomerPhone];
    NSString *strURL = [NSString stringWithFormat:@"tel://%@", strphone];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:strURL]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strURL]];
    }
}

@end
