//
//  WebsiteViewController.m
//  WldhClient
//
//  Created by dyn on 13-8-9.
//  Copyright (c) 2013年 guoling. All rights reserved.
//

#import "WebsiteViewController.h"
@interface WebsiteViewController ()

@end

@implementation WebsiteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setTitle:(NSString *)title withURL:(NSString *)urlStr
{
    m_strTitle = title;
    _urlRequest = urlStr;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _loadTimerout = nil;
    [_mainWebView setOpaque:NO];
    [_mainWebView setBackgroundColor:[UIColor clearColor]];
    [_mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlRequest]]];
    [_mainWebView setScalesPageToFit:YES];
    [_mainWebView setDelegate:self];
    isNeedUPdata = YES;
    self.title = m_strTitle;
}

- (void)viewWillAppear:(BOOL)animated
{
    if(isNeedUPdata)
    {
        [SVProgressHUD showInView:self.navigationController.view
                           status:@"请稍候"
                 networkIndicator: NO
                             posY: -1
                         maskType: SVProgressHUDMaskTypeClear];
        
        _loadTimerout = [NSTimer scheduledTimerWithTimeInterval:30
                                                         target:self
                                                       selector:@selector(handleTimerOut)
                                                       userInfo:nil
                                                        repeats:NO];
        isNeedUPdata = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated;
{
    PhoneNetType netType = [ZdywUtils getCurrentPhoneNetType];
    if(netType == PNT_UNKNOWN)
    {
        if(_loadTimerout)
        {
            [_loadTimerout invalidate];
            _loadTimerout = nil;
            [SVProgressHUD dismissWithError: @"请检查您的网络后重试" afterDelay:1.0];
        }
    }
}

-(void)handleTimerOut
{
    [SVProgressHUD dismiss];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma  mark
#pragma  mark UIWebViewDelegate

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    if(_loadTimerout)
    {
        [_loadTimerout invalidate];
        _loadTimerout = nil;
    }
    [SVProgressHUD dismiss];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"webview didFailLoadWithError %@ , and err is %@",webView.debugDescription, error.debugDescription);
}
@end
