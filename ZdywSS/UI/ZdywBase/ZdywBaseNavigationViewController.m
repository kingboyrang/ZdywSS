//
//  ZdywBaseNavigationViewController.m
//  ZdywClient
//
//  Created by ddm on 6/16/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "ZdywBaseNavigationViewController.h"

@interface ZdywBaseNavigationViewController ()

@end

@implementation ZdywBaseNavigationViewController

#pragma mark - LiftCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithRootViewController:(UIViewController *)rootViewController
{
    if (self = [super initWithRootViewController:rootViewController])
    {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            
            [self.navigationBar setBarTintColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyNavBarBgColor]];
            [self.navigationBar setTintColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyNavBarBackGroundColor]];
            //[self.navigationBar setTintColor:kNavigationBarBackGroundColor];
        }
        else
        {
            //[self.navigationBar setTintColor:kNavigationBarBgColor];
            [self.navigationBar setTintColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyNavBarBgColor]];
        }
        BOOL hasShadow=[ZdywUtils getLocalDataBoolen:kZdywDataKeyNavBarTitleHasShadow];
        NSDictionary *fontDictionary=[ZdywUtils getLocalIdDataValue:kZdywDataKeyNavBarTitleFontSize];
        UIFont *font=[UIFont fontWithName:[fontDictionary objectForKey:@"name"] size:[[fontDictionary objectForKey:@"size"] floatValue]];
        
        UIColor *navTitleColor=[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyNavBarTitleFontColor];
        if (hasShadow) {//有阴影
            UIColor *shadowColor=[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyNavBarTitleShadowColor alpha:0.8];
            [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                        navTitleColor,
                                                        UITextAttributeTextColor,
                                                        shadowColor,
                                                        UITextAttributeTextShadowColor,
                                                        [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
                                                        UITextAttributeTextShadowOffset,
                                                        font,
                                                        UITextAttributeFont,nil]];
        }else{
            [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                        navTitleColor,
                                                        UITextAttributeTextColor,
                                                        font,
                                                        UITextAttributeFont,nil]];
        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
