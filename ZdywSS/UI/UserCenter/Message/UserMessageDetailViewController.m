//
//  UserMessageDetailViewController.m
//  ZdywClient
//
//  Created by ddm on 7/4/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "UserMessageDetailViewController.h"

@interface UserMessageDetailViewController ()

@end

@implementation UserMessageDetailViewController

#pragma mark - liftCycle

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
    self.title = @"详情";
    _userMsgStrTextView.showsVerticalScrollIndicator = YES;
    _userMsgStrTextView.showsHorizontalScrollIndicator = NO;
    _userMsgStrTextView.editable = NO;
    _userMsgStrTextView.scrollEnabled = YES;
    _userMsgStrTextView.text = _userMsgStr;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PrivateMethod

- (void)setUserMsgStr:(NSString *)userMsgStr{
    _userMsgStr = userMsgStr;
    _userMsgStrTextView.text = _userMsgStr;
}

@end
