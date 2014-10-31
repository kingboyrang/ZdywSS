//
//  WebsiteViewController.h
//  WldhClient
//
//  Created by dyn on 13-8-9.
//  Copyright (c) 2013年 guoling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebsiteViewController : UIViewController
<UIWebViewDelegate>
{
    NSString        *m_strTitle;    // 窗口标题
    NSTimer         *_loadTimerout;
    BOOL            isNeedUPdata;
    NSString        *_urlRequest;
}
@property(nonatomic,retain)IBOutlet UIWebView   *mainWebView;

//设置标题和请求的url
- (void)setTitle:(NSString *)title withURL:(NSString *)urlStr;

@end
