//
//  ZdywAppDelegate.m
//  ZdywMini
//
//  Created by mini1 on 14-5-28.
//  Copyright (c) 2014年 Guoling. All rights reserved.
//

#import "ZdywAppDelegate.h"
#import "MainMenuViewController.h"
#import "CustomNavigationController.h"
#import "ContactManager.h"
#import "LoginViewController.h"
#import "RichMessageEngine.h"
#import "CallManager.h"
#import "RechargeCellNode.h"
#import "CallInfoNode.h"
#import "CallWrapper.h"
#import "SelectVPSController.h"
#import "ZdywBaseNavigationViewController.h"
#import "PayTypeNode.h"
#import "WelcomeViewController.h"
#import "ZdywServiceQueue.h"

#define Update_tag                      1003
#define ForceUpdate_tag                 1004
#define kExpirationDateTip_Tag          1005

@interface ZdywAppDelegate ()

@property (nonatomic, strong) WelcomeViewController                 *welComeView;
@property (nonatomic, strong) LoginViewController                   *loginView;
@property (nonatomic, strong) ZdywBaseNavigationViewController      *tempNavigation;
@property (nonatomic, strong) ContactNode                           *contactNodeInfo;
@property (nonatomic, strong) MainMenuViewController                *mainView;



@end

@implementation ZdywAppDelegate

+ (ZdywAppDelegate *)appDelegate
{
    return (ZdywAppDelegate *)[UIApplication sharedApplication].delegate;
}

#pragma mark - LiftCycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    self.isNewMsg = NO;
    [self createContactServer];     //初始化联系人相关数据
    [[ContactManager shareInstance] loadAllContact];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    // Override point for customization after application launch.
    [self initAppSetting];
    [self initSoftPhone];           //初始化softphone组件
    //初始化vps多点接入
    [[SelectVPSController shareInstance] selectOptimalVPS];
    //初始化http server多点接入
    [MutilPointDetectController shareInstance].delegate = self;
    
    [self createMainView];
    [self checkUpdateInfo];
    //注册远程push
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {//ios8推送注册
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
    }
    return YES;
}

// Handle an actual notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"%@",userInfo);
    if (UIApplicationStateActive == application.applicationState) {
        NSLog(@"didReceiveRemoteNotification UIApplicationStateActive");
        [self performSelector:@selector(getpushmsg) withObject:nil afterDelay:5.0];
//        [self didResponseNotifications:userInfo]; 反馈接口后台Push地方使用
    } else if (UIApplicationStateInactive == application.applicationState) {
        NSLog(@"didReceiveRemoteNotification UIApplicationStateInactive");
        [self performSelector:@selector(getpushmsg) withObject:nil afterDelay:5.0];
        //        [self didResponseNotifications:userInfo];     //反馈接口后台Push地方使用
    } else {
        NSLog(@"didReceiveRemoteNotification UIApplicationStateBackground");
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[MutilPointDetectController shareInstance] stopTestHttpServer];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self performSelectorInBackground:@selector(afterClientActived) withObject:nil];
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark retrieve the device token
-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    NSString *results = [NSString stringWithFormat:@"Badge: %@, Alert:%@, Sound: %@",
                         (rntypes & UIRemoteNotificationTypeBadge) ? @"Yes" : @"No",
                         (rntypes & UIRemoteNotificationTypeAlert) ? @"Yes" : @"No",
                         (rntypes & UIRemoteNotificationTypeSound) ? @"Yes" : @"No"];
    NSLog(@"results = %@", results);
    NSString *status = [NSString stringWithFormat:@"Registration succeeded."];
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken status: %@", status);
    NSString *strDeviceToken = [NSString stringWithFormat:@"%@", [deviceToken description]];
    strDeviceToken = [strDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    strDeviceToken = [strDeviceToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    strDeviceToken = [strDeviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    NSLog(@"strDeviceToken = %@", strDeviceToken);
    if([strDeviceToken length] > 0)
    {
        [ZdywUtils setLocalDataString:strDeviceToken key:kRemotePushDeviceToken];
    }
    if(![ZdywUtils getLocalDataBoolen:kRemotePushTokenReportFlag])   //未上传过token
    {
        bool bAlertFlag = rntypes & UIRemoteNotificationTypeAlert;
        [ZdywUtils setLocalDataBoolen:bAlertFlag key:kRemotePushTokenState];
        [self handleTokenReport];
    }
    else
    {
        bool bAlertFlag = rntypes & UIRemoteNotificationTypeAlert;
        bool bFlag = [ZdywUtils getLocalDataBoolen:kRemotePushTokenState];
        if(bFlag != bAlertFlag) //当前的状态和以前的状态相比有变化
        {
            [ZdywUtils setLocalDataBoolen:bAlertFlag key:kRemotePushTokenState];
            [self handleTokenReport];
        }
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    NSLog(@"url = %@", url);
    NSString *brand=[ZdywCommonFun getAppConfigureInfoWithKey:kZdywDataKeyBrandID];
    if([[url scheme] isEqualToString:brand])    //支付宝
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAlixPayRechargeFininsh
                                                            object:nil
                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys:url, @"alixpayURL",nil]];
    }
    return YES;
}

#pragma mark - PrivateMethod
//上传push token
- (void)handleTokenReport
{
    if([[ZdywUtils getLocalStringDataValue:kRemotePushDeviceToken] length] <= 0)
    {
        return;
    }
    NSString *strData = @"token=%@&mac=%@&flag=%d";
    //NSString *strData = @"token=%@";
    strData = [NSString stringWithFormat:strData,
               [ZdywUtils getLocalStringDataValue:kRemotePushDeviceToken],
               [ZdywUtils getDeviceID],
               [ZdywUtils getLocalDataBoolen:kRemotePushTokenState]
               ];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setValue:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceTokenReportType
                                              userInfo:nil
                                              postDict:dic];
    
}

//接收远程push的相关处理
- (void)launchNotification:(NSNotification *)notification
{
    NSLog(@"launchNotification");
    [self didResponseNotifications:[notification userInfo]];
}

- (void) didResponseNotifications:(NSDictionary*)userInfo
{
    if (nil == userInfo)
    {
        return;
    }
    NSDictionary *pBody = [NSDictionary dictionaryWithDictionary:userInfo];
    if (nil != [userInfo objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"])
    {
        NSLog(@"%@", @"2222");
        pBody = [NSDictionary dictionaryWithDictionary:[userInfo objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"]];
    }
    
    NSLog(@"pBody = %@", [pBody description]);
    
    [UIApplication sharedApplication].applicationIconBadgeNumber=1;
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    
    NSDictionary *dicRedirect = [pBody objectForKey:@"redirect"];
    NSLog(@"dicRedirect = %@", dicRedirect);
    NSString *strType = [dicRedirect objectForKey:@"type"];
    NSLog(@"strType = %@", strType);
    NSString *strTarget = [dicRedirect objectForKey:@"target"];
    NSLog(@"strTarget = %@", strTarget);
    NSString *strPushid = [dicRedirect objectForKey:@"id"];
    NSLog(@"strPushid = %@", strPushid);
    
    //push阅读反馈
    if([strPushid length] > 0)
    {
//        [self handlePushFeedback:strPushid];
    }

}

// 初始化softphone组件
- (void)initSoftPhone
{
    CallManager *callManager = [CallManager shareInstance];
    callManager.platform = @"ios";
    callManager.name = [ZdywUtils getLocalStringDataValue:kZdywDataKeyBrandID];
    callManager.version = [ZdywUtils getLocalStringDataValue:kZdywDataKeyVersion];
    [callManager sp_start];
}

- (void)createContactServer{
    //初始化号码归属地
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"upbkAtt" ofType:@"dat"];
    [[ContactManager shareInstance].myPhoneOwnerShipEngine loadDataWithFilePath:filePath];
    
    //创建用户全局数据库
    NSArray *aLis = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                        NSUserDomainMask, YES);
    if ([aLis count] > 0)
    {
        NSString *dbPath = [[aLis objectAtIndex:0] stringByAppendingPathComponent:@"gloab.db"];
        [[ZdywDBManager shareInstance] createGloabDatabase:dbPath];
    }
}

- (void)initAppSetting{
    NSString *cfgFilePath = [[NSBundle mainBundle] pathForResource:@"ZdywConfigure"
                                                            ofType:@"plist"];
    
    NSUserDefaults *usDeaults = [NSUserDefaults standardUserDefaults];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cfgFilePath]){
        NSDictionary *cfgDictionary=[[NSDictionary alloc] initWithContentsOfFile:cfgFilePath];
        self.appConfigure=cfgDictionary;
        //服务器配置地址列表
        [usDeaults setObject:[cfgDictionary objectForKey:kZdywDataKeyServiceHosts] forKey:kZdywDataKeyServiceHosts];
        //基本信息配置
        NSDictionary *basicDictionary=[cfgDictionary objectForKey:kZdywDataKeySoftWareInfo];
        for (NSString *item in basicDictionary.allKeys) {
            [usDeaults setObject:[basicDictionary objectForKey:item] forKey:item];
        }
        //颜色配置
        NSDictionary *colorDictionary=[cfgDictionary objectForKey:kZdywDataKeyColorInfo];
        for (NSString *value in colorDictionary.allKeys) {
            [usDeaults setObject:[colorDictionary objectForKey:value] forKey:value];
        }
    }
    //http网关接口的相关信息
    if([[usDeaults objectForKey:kAGWAnType] length] <= 0)  //算法编码
    {
        [usDeaults setObject:@"1" forKey:kAGWAnType];
    }
    if([[usDeaults objectForKey:kAGWKnType] length] <= 0)  //key编码
    {
        [usDeaults setObject:@"1" forKey:kAGWKnType];
    }
    if([[usDeaults objectForKey:kZdywDataKeyInviteWay] length] <= 0)
    {
        [usDeaults setObject:@"ad" forKey:kZdywDataKeyInviteWay];
    }
    NSString *infoStr = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *infoItem = [NSDictionary dictionaryWithContentsOfFile:infoStr];
    //保存版本号
    NSString *strVersion = [infoItem objectForKey:@"CFBundleVersion"];
    [usDeaults setObject:strVersion forKey:kZdywDataKeyVersion];
    [usDeaults synchronize];
    
    //添加越狱版安装量统计监听
    [[NSNotificationCenter defaultCenter ] addObserver:self
                                              selector:@selector(receiveRecordInstallNumber:)
                                                  name:kNotificationRecordInstallNumberFinish
                                                object:nil];
    //默认配置监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveDefaultServerInfo:)
                                                 name:kNotificationDefaultConfigFinish
                                               object:nil];
    
    //模板配置监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveTempateServerInfo:)
                                                 name:kNotificationTemplateConfigFinish
                                               object:nil];
    
    //系统公告监听
    [[NSNotificationCenter defaultCenter ] addObserver:self
                                              selector:@selector(saveMessageInfo:)
                                                  name:kNotificationSystemnoticeFinish
                                                object:nil];
    //解析好的充值列表数据监听
    [[NSNotificationCenter defaultCenter ] addObserver:self
                                              selector:@selector(saveRechargeList:)
                                                  name:kNotificationGetGoodsCGFFininsh
                                                object:nil];
    
    //版本更新信息监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveUpdataVersionInfo:)
                                                 name:kNotificationUpdateVersionFinish
                                               object:nil];
    //获取用户信息(如注册送30分钟)监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveUserInfoData:)
                                                 name:kNotificationUserInfoFinish
                                               object:nil];
    //sign错误事件监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSignError:)
                                                 name:kNotificationSignErrorEvent
                                               object:nil];
    //远程push的token上传监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTokenReportData:)
                                                 name:kNotificationTokenReportFininsh
                                               object:nil];
    //push消息监听
    [[NSNotificationCenter defaultCenter ] addObserver:self
                                              selector:@selector(receivepushmsg:)
                                                  name:kNotificationPushmsgFinish
                                                object:nil];
    //push消息反馈
    [[NSNotificationCenter defaultCenter ] addObserver:self
                                              selector:@selector(receivePushFeedbackData:)
                                                  name:kNotificationPushFeedbackFinish
                                                object:nil];
}
//获取客户端配置信息
- (id)getClientConfigurationWithKey:(NSString *)aKey
{
    if (0 == [aKey length])
    {
        return nil;
    }
    
    if (nil == self.appConfigure)
    {
        return nil;
    }
    
    return [self.appConfigure objectForKey:aKey];
}
- (void)createMainView{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _mainView = [[MainMenuViewController alloc] initWithNibName:NSStringFromClass([MainMenuViewController class]) bundle:nil];
    ZdywBaseNavigationViewController *nacVC = [[ZdywBaseNavigationViewController alloc]initWithRootViewController:_mainView];
    self.window.rootViewController = nacVC;
    [self.window makeKeyAndVisible];
    
    NSString *uidStr = [ZdywUtils getLocalIdDataValue:kZdywDataKeyUserID];
    NSString *pwdStr = [ZdywUtils getLocalIdDataValue:kZdywDataKeyUserPwd];
    NSString *phoneStr = [ZdywUtils getLocalIdDataValue:kZdywDataKeyUserPhone];
    if (![uidStr length] || ![pwdStr length] || ![phoneStr length]) {
        [self showLoginView];
    } else {
        self.userIsLogined = YES;
        [[ContactManager shareInstance] createUserDataBaseWithUserID:uidStr];
    }
    BOOL appVersion=[ZdywUtils getLocalDataBoolen:kZdywDataKeyAppStoreVersion];
    if (!appVersion) {
        NSString *expirationDateStr = [ZdywUtils getLocalStringDataValue:kCerExpirationDate];
        NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        if ([expirationDateStr length]) {
            NSDate *expirationDate = [dateFormatter dateFromString:expirationDateStr];
            NSArray *dateList = [expirationDateStr componentsSeparatedByString:@"-"];
            
            NSInteger  year = [[dateList objectAtIndex:0] integerValue];
            NSInteger  month = [[dateList objectAtIndex:1] integerValue];
            NSInteger  day = [[dateList objectAtIndex:2] integerValue];
            
            if ([expirationDate timeIntervalSinceDate:[NSDate date]]<15*24*60*60)
            {
                if (![[ZdywUtils getLocalStringDataValue:kExpirationDateTip] isEqualToString:[dateFormatter stringFromDate:[NSDate date]]])
                {
                    NSString *expirationDateTip = [dateFormatter stringFromDate:[NSDate date]];
                    [ZdywUtils setLocalDataString:expirationDateTip key:kExpirationDateTip];
                    NSString *dateStr = [NSString stringWithFormat:@"%d年%d月%d日",year,month,day];
                    NSString *msgStr = [NSString stringWithFormat:@"你当前使用的企业版%@电话%@就要过期了，赶紧更新最新的版本，谢谢支持",[ZdywCommonFun getAppConfigureInfoWithKey:kZdywDataKeyDisplayName],dateStr];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                        message:msgStr
                                                                       delegate:self
                                                              cancelButtonTitle:@"立即下载"
                                                              otherButtonTitles:@"取消", nil];
                    [alertView setTag:kExpirationDateTip_Tag];
                    [alertView show];
                }
            }
        }
    }
}

- (void)showLoginView{
    self.userIsLogined = NO;
//         _loginView = [[LoginViewController alloc] initWithNibName:NSStringFromClass([LoginViewController class]) bundle:nil];
//      _loginView.view.frame = [[UIScreen mainScreen] applicationFrame];
//     _tempNavigation = [[ZdywBaseNavigationViewController alloc] initWithRootViewController:_loginView];
    
    //修改成WelcomeController
     _welComeView = [[WelcomeViewController alloc] initWithNibName:NSStringFromClass([WelcomeViewController class]) bundle:nil];
    _welComeView.view.frame = [[UIScreen mainScreen] applicationFrame];
    _tempNavigation = [[ZdywBaseNavigationViewController alloc] initWithRootViewController:_welComeView];
    [_mainView.callListBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self.window addSubview:_tempNavigation.view];
}

- (void)afterClientActived{
    //获取静态配置
    [self getDefaultConfige];
    NSString *strUid = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserID];
    NSString *strPwd = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPwd];
    NSString *phoneNum = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPhone];
    if (strUid.length>0 && strPwd.length> 0 && phoneNum.length>0) {
        //获取模板配置
        [self getTempletConfigure];
        //获取充值列表
        [self getRecharegeListData];
        //获取系统公告
        NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        NSString *showDate = [ZdywUtils getLocalIdDataValue:kSystemNoticeShowDate];
        if (![showDate isEqualToString:[dateFormatter stringFromDate:[NSDate date]]]){
            [self getSysMessage];
        }
        //获取用户信息
        [self getUserInfo];
        //push拉取消息
        [self getpushmsg];
        //获取系统公告
    }
    
}

#pragma mark mutilpoint detect

// 客户端关闭网络连接
- (void)appDidCloseWeb
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                        message:@"网络无法连接,请检查网络状况"
                                                       delegate:nil
                                              cancelButtonTitle:@"我知道了"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

// 网络正常但无法接入http server
- (void)netDidNormal
{
    [[MutilPointDetectController shareInstance] findValidHttpServer];
}

#pragma mark - HttpServerRequest

- (void)handlePushFeedback:(NSString *)push_id{
    NSString *strData = @"push_id=%@";
    strData = [NSString stringWithFormat:strData,push_id];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setValue:strData forKey:kAGWDataString];
    [[ZdywServiceManager  shareInstance] requestService:ZdywServiceFeedback
                                               userInfo:nil
                                               postDict:dic];
}

- (void)getpushmsg           //push拉取消息
{
    NSString *strData = nil;
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setValue:strData forKey:kAGWDataString];
    [[ZdywServiceManager  shareInstance] requestService:ZdywServicepullmsg
                                               userInfo:nil
                                               postDict:dic];
}

//检查更新接口
- (void)checkUpdateInfo{
    NSString *infoStr = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *infoItem = [NSDictionary dictionaryWithContentsOfFile:infoStr];
    //保存版本号
    NSString *strVersion = [infoItem objectForKey:@"CFBundleIdentifier"];
    NSString *netStatus = nil;
    if ([ZdywUtils getCurrentPhoneNetType] == 1) {
        netStatus = @"wifi";
    } else if([ZdywUtils getCurrentPhoneNetType] == 2){
        netStatus = @"2g";
    } else {
        netStatus = @"";
    }
    NSString *strData = [NSString stringWithFormat:@"package_name=%@&netmode=%@",strVersion,netStatus];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setValue:strData forKey:kAGWDataString];
    [[ZdywServiceManager  shareInstance] requestService:ZdywServiceUpdateInfo
                                               userInfo:nil
                                               postDict:dic];
}

//获取静态配置信息
- (void)getDefaultConfige
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

//获取模板配置信息
- (void)getTempletConfigure
{
    NSString *strData = @"pwd=%@&flag=%@";
    //获取密码
    NSString *strPwd = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPwd];
    if([strPwd length] > 0)
    {
        strPwd = [[Zdyw_md5 shareUtility] md5:strPwd] ;
    }
    //获取flag
    NSString *strFlag = [ZdywUtils getLocalStringDataValue:kDefaultConfigSameFlag];
    if([strFlag length] <= 0)
    {
        strFlag = @"";
    }
    strData = [NSString stringWithFormat:strData, strPwd, strFlag];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setValue:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceTemplateConfigType
                                              userInfo:nil
                                              postDict:dic];
}

//获取充值列表
- (void)getRecharegeListData
{
    NSString *strData = @"";
    
    NSString *strFlag = [ZdywUtils getLocalStringDataValue:kGetGoodsCgfFlag];
    
    if([strFlag length] > 0)
    {
        strData = [NSString stringWithFormat:@"flag=%@", strFlag];
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setValue:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceGetGoodsCgfType
                                              userInfo:nil
                                              postDict:dic];
}

// 获取系统公告
- (void)getSysMessage
{
    NSString *strData = @"";
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setValue:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceSysMessage
                                               userInfo:nil
                                               postDict:dic];
}

//获取用户信息(如注册时间)
- (void)getUserInfo
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceUserInfoType
                                              userInfo:nil
                                              postDict:dic];
}

#pragma mark - DefaultConfigAction

//判断两个数组是否一样
- (BOOL)list:(NSArray *)aList isSameWithOther:(NSArray *)bList
{
    if ([aList count] != [bList count])
    {
        return NO;
    }
    
    for (NSString *aStr in aList)
    {
        if ([bList indexOfObject:aStr] == NSNotFound)
        {
            return NO;
        }
    }
    
    return YES;
}

//保存充值模块的选择充值方式列表
- (void)buildRechargeTypeList:(NSMutableArray *)rechargePayTypeArray
{
    NSMutableArray *payTypeArray = [[NSMutableArray array] init];
    
    if(rechargePayTypeArray && [rechargePayTypeArray count]>0)
    {
        for(int i = 0;i<[rechargePayTypeArray count];i++)
        {
            NSMutableDictionary *payTypeDic = [rechargePayTypeArray objectAtIndex:i];
            PayTypeNode *node = [[PayTypeNode alloc] init];
            node.descStr = [payTypeDic objectForKey:@"desc"];
            node.payTypeStr = [payTypeDic objectForKey:@"paytype"];
            node.payKindStr = [payTypeDic objectForKey:@"paykind"];
            BOOL bFlag = [ZdywUtils getLocalDataBoolen:kNeedReloadRechargeData];
            NSMutableArray *OriDataArray = [ZdywUtils
                                            getLocalIdDataValue:kRechargePayTypeArray];
            if([OriDataArray count]>i&&bFlag==NO)
            {
                NSData *data = [OriDataArray objectAtIndex:i];
                PayTypeNode *orinodeInfo = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                if([ orinodeInfo isEqualPayTypeCell:node])
                {
                    [ZdywUtils setLocalDataBoolen: NO key:kNeedReloadRechargeData];
                }
                else
                {
                    [ZdywUtils setLocalDataBoolen:YES key:kNeedReloadRechargeData];
                    
                }
            }
            
            switch ([node.payKindStr intValue])
            {
                case 701:
                    node.leftIconImageName = @"recharge_yd_icon.png";
                    break;
                case 702:
                    node.leftIconImageName = @"recharge_lt_icon.png";
                    break;
                case 703:
                    node.leftIconImageName = @"recharge_dx_icon.png";
                    break;
                case 704:
                    node.leftIconImageName = @"recharge_zfb_icon.png";
                    break;
                case 705:
                    node.leftIconImageName = @"recharge_yl_icon.png";
                    break;
                case 707:
                    node.leftIconImageName = @"recharge_zfbweb_icon.png";
                    break;
                default:
                    break;
            }
            NSData *data =[NSKeyedArchiver archivedDataWithRootObject:node];
            [payTypeArray addObject:data];
        }
    }
    [ZdywUtils setLocalIdDataValue:payTypeArray key:kRechargePayTypeArray];
}

//保存直拨服务器信息
- (void)saveDirectCallInfo:(NSDictionary *)sipInfoDic
{
    if([sipInfoDic count]>0)
    {
        //比较直拨服务器的地址是否有变化
        //已保存的数据
        NSArray *currUrlArray = [ZdywUtils getLocalIdDataValue:kZdywDataKeyVPSIPList];
        //服务器下发的数据
        NSArray *urlArray = [sipInfoDic objectForKey:@"sip_addr"];
        NSArray *portArray = [sipInfoDic objectForKey:@"sip_port"];
        BOOL bFlag = [self list:currUrlArray isSameWithOther:urlArray];
        if(!bFlag)
        {
            //保存直拨服务器ip
            [ZdywUtils setLocalIdDataValue:urlArray key:kZdywDataKeyVPSIPList];
            //保存直拨服务器端口
            [ZdywUtils setLocalIdDataValue:portArray key:kZdywDataKeyVPSPortList];
            [[SelectVPSController shareInstance] selectOptimalVPS];
        }
    }
    
}

- (void)saveDefaultConfig:(NSDictionary*)dic{
    switch ([[dic objectForKey:@"result"]intValue])
    {
        case 0:
        {
            NSMutableDictionary *tempDic = [dic objectForKey:@"defaultconfig"];
            NSMutableDictionary *tempDic1 = [tempDic objectForKey:@"bootini"];
            if([tempDic count]>0)
            {
                //保存直拨服务器信息
                NSMutableDictionary *sipInfoDic = [tempDic1 objectForKey:@"driect_call"];
                [self saveDirectCallInfo:sipInfoDic];
                //保存是否要显示的app store功能的设置
                NSString *hideStr = [tempDic1 objectForKey:@"hidefunction"];
                if([hideStr length] > 0)
                {
                    if([hideStr isEqualToString:@"appear"])
                    {
                        [ZdywUtils setLocalDataBoolen:YES key:kShowHiddenFunction];
                    }
                    else if ([hideStr isEqualToString:@"hide"])
                    {
                        [ZdywUtils setLocalDataBoolen:NO key:kShowHiddenFunction];
                    }
                }
                else
                {
                    [ZdywUtils setLocalDataBoolen:NO key:kShowHiddenFunction];
                }
                NSDictionary *moreTips = [tempDic1 objectForKey:@"more_page_tips"];
                //保存客服电话,客服qq
                NSString *customerPhone = [moreTips objectForKey:@"customer_phone"];
                if([customerPhone length] > 0)
                {
                    [ZdywUtils setLocalDataString:customerPhone key:kZdywDataKeyCustomerPhone];
                }
                //保存客服服务时间
                NSString *serviceTime = [tempDic1 objectForKey:@"service_time"];
                if ([serviceTime length] > 0) {
                    [ZdywUtils setLocalDataString:serviceTime key:kZdywDataKeyServiceTime];
                }
                //保存充值界面的充值方式
                NSMutableArray *rechargePayTypeArray = [tempDic1 objectForKey:@"paytypes"];
                [self buildRechargeTypeList:rechargePayTypeArray];
            }
        }
            break;
        default:
            break;
    }
}

//保存当前最新的版本号
- (void)saveUpdataVersionInfo:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    NSString *tempStr = [dic objectForKey:@"mandatory"];
    if([tempStr length] > 0)
    {
        [ZdywUtils setLocalDataString: tempStr key:kUpdateMandatory];
    }
    tempStr = [dic objectForKey:@"new_version"];
    if([tempStr length] > 0)
    {
        [ZdywUtils setLocalDataString: tempStr key:kUpdateVersion];
    }
    tempStr = [dic objectForKey:@"update_addr"];
    if([tempStr length] > 0)
    {
        [ZdywUtils setLocalDataString:tempStr key:kUpdateAddress];
    }
    tempStr = [dic objectForKey:@"update_info"];
    if([tempStr length] > 0)
    {
        [ZdywUtils setLocalDataString:tempStr key: kUpdateInfo];
    }
    id tipsNumber = [dic objectForKey:@"tips_number"];
    if (tipsNumber && ![tipsNumber isKindOfClass:[NSNull class]]) {
        NSInteger tipNumber = [tipsNumber integerValue];
        [ZdywUtils setLocalIdDataValue:[NSString stringWithFormat:@"%d",tipNumber] key:KUpdateTipNumber];
    }
    
    if([[dic objectForKey:@"new_version"] length]  <= 0)
    {
        //        NSString *version = [PublicFunction getLocalStringDataValue:kVersion];
        //        [PublicFunction setLocalDataString:version key:kUpdateVersion];
    }
    else
    {
        NSString *updateMandatory = [ZdywUtils getLocalStringDataValue:kUpdateMandatory];
        
        if([updateMandatory isEqualToString:@"force"] || [updateMandatory isEqualToString:@"auto"])
        {
            [self willDisplayUpdateView];
        }
    }
    
}

- (void)saveDefaultServerInfo:(NSNotification *)notification
{
    NSDictionary *serverInfo = [notification userInfo];
    [self saveDefaultConfig:serverInfo];
    if (nil != serverInfo)
    {
        NSDictionary *tempdic = [serverInfo objectForKey:@"defaultconfig"];
        if (nil != tempdic)
        {
            //兼容老版本的充值列表
            [ZdywUtils setLocalDataString:@"" key:kGetGoodsCgfFlag];
            
            NSDictionary *bootiniDict = [tempdic objectForKey:@"bootini"];
            if (nil != bootiniDict)
            {
                NSString *cerExpirationDate = [bootiniDict objectForKey:@"cer_expiration_date"];
                [ZdywUtils setLocalDataString:cerExpirationDate key:kCerExpirationDate];
                
                NSString *versionUpdateUrl = [bootiniDict objectForKey:@"version_update_url"];
                [ZdywUtils setLocalDataString:versionUpdateUrl key:kVersionUpdateUrl];
                
                NSDictionary *dialModelDict = [bootiniDict objectForKey:@"dialModel"];
                if (nil != dialModelDict)
                {
                    NSString *directFee = [dialModelDict objectForKey:@"direct_fee"];
                    if (nil == directFee)
                    {
                        directFee = @"";
                    }
                    [ZdywUtils setLocalDataString:directFee key:kDialModelDirectFee];
                    
                    NSString *callBackFee = [dialModelDict objectForKey:@"callBack_fee"];
                    if (nil == callBackFee)
                    {
                        callBackFee = @"";
                    }
                    [ZdywUtils setLocalDataString:callBackFee key:kDialModelCallBackFee];
                    
                    NSString *directRate = [dialModelDict objectForKey:@"direct_rate"];
                    if (nil == directRate)
                    {
                        directRate = @"";
                    }
                    [ZdywUtils setLocalDataString:directRate key:kDialModelDirectRate];
                    
                    NSString *callBackRate = [dialModelDict objectForKey:@"callBack_rate"];
                    if (nil == callBackRate)
                    {
                        callBackRate = @"";
                    }
                    [ZdywUtils setLocalDataString:callBackRate key:kDialModelCallBackRate];
                    
                    NSString *dialModelTips = [dialModelDict objectForKey:@"tips"];
                    if (nil == dialModelTips)
                    {
                        dialModelTips = @"";
                    }
                    [ZdywUtils setLocalDataString:dialModelTips key:kDialModelTips];
                }
            }
        }
    }
}

#pragma mark - HttpServiceRecevice

//push阅读反馈请求返回的数据
- (void)receivePushFeedbackData:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    
    NSLog(@"%@", dic);
}

#pragma mark push消息监听
-(void)receivepushmsg:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    
    NSString *result = [dic objectForKey:@"reason"];
    NSLog(@"result ======== %@",result);
    if([[dic objectForKey:@"content"] isKindOfClass:[NSString class]]||[dic objectForKey:@"content"]==nil)
    {
        NSLog(@"push消息数目是0000000,标题要长---");
    } else {
        NSMutableArray *pushMsgArray = [[NSMutableArray alloc] initWithCapacity:2];
        NSArray *msgArray = [ZdywUtils getLocalIdDataValue:kPushMessageArray];
        if (dic) {
            if ([msgArray count]) {
                [pushMsgArray addObjectsFromArray:msgArray];
            }
            [pushMsgArray addObjectsFromArray:[dic objectForKey:@"content"]];
            self.isNewMsg = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReceiveNewPushMsg object:nil];
            [ZdywUtils setLocalIdDataValue:pushMsgArray key:kPushMessageArray];
        }
    }
}

- (void)receiveTokenReportData:(NSNotification *)notification       //上传push token返回的数据
{
    NSDictionary *dic = [notification userInfo];
    NSLog(@"%@",[dic objectForKey:@"reason"]);
    
    if([dic objectForKey:@"result"])
    {
        int nRet = [[dic objectForKey:@"result"] intValue];
        
        if(nRet == 1)
        {
            [ZdywUtils setLocalDataBoolen:YES key:kRemotePushTokenReportFlag];
        }
    }
}

- (void)handleSignError:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    int nRet = [[userInfo objectForKey:@"result"] intValue];
    
    if(nRet == 403) //sign错误
    {
        NSString *strAn = [[userInfo objectForKey:@"an"] stringValue];    //算法编码
        [ZdywUtils setLocalDataString:strAn key:kAGWAnType];
        NSString *strKn = [[userInfo objectForKey:@"kn"] stringValue];    //key编码
        [ZdywUtils setLocalDataString:strKn key:kAGWKnType];
        NSString *strTk = [userInfo objectForKey:@"tk"];    //临时key
        [ZdywUtils setLocalDataString:strTk key:kAGWTkType];
        //==sign错误时需用新的key值重新登录一次===
        //获取account(值为uid/phone/email)
        NSString *strAccount = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserID];
        if([strAccount length] <= 0)
            return;
        //获取pwd(使用自己的md5)
        NSString *strPwd = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPwd];
        if([strPwd length] <= 0)
            return;
        strPwd = [[Zdyw_md5 shareUtility] md5:strPwd];
        NSString *strData = @"account=%@&passwd=%@&ptype=%@&netmode=%@";
        //获取ptype(手机型号)
        NSString *strPType = [ZdywUtils getPlatformInfo];
        //获取netmode(网络类型)
        NSString *strNetMode = [ZdywUtils getCurrentPhoneNetMode];
        strData = [NSString stringWithFormat:strData, strAccount, strPwd, strPType, strNetMode];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
        [dic setObject:strData forKey:kAGWDataString];
        [[ZdywServiceManager shareInstance] requestService:ZdywServiceLogin
                                                  userInfo:nil
                                                  postDict:dic];
    }
}

- (void)receiveRecordInstallNumber:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    int nRet = [[userInfo objectForKey:@"result"] intValue];
    
    NSString *userID = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserID];
    NSString *aKey = kRecordInstall;
    if ([userID length] > 0)
    {
        aKey = [NSString stringWithFormat:@"%@_%@",userID,kRecordInstall];
    }
    if(nRet==0)
    {
        [ZdywUtils setLocalDataBoolen:YES key:aKey];
    }
    else if(nRet==-1)
    {
        [ZdywUtils setLocalDataBoolen:YES key:aKey];
    }
    else
    {
        [ZdywUtils setLocalDataBoolen:NO key:aKey];
    }
}

- (void)saveTempateServerInfo:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    if ([[dic objectForKey:@"result"]intValue] == 0) {
        NSMutableDictionary *listData = [dic objectForKey:@"wap_target_url"];
        //收支明细
        NSMutableDictionary *detailDic = [listData objectForKey:@"wap_account_details"];
        NSString *detailURL = [detailDic objectForKey:@"url"];
        if([detailURL length]>0)
        {
            [ZdywUtils setLocalDataString:detailURL key:kAccountDetailWebURL];
        }
        //查询话单
        NSMutableDictionary *callDic = [listData
                                        objectForKey:@"wap_call_log"];
        NSString *callURL = [callDic objectForKey:@"url"];
        if([callURL length]>0)
        {
            [ZdywUtils setLocalDataString:callURL key:kAccountPayListWebURL];
        }
    }
}

// 处理系统公告下发的相关信息
- (void)saveMessageInfo:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    int nRet = [[dic objectForKey:@"result"] intValue];
    
    if(nRet == 0)
    {
        //优惠信息
        NSString *strPayInfo = [dic objectForKey:@"pay_info"];
        if([strPayInfo length] > 0)
        {
            [ZdywUtils setLocalDataString:strPayInfo key:kPayInfo];
        }
        
        //最新优惠
        NSString *strFavourableInfo = [dic objectForKey:@"favourable_info"];
        if([strFavourableInfo length] > 0)
        {
            [ZdywUtils setLocalDataString:strFavourableInfo key:kFavourableInfo];
        }
        
        //系统公告
        NSArray *msgList = [dic objectForKey:@"syslist"];
        if ([msgList count]) {
            NSDictionary *dic = [msgList objectAtIndex:0];
            _sysMessage = [[SysMessageObj alloc] initWithDictory:dic];
            [self showSystemNoticeView];
        }
    }
}

- (void)saveRechargeList:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    //101表示本次数据没有变化
    if([[userInfo objectForKey:@"result"] intValue]==101)
    {
        return;
    }
    else
    {
        NSString *flag =[userInfo objectForKey:@"flag"];
        [ZdywUtils setLocalDataString:flag key:kGetGoodsCgfFlag];
        [self buildRechargeNode :userInfo];
    }
    //获取充值列表
    NSMutableArray *rechargeMoneyInfoArray = [[ZdywUtils getLocalIdDataValue:kGoodsRechargeListArray] mutableCopy];
    
    if(!rechargeMoneyInfoArray)
    {
        rechargeMoneyInfoArray = [NSMutableArray arrayWithCapacity:0];
    }
    
    for(int i = 0;i< [rechargeMoneyInfoArray count];i++)
    {
        RechargeCellNode *cellNode =[NSKeyedUnarchiver unarchiveObjectWithData:[rechargeMoneyInfoArray objectAtIndex:i]];
        
        //移除充值列表接口下发的官方充值
        if([cellNode.appleIdStr length]>0)
        {
            [rechargeMoneyInfoArray removeObjectAtIndex:i];
            i--;
        }
    }
    //获取充值页推荐位的文字
    for(int i = 0;i< [rechargeMoneyInfoArray count];i++)
    {
        RechargeCellNode *cellNode =[NSKeyedUnarchiver unarchiveObjectWithData:[rechargeMoneyInfoArray objectAtIndex:i]] ;
        if([cellNode.recommendFlag isEqualToString:@"y"])
        {
            [ZdywUtils setLocalDataString:cellNode.nameStr
                                           key:kRecommandMoneyName];
        }
        break;
    }
    //把组装好的cellarray设置给充值页
    [ZdywUtils setLocalIdDataValue:[rechargeMoneyInfoArray mutableCopy] key:kRechargeListNodeArray];
}

- (void)buildRechargeNode:(NSDictionary*)dic
{
    //保存充值界面的充值金额信息
    switch ([[dic objectForKey:@"result"]intValue])
    {
        case 0:
        {
            NSMutableArray *rechargeMoneyInfoArray = [[NSMutableArray alloc ]initWithCapacity:0];
            NSMutableArray *oldNodeDataArray = [[NSUserDefaults standardUserDefaults] objectForKey:kGoodsRechargeListArray];
            NSMutableArray *moneyArray = [dic objectForKey:@"goods_list"];
            for(NSInteger i = 0;i< [moneyArray count];i++)
            {
                NSMutableDictionary *MoneyDic = [moneyArray objectAtIndex:i];
                RechargeCellNode *section = [[RechargeCellNode alloc] init];
                Init(section.totalFlagStr,[MoneyDic objectForKey:@"total_flag"]);
                Init(section.nameStr,[MoneyDic objectForKey:@"name"]);
                section.goodsID = [[MoneyDic objectForKey:@"goods_id"] intValue];
                Init(section.bidStr,[MoneyDic objectForKey:@"bid"]);
                Init(section.desStr,[MoneyDic objectForKey:@"des"]);
                section.buyLimit = [[MoneyDic objectForKey:@"buy_limit"] intValue];
                Init(section.minuteStr, [MoneyDic objectForKey:@"convert_minute"]);
                Init(section.appleIdStr,[MoneyDic objectForKey:@"apple_id"]);
                section.sortID = [[MoneyDic objectForKey:@"sort_id"] intValue];
                Init(section.goodsTypeStr,[MoneyDic objectForKey:@"goods_type"]);
                section.priceNumStr = [NSString stringWithFormat:@"%.2f",
                                       [[MoneyDic objectForKey:@"price"] floatValue]/100];
                for(int tempk = 0;tempk<2;tempk++)
                {
                    if([section.priceNumStr hasSuffix:@"0"])
                    {
                        section.priceNumStr = [section.priceNumStr
                                               substringToIndex:section.priceNumStr.length-1];
                    }
                    if([section.priceNumStr hasSuffix:@"."])
                    {
                        section.priceNumStr = [section.priceNumStr
                                               substringToIndex:section.priceNumStr.length-1];
                        
                    }
                }
                Init(section.recommendFlag,[MoneyDic objectForKey:@"recommend_flag"]);
                Init(section.jumpURL,[MoneyDic objectForKey:@"url"]);
                Init(section.jumpFlag,[MoneyDic objectForKey:@"jump_flag"]);
                Init(section.adImageURL,[MoneyDic objectForKey:@"image"]);
                
                NSData *oldTopData= nil;
                RechargeCellNode *nodeTop = nil;
                BOOL bFlag = [ZdywUtils getLocalDataBoolen:kNeedReloadRechargeData];
                
                if([oldNodeDataArray count]>i && bFlag == NO)
                {
                    oldTopData   = [oldNodeDataArray objectAtIndex:i];
                    nodeTop= [NSKeyedUnarchiver unarchiveObjectWithData:oldTopData];
                }
                //lao
                if(nodeTop)
                {
                    if([section isEqualRechargeCell:nodeTop])
                    {
                        [ZdywUtils setLocalDataBoolen:NO key:kNeedReloadRechargeData];
                    }
                    else
                    {
                        [ZdywUtils setLocalDataBoolen:YES key:kNeedReloadRechargeData];
                        
                    }
                }
                else
                {
                    [ZdywUtils setLocalDataBoolen:YES key:kNeedReloadRechargeData];
                    
                }
                NSData * data1= [NSKeyedArchiver archivedDataWithRootObject:section];
                [rechargeMoneyInfoArray addObject:data1];
            }
            [ZdywUtils setLocalIdDataValue:rechargeMoneyInfoArray key:kGoodsRechargeListArray];
        }
            break;
        default:
            break;
    }
}

- (void)willDisplayUpdateView{
    NSString *updateTipDate = [ZdywUtils getLocalStringDataValue:KUpdateTipDate];
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    if ([updateTipDate length]) {
        NSInteger updateShowCount = [[ZdywUtils getLocalStringDataValue:KUpdateIsNumber] integerValue];
        if ([updateTipDate isEqualToString:[dateFormatter stringFromDate:[NSDate date]]]) {
            if (updateShowCount < [[ZdywUtils getLocalStringDataValue:KUpdateTipNumber] integerValue]) {
                [self displayUpdateView];
                updateShowCount=updateShowCount+1;
                [ZdywUtils setLocalIdDataValue:[NSString stringWithFormat:@"%d",updateShowCount] key:KUpdateIsNumber];
            } else {
                return;
            }
        } else {
            [self displayUpdateView];
            NSString *tipDate = [dateFormatter stringFromDate:[NSDate date]];
            [ZdywUtils setLocalDataString:tipDate key:KUpdateTipDate];
            [ZdywUtils setLocalIdDataValue:@"1" key:KUpdateIsNumber];
        }
    } else {
        [self displayUpdateView];
        NSString *tipDate = [dateFormatter stringFromDate:[NSDate date]];
        [ZdywUtils setLocalDataString:tipDate key:KUpdateTipDate];
        [ZdywUtils setLocalIdDataValue:@"1" key:KUpdateIsNumber];
    }
}

- (void)displayUpdateView
{
    NSString *updateVersion = [ZdywUtils getLocalStringDataValue:kUpdateVersion];
    NSString *version = [ZdywUtils getLocalStringDataValue:kZdywDataKeyVersion];
    NSString *updateMandatory = [ZdywUtils getLocalStringDataValue:kUpdateMandatory];
    
    if([updateVersion compare:version options:NSNumericSearch] > 0)
    {
        NSString *strTitle = nil;
        NSString *strMsg = nil;
        if([updateMandatory isEqualToString:@"force"])
        {
            strTitle = @"欢迎升级";
            strMsg = [NSString stringWithFormat:@"最新版本号：%@\n更新信息：%@",
                      updateVersion,
                      [ZdywUtils getLocalStringDataValue:kUpdateInfo]];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:strTitle
                                                                message:strMsg
                                                               delegate:self
                                                      cancelButtonTitle:@"升级"
                                                      otherButtonTitles:nil, nil];
            alertView.tag = ForceUpdate_tag;
            [alertView show];
        }
        else
        {
            strTitle = [NSString stringWithFormat:@"%@提示",[ZdywCommonFun getAppConfigureInfoWithKey:kZdywDataKeyDisplayName]];
            strMsg = [NSString stringWithFormat:@"最新版本号：%@\n更新信息：%@",
                      updateVersion,
                      [ZdywUtils getLocalStringDataValue:kUpdateInfo]];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:strTitle
                                                                message:strMsg
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"升级", nil];
            alertView.tag = Update_tag;
            [alertView show];
        }
        
        
    }
}

- (void)receiveUserInfoData:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    
    NSLog(@"receiveUserInfoData dic = %@", dic);
    
    int nRet = [[dic objectForKey:@"result"] intValue];
    
    if(nRet == 0)
    {
        //处理注册时间
        NSDate *registeDate = nil;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        //存储用户注册时间
        id rDate = [dic objectForKey:@"regtime"];
        if (rDate != nil)
        {
            if ([rDate isKindOfClass:[NSString class]])
            {
                registeDate = [formatter dateFromString:rDate];
            }
            else
            {
                registeDate = (NSDate *)rDate;
            }
        }
    }
}

#pragma mark - 拨打电话

- (void)callWithContactID:(NSInteger)contactID
{
    ContactNode *aContact = [[ContactManager shareInstance] getOneContactByID:contactID];
    _contactNodeInfo = aContact;
    if (nil != aContact
        && kInValidContactID != aContact.contactID)
    {
        NSArray *aList = [aContact contactAllPhone];
        if ([aList count] > 1)
        {
            UIActionSheet *phoneSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                    delegate:self
                                                           cancelButtonTitle:nil
                                                      destructiveButtonTitle:nil
                                                           otherButtonTitles:nil];
            phoneSheet.tag = 1001;
            for (NSString  *phoneNumerStr in  aList)
            {
                [phoneSheet addButtonWithTitle:phoneNumerStr];
            }
            [phoneSheet addButtonWithTitle:@"取消"];
            phoneSheet.cancelButtonIndex = [aList count];
            [phoneSheet showInView:self.window];
        }
        else if([aList count] > 0)
        {
            [self startCallWithPhoneNumber:[aList objectAtIndex:0]
                               contactName:[aContact getContactFullName]
                                 contactID:aContact.contactID];
        }
    }
}

- (void)startCallWithPhoneNumber:(NSString *)phoneNumber
                     contactName:(NSString *)contactName
                       contactID:(NSInteger)contactID
{
    if ([phoneNumber isEqualToString:@"请输入电话号码"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"拨打的电话号码不能为空"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if (![phoneNumber length]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"拨打的电话号码不能为空"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    } else if([phoneNumber length] < 5){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"你所呼叫的号码过短，请确认后在拨打!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        CallInfoNode *infoNode = [[CallInfoNode alloc] init];
        infoNode.calleePhone = phoneNumber;  //加上国家
        infoNode.calleeName = contactName;
        infoNode.calleeRecordID = contactID;
        infoNode.calltype = ZdywDirectCallType;
        [[CallWrapper shareCallWrapper] initiatingCall:infoNode];
    }
}

#pragma mark - showSystemNotice

- (void)showSystemNoticeView{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:KZdywAppFristLaunch] && self.userIsLogined == YES) {
        NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        NSString *showDate = [ZdywUtils getLocalIdDataValue:kSystemNoticeShowDate];
        if (showDate!=nil) {
            if ([showDate isEqualToString:[dateFormatter stringFromDate:[NSDate date]]]) {
                return;
            } else {
                [ZdywUtils setLocalIdDataValue:[dateFormatter stringFromDate:[NSDate date]] key:kSystemNoticeShowDate];
                [_mainView showSystemNoticeView];
            }
        } else {
            NSString *expirationDateTip = [dateFormatter stringFromDate:[NSDate date]];
            [ZdywUtils setLocalDataString:expirationDateTip key:kSystemNoticeShowDate];
            [_mainView showSystemNoticeView];
        }
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.cancelButtonIndex != buttonIndex)
    {
        NSString *phoneNumber = [actionSheet buttonTitleAtIndex:buttonIndex];
        [self startCallWithPhoneNumber:phoneNumber
                           contactName:[_contactNodeInfo getContactFullName]
                             contactID:_contactNodeInfo.contactID];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == Update_tag) {
        if (buttonIndex>0) {
            NSString *strUrl = [ZdywUtils getLocalStringDataValue:kUpdateAddress];
            NSURL *url = [NSURL URLWithString: strUrl];
            [[UIApplication sharedApplication] openURL: url];
        }
    } else if (alertView.tag == ForceUpdate_tag){
        NSString *strUrl = [ZdywUtils getLocalStringDataValue:kUpdateAddress];
        NSURL *url = [NSURL URLWithString: strUrl];
        [[UIApplication sharedApplication] openURL: url];
         exit(0);
    } else if (alertView.tag == kExpirationDateTip_Tag){
        if (buttonIndex == 0) {
            NSString *versionUpdateUrl = [ZdywUtils getLocalStringDataValue:kVersionUpdateUrl];
            if ([versionUpdateUrl length]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:versionUpdateUrl]];
            }
        }else {
        }
    }
}

@end
