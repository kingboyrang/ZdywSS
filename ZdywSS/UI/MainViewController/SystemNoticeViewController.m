//
//  SystemNoticeViewController.m
//  ZdywXY
//
//  Created by zhongduan on 14-8-11.
//  Copyright (c) 2014年 zhongduan. All rights reserved.
//

#import "SystemNoticeViewController.h"

@interface SystemNoticeViewController ()

@end

@implementation SystemNoticeViewController


#pragma mark - liftCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //[self addObservers];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.title = @"系统公告";
    [self performSelector:@selector(changeStatusBarStyle) withObject:nil afterDelay:0.1];
    [self performSelector:@selector(InitMainView) withObject:nil afterDelay:0.1];
    
    //[self performSelector:@selector(getactivityInfo) withObject:nil afterDelay:0.1];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    //[self removeObservers];
}

#pragma mark - observers
- (void)changeStatusBarStyle
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}


- (void)addObservers
{
    [[NSNotificationCenter defaultCenter ] addObserver:self
                                              selector:@selector(getLocalDefaualCfg:)
                                                  name:kNotificationDefaultConfigFinish
                                                object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationDefaultConfigFinish object:nil];
}


#pragma mark - HttpReceiveData

// 拉取系统公告
- (void)getLocalDefaualCfg:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    
    switch ([[dic objectForKey:@"result"]intValue])
    {
        case 0:
        {
            NSMutableDictionary *tempDic = [dic objectForKey:@"defaultconfig"];
            NSMutableDictionary *tempDic1 = [tempDic objectForKey:@"bootini"];
            if([tempDic count]>0)
            {
                NSString *activityStr = [tempDic1 objectForKey:@"push_rechargeTips"];
                if([activityStr length] > 0)
                {
                    _noticeTextView.text =  [NSString stringWithFormat:@"       %@",activityStr];
                }
                else
                {
                    _noticeTextView.text = @"";
                }


            }
        }
        break;
        default:
             _noticeTextView.text = @"";
            break;
    }

}


#pragma mark  -PrivateMethod
- (void)getactivityInfo
{
    NSString *strData = @"";
    NSString *strFlag = [ZdywUtils getLocalStringDataValue:kDefaultConfigSameFlag];
    if([strFlag length] > 0)
    {
        strData = [NSString stringWithFormat:@"flag=%@", strFlag];
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setValue:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceDefaultConfigType
                                              userInfo:nil
                                              postDict:dic];

}
- (void)InitMainView
{
    _noticeTextView.font = [UIFont systemFontOfSize:16];
    _noticeTextView.text = _noticeText;
    _noticeTextView.editable =NO;
    if (IOS7)
    {
        _noticeTextView.selectable =YES;
    }
    _noticeTextView.scrollEnabled =YES;
    _noticeTextView.dataDetectorTypes = UIDataDetectorTypeLink|UIDataDetectorTypeNone;
}


@end
