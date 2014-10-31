//
//  ZdywAppDelegate.h
//  ZdywMini
//
//  Created by mini1 on 14-5-28.
//  Copyright (c) 2014年 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MutilPointDetectController.h"
#import "SystemNoticeView.h"
#import "SysMessageObj.h"

@interface ZdywAppDelegate : UIResponder <UIApplicationDelegate,UIActionSheetDelegate,MutilPointDetectControllerDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) UIWindow          *window;
@property (nonatomic, assign) BOOL              userIsLogined;
@property (nonatomic, assign) BOOL              isNewMsg;
@property (nonatomic, strong) SysMessageObj         *sysMessage;

@property (nonatomic,assign)  BOOL                                  isShowDirectCallView;
@property (nonatomic,assign)  BOOL                                  isShowCallBackView;
@property (nonatomic,strong)  NSDictionary *appConfigure;

+ (ZdywAppDelegate *)appDelegate;

- (void)afterClientActived;

- (void)startCallWithPhoneNumber:(NSString *)phoneNumber
                     contactName:(NSString *)contactName
                       contactID:(NSInteger)contactID;

- (void)callWithContactID:(NSInteger)contactID;

- (void)showLoginView;

- (void)displayUpdateView;

- (void)handleTokenReport;

- (void)showSystemNoticeView;

//获取客户端配置信息
- (id)getClientConfigurationWithKey:(NSString *)aKey;

@end
