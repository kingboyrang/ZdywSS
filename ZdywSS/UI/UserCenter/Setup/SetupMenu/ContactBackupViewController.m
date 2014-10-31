//
//  ContactBackupViewController.m
//  WldhClient
//
//  Created by ddm on 3/27/14.
//  Copyright (c) 2014 guoling. All rights reserved.
//

#import "ContactBackupViewController.h"
#import "T9ContactRecord.h"
#import "ContactManager.h"
#import "ZdywServiceManager.h"

#define AlertViewTag_Backup 1002
#define AlertViewTag_Recovery 1003

@interface ContactBackupViewController ()

@property (nonatomic, retain) IBOutlet UIView *backupView;
@property (nonatomic, retain) IBOutlet UIView *restoreView;
@property (nonatomic, retain) IBOutlet UILabel *lastBackupInfoLable;
@property (nonatomic, retain) IBOutlet UILabel *lastRestoreInfoLable;
@property (nonatomic, retain) IBOutlet UILabel *lastBackupTimeLable;
@property (nonatomic, retain) IBOutlet UILabel *lastRestoreTimeLable;
@property (nonatomic, strong) IBOutlet UILabel *contactCountLable;

@end

@implementation ContactBackupViewController

#pragma mark - Liftcycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self addObservers];
    [self contactBackupInfo];
    
    self.title = @"备份通讯录";
    
    self.backupView.backgroundColor = [UIColor clearColor];
    self.backupView.layer.borderColor = [UIColor colorWithRed:138.0/255.0 green:138.0/255.0 blue:138.0/255.0 alpha:1.0].CGColor;
    self.backupView.layer.borderWidth = 0.5;
    self.backupView.layer.cornerRadius = 10.0;
    
    self.restoreView.backgroundColor = [UIColor clearColor];
    self.restoreView.layer.borderColor = [UIColor colorWithRed:138.0/255.0 green:138.0/255.0 blue:138.0/255.0 alpha:1.0].CGColor;
    self.restoreView.layer.borderWidth = 0.5;
    self.restoreView.layer.cornerRadius = 10.0;
    
    UIButton *backupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backupBtn.frame = CGRectMake(0, 0, _backupView.frame.size.width, _backupView.frame.size.height);
    [backupBtn setBackgroundColor:[UIColor clearColor]];
    [backupBtn addTarget:self action:@selector(backupAction) forControlEvents:UIControlEventTouchUpInside];
    [self.backupView addSubview:backupBtn];
    
    UIButton *restoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    restoreBtn.frame = CGRectMake(0, 0, _restoreView.frame.size.width, _restoreView.frame.size.height);
    [restoreBtn setBackgroundColor:[UIColor clearColor]];
    [restoreBtn addTarget:self action:@selector(recoveryAction) forControlEvents:UIControlEventTouchUpInside];
    [self.restoreView addSubview:restoreBtn];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self removeObservers];
}

#pragma mark - BtnAction

- (void)backupAction{
    UIAlertView * backupAlertView = [[UIAlertView alloc] initWithTitle:@"是否备份通讯录"
                                                               message:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"取消"
                                                     otherButtonTitles:@"确认", nil];
    [backupAlertView setTag:AlertViewTag_Backup];
    [backupAlertView show];
}

- (void)recoveryAction{
    UIAlertView * recoveryAlertView = [[UIAlertView alloc] initWithTitle:@"是否恢复通讯录"
                                                               message:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"取消"
                                                     otherButtonTitles:@"确认", nil];
    [recoveryAlertView setTag:AlertViewTag_Recovery];
    [recoveryAlertView show];
}

#pragma mark - 通知相关操作

- (void)addObservers{
    NSNotificationCenter *userDefaultCenter = [NSNotificationCenter defaultCenter];
    //添加联系人备份结束通知
    [userDefaultCenter addObserver:self
                          selector:@selector(contactBackupFinish:)
                              name:kNotificationContactBackUpFinish
                            object:nil];
    
    //下载备份的联系人
    [userDefaultCenter addObserver:self
                          selector:@selector(contactRecovery:)
                              name:kNotificationContactRecoveryFinish
                            object:nil];
    
    //联系人备份信息
    [userDefaultCenter addObserver:self
                          selector:@selector(contactBackupInfoFinish:)
                              name:kNotificationContactBackUpInfoFinish
                            object:nil];
}

- (void)removeObservers{
    NSNotificationCenter *userDefaultCenter = [NSNotificationCenter defaultCenter];
    [userDefaultCenter removeObserver:self name:kNotificationContactBackUpFinish object:nil];
    [userDefaultCenter removeObserver:self name:kNotificationContactRecoveryFinish object:nil];
    [userDefaultCenter removeObserver:self name:kNotificationContactBackUpInfoFinish object:nil];
}

#pragma mark - 备份联系人

- (void)contactBackupData
{
    NSLog(@"备份联系人");
    //设置时间戳
    NSString *strData = @"vcard_contacts=%@";
    
    NSString *vcard_contacts = [[ContactManager shareInstance] getRecoveryJsonString];
    vcard_contacts = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                        (CFStringRef)vcard_contacts,
                                                                        NULL,
                                                                        CFSTR(":/?#[]@!$&’()*+,;="),
                                                                        kCFStringEncodingUTF8));
    
    strData = [NSString stringWithFormat:strData,vcard_contacts];
    

    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [dic setObject:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceContactBackUpType
                                              userInfo:nil
                                              postDict:dic];
    [SVProgressHUD showInView:self.view
                       status:@"数据提交中，请稍候..."
             networkIndicator:NO
                         posY:-1
                     maskType:SVProgressHUDMaskTypeClear];
    
}

#pragma mark - 下载联系人数据

- (void)downloadContactData{
    NSLog(@"下载联系人数据");
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceContactRecoveryType
                                              userInfo:nil
                                              postDict:dic];
    [SVProgressHUD showInView:self.view
                       status:@"数据提交中，请稍候..."
             networkIndicator:NO
                         posY:-1
                     maskType:SVProgressHUDMaskTypeClear];
}

#pragma mark - 联系人备份信息
- (void)contactBackupInfo{
    NSLog(@"联系人备份信息");
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceContactBackUpInfoType
                                              userInfo:nil
                                              postDict:dic];
}

#pragma mark - 获取备份联系人信息返回

- (void)contactBackupInfoFinish:(NSNotification *)notify{
    NSDictionary *userInfo = [notify userInfo];
    id result = [userInfo objectForKey:@"result"];
    NSString *strReason = [userInfo objectForKey:@"reason"];
    if (result) {
        NSInteger resultCode = [result integerValue];
        if (resultCode == 0) {
            NSString *contactCount = [userInfo objectForKey:@"contactnum"];
            NSString *lastBackupInfo = [userInfo objectForKey:@"lastbackup"];
            NSString *lastRestoreInfo = [userInfo objectForKey:@"lastrenew"];
            if ([contactCount length] && ![contactCount isKindOfClass:[NSNull class]]) {
                self.contactCountLable.text = contactCount;
            }
            if ([lastRestoreInfo length] && ![lastRestoreInfo isKindOfClass:[NSNull class]]) {
                self.lastRestoreTimeLable.text = [lastRestoreInfo substringToIndex:10];
            }
            if ([lastBackupInfo length] && ![lastBackupInfo isKindOfClass:[NSNull class]]) {
                self.lastBackupTimeLable.text = [lastBackupInfo substringToIndex:10];
            }
        } else {
            NSLog(@"%@",strReason);
        }
    }
}

#pragma mark - 备份联系人返回

- (void)contactBackupFinish:(NSNotification *)notify{
    NSDictionary *userInfo = [notify userInfo];
    id result = [userInfo objectForKey:@"result"];
    NSString *strReason = [userInfo objectForKey:@"reason"];
    if (result) {
        NSInteger resultCode = [result integerValue];
        if (resultCode == 0) {
            [self contactBackupInfo];
            [SVProgressHUD dismissWithSuccess:strReason afterDelay:1];
        } else {
            [SVProgressHUD dismissWithError:strReason afterDelay:1];
        }
    }
}

#pragma mark - 恢复联系人操作

- (void)contactRecovery:(NSNotification *)notify{
    NSDictionary *userInfo = [notify userInfo];
    id result = [userInfo objectForKey:@"result"];
    NSString *strReason = [userInfo objectForKey:@"reason"];
    if (result) {
        NSInteger resultCode = [result integerValue];
        if (resultCode == 0) {
            NSArray *dataList = [userInfo objectForKey:@"contactlist"];
            [[ContactManager shareInstance] recoveryContactWithDataList:dataList recoveryType:1];
            [self contactBackupInfo];
            [SVProgressHUD dismissWithSuccess:strReason afterDelay:2];
        } else if (resultCode == -3){
            [SVProgressHUD dismissWithError:@"恢复联系人失败" afterDelay:2];
        } else {
            [SVProgressHUD dismissWithError:strReason afterDelay:2];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == AlertViewTag_Backup) {
        if (buttonIndex == 1) {
            [self contactBackupData];
        }
    }
    if (alertView.tag == AlertViewTag_Recovery) {
        if (buttonIndex == 1) {
            [self downloadContactData];
        }
    }
}

@end
