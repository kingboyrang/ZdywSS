//
//  RechargeInstructionViewController.m
//  ZdywClient
//
//  Created by ddm on 6/19/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "RechargeInstructionViewController.h"

@interface RechargeInstructionViewController ()

@end

@implementation RechargeInstructionViewController

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
    self.title = @"充值说明";
    NSString *path = [[NSBundle mainBundle] pathForResource:@"recharge" ofType:@"html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
    [_textWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
