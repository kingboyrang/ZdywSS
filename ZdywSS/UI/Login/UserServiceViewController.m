//
//  UserServiceViewController.m
//  ZdywClient
//
//  Created by ddm on 6/19/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "UserServiceViewController.h"
#import "UIImage+Scale.h"

@interface UserServiceViewController ()

@end

@implementation UserServiceViewController

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

    NSString *path = [[NSBundle mainBundle] pathForResource:@"service_term_one" ofType:@"html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
    [_textWebView loadRequest:request];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    UIImage * loginDefaultImage = [[[UIImage imageNamed:@"login_btn_default"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    [_makesureBtn setBackgroundImage:loginDefaultImage forState:UIControlStateNormal];
    [_makesureBtn addTarget:self action:@selector(makesureAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.title = @"服务条款";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BtnAction

- (void)makesureAction{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
