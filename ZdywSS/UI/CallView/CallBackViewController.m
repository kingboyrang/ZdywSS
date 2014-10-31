//
//  CallBackViewController.m
//  ZdywClient
//
//  Created by ddm on 7/2/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "CallBackViewController.h"
#import "CallWrapper.h"
#import "ContactRecordNode.h"
#import "ContactManager.h"


#define Pointcount   3

@interface CallBackViewController (){
    NSTimer                         *_backDismissTimer;     //回拨视图消失计时器
}
@end

@implementation CallBackViewController

#pragma mark - lifeCycle

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
    NSMutableArray *signalList = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0 ;i < Pointcount; i++ ) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"callback_point%d",i+1]];
        [signalList addObject:image];
    }
    _pointImageView.animationImages = signalList;
    _pointImageView.animationDuration = 0.5*Pointcount;
    [_pointImageView startAnimating];
    _nameLable.text = _myCallInfoNode.calleeName;
    if (_myCallInfoNode.calleeName == nil) {
        _nameLable.text = _myCallInfoNode.calleePhone;
    }
    _areaLable.text = [self phoneAttributionForPhone:_myCallInfoNode.calleePhone];
    [self addObservers];
    
    _callInfoView.backgroundColor=[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyZdywFontColor];
    _waitLabel.textColor=[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyZdywFontColor];
    _strangeCallLabel.textColor=[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyZdywFontColor];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.navigationController.navigationBarHidden = YES;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self removeObservers];
}

#pragma mark - PublicMethod

- (void)startCall:(CallInfoNode *)callInfoNode{
    _myCallInfoNode = callInfoNode;
    _nameLable.text = callInfoNode.calleeName;
    if (callInfoNode.calleeName == nil) {
        _nameLable.text = callInfoNode.calleePhone;
    }
    _areaLable.text = [self phoneAttributionForPhone:callInfoNode.calleePhone];
    [self startCallBackRequest];
}

#pragma mark - Observers

- (void)addObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveCallBackData:)
                                                 name:kNotificationCallFinish
                                               object:nil];
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationCallFinish
                                                  object:nil];
}

#pragma mark - HttpAction

- (void)receiveCallBackData:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    int nRet = [[dic objectForKey:@"result"] intValue];
    NSString *strReason = [dic objectForKey:@"reason"];
    [self removeObservers];
    
    if (nRet == 40)
    {
        NSString *msgTitle=[NSString stringWithFormat:@"%@提示",[ZdywCommonFun getAppConfigureInfoWithKey:kZdywDataKeyDisplayName]];
        NSString * alertMsg = [NSString stringWithFormat:@"为了保证您的正常拨打和号码显示，请验证您的手机"];
        UIAlertView *AlertView = [[UIAlertView alloc] initWithTitle:msgTitle
                                                            message:alertMsg
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"验证手机", nil];
        
        [AlertView show];
        return;

    }
    [self showCallBackErr:strReason isErr:(nRet != 0)];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{


    if (buttonIndex != 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBindPhoneView
                                                            object:nil
                                                          userInfo:nil];
    }
    
        [self performSelectorOnMainThread:@selector(dimissBackCallViewInMain)
                               withObject:nil
                            waitUntilDone:YES];
    
}

//展示回拨错误码
- (void)showCallBackErr:(NSString *)errMsg isErr:(BOOL)isErr
{
    [SVProgressHUD showInView:[ZdywAppDelegate appDelegate].window
                       status:errMsg
             networkIndicator:NO
                         posY:-1
                     maskType:SVProgressHUDMaskTypeClear];
    
    [self insertOneCallRecord];
    if (isErr)
    {
        [SVProgressHUD dismissWithError:errMsg afterDelay:4.5];
        [self dismissBackCallView];
        return;
    }
    else
    {
        [SVProgressHUD dismissWithSuccess:errMsg afterDelay:4.5];
    }
    if (_backDismissTimer)
    {
        if ([_backDismissTimer isValid])
        {
            [_backDismissTimer invalidate];
        }
        _backDismissTimer = nil;
    }
    _backDismissTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                         target:self
                                                       selector:@selector(dismissBackCallView)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (void)dismissBackCallView
{
    if(_backDismissTimer != nil)
    {
        [_backDismissTimer invalidate];
        _backDismissTimer = nil;
    }
    [self performSelectorOnMainThread:@selector(dimissBackCallViewInMain)
                           withObject:nil
                        waitUntilDone:YES];
}

//回拨页面消失
- (void)dimissBackCallViewInMain
{
    [CallWrapper shareCallWrapper].isCalling = NO;
    [_pointImageView stopAnimating];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.view removeFromSuperview];
    [[ZdywAppDelegate appDelegate].window makeKeyAndVisible];
}

//插入通话记录
- (void)insertOneCallRecord
{
    NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-0];
    ContactRecordNode *oneRecord = [[ContactRecordNode alloc] init];
    oneRecord.contactID = self.myCallInfoNode.calleeRecordID;
    oneRecord.phoneNum = self.myCallInfoNode.calleePhone;
    [oneRecord dateStringFromDate:startDate];    //通话时间
    oneRecord.recordType = self.myCallInfoNode.calltype;  //通话类型
    //处理呼叫号码
    NSString  *countryCode = [ZdywUtils getLocalStringDataValue:kCurrentCountryCode];
    
    if ([self.myCallInfoNode.calleePhone hasPrefix:@"+"]) {    //处理呼叫号码
        oneRecord.phoneNum = [NSString stringWithFormat:@"86%@",[[ContactManager shareInstance] deleteCountryCodeFromPhoneNumber:self.myCallInfoNode.calleePhone
                                                                                                                     countryCode:countryCode]];
    } else if(![[self.myCallInfoNode.calleePhone substringToIndex:2] isEqualToString:@"86"]){
        oneRecord.phoneNum = [[ContactManager shareInstance] deleteCountryCodeFromPhoneNumber:self.myCallInfoNode.calleePhone
                                                                                  countryCode:countryCode];
    }
    NSLog(@"通话开始时间:%@_%@",oneRecord.recordDateString,startDate);
    if ([[ContactManager shareInstance].myRecordEngine insertOneRecord:oneRecord])
    {
        NSArray *aList = [[ContactManager shareInstance].myRecordEngine allRecord];
        if ([aList count] > 0)
        {
            ContactRecordNode *resultRecord = [[ContactRecordNode alloc] initWithDictionary:[aList objectAtIndex:0]];
            if (resultRecord && [resultRecord isKindOfClass:[ContactRecordNode class]])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CallRecordRefresh"
                                                                    object:nil
                                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                            resultRecord,@"Record",
                                                                            nil]];
            }
        }
    }
}

#pragma mark - PrivateMethod

//开始回拨呼叫请求
- (void)startCallBackRequest
{
    
//    int callPhoneCount = [[ZdywUtils getLocalIdDataValue:kUserCallPhoneCount] intValue];
//    if (callPhoneCount > kMaxFeelCPhoneCount)
//    {
//        // 弹框验证手机框
//        return;
//    }

    NSString *strData = @"callee=%@";
    //获取callee(被叫号码)
    //处理呼叫号码
    NSString  *countryCode = [ZdywUtils getLocalStringDataValue:kCurrentCountryCode];
    //去掉电话号码的特殊字符
    NSString *callNumberStr = [[ContactManager shareInstance] deleteCountryCodeFromPhoneNumber:_myCallInfoNode.calleePhone
                                                                                   countryCode:countryCode];
    
    NSString *strCallee = [self dealPhoneNumbe:callNumberStr];
    strData = [NSString stringWithFormat:strData, strCallee];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceBackCall
                                              userInfo:nil
                                              postDict:dic];
}

//处理电话号码，判断是否加上区号
- (NSString *)dealPhoneNumbe:(NSString *)phoneNum
{
    NSString *resutlNumber = [NSString stringWithFormat:@"%@",phoneNum];
    if ([ZdywUtils getLocalDataBoolen:kIsChinaAcount])
    {
        //如果不是手机号 第一位是非零 = 座机
        BOOL isMobile = [ZdywUtils isMobileNumber:phoneNum];
        if(!isMobile)
        {
            int h = [[phoneNum substringWithRange:NSMakeRange(0,1)] intValue];
            if (h != 0)
            {
                NSString *userID = [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserID];
                NSString *aKey = [NSString stringWithFormat:@"%@_%@",
                                  userID,
                                  kUserDefaultZone];
                NSString *defaultZone = [ZdywUtils getLocalStringDataValue:aKey];
                if ([defaultZone length] > 0)
                {
                    resutlNumber = [NSString stringWithFormat:@"%@%@", defaultZone, phoneNum];
                }
            }
        }
    }
    return resutlNumber;
}

//获取联系人号码归属地
- (NSString *)phoneAttributionForPhone:(NSString *)phoneNumber
{
    
    NSString *attStr = [[ContactManager shareInstance] phoneAttributionWithPhoneNumber:phoneNumber
                                                                           countryCode:[ZdywUtils getLocalStringDataValue:kCurrentCountryCode]];
    if (0 == [attStr length])
    {
        attStr = @"未知";
    }
    return attStr;
}

@end
