//
//  CallTypeViewController.m
//  ZdywClient
//
//  Created by ddm on 6/20/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "CallTypeViewController.h"

@interface CallTypeViewController ()

@end

@implementation CallTypeViewController

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
    self.title = @"直拨/回拨介绍";
    NSString *path = [[NSBundle mainBundle] pathForResource:@"direct" ofType:@"html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
    [_textWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
