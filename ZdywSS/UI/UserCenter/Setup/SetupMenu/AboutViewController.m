//
//  AboutViewController.m
//  ZdywClient
//
//  Created by ddm on 6/21/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "AboutViewController.h"
#import "ZdywUtils.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

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
    self.title = @"关于";
    NSString *clientVerStr = [ZdywUtils getLocalIdDataValue:kZdywDataKeyVersion];
    self.versionInfo.text = [NSString stringWithFormat:@"版本号：V %@",clientVerStr];
    if (!kZdywClientIsIphone5) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            _versionInfo.frame = CGRectMake(85, 220, 151, 29);
            _ddLogoImageView.frame = CGRectMake(100, 75, 120, 129);
        } else{
            _versionInfo.frame = CGRectMake(85, 180, 151, 29);
            _ddLogoImageView.frame = CGRectMake(100, 35, 120, 129);
        }
    }
    _wordsLable.numberOfLines=0;
    _wordsLable.lineBreakMode=NSLineBreakByWordWrapping;
    NSString *displyName=[ZdywCommonFun getAppConfigureInfoWithKey:kZdywDataKeyDisplayName];
    NSString *msg=[_wordsLable.text stringByReplacingOccurrencesOfString:@"说说" withString:displyName];
    _wordsLable.text=msg;
    [_wordsLable sizeToFit];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
