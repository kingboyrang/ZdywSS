//
//  MainMenuViewController.m
//  ZdywClient
//
//  Created by ddm on 5/21/14.
//  Copyright (c) 2014 ddm GuoLing. All rights reserved.
//

#import "MainMenuViewController.h"
#import "ContactDetailViewController.h"
#import "ContactViewController.h"
#import "ZdywBaseNavigationViewController.h"
#import "UIImage+Scale.h"
#import "GuideView.h"
#import "UserBalanceViewController.h"
#import "UserYMBalanceViewController.h"
#import "HelpCenterViewController.h"
#import "UserSetupViewController.h"
#import "UserFeedbackViewController.h"
#import "UserRechargeViewController.h"
#import "UserAccountViewController.h"
#import "UserMessageViewController.h"
#import "WebsiteViewController.h"
#import "RichMessageEngine.h"
#import "FindPwdViewController.h"
#import "ModifyPWDViewController.h"
#import "RechargeInstructionViewController.h"
#import "DialTypeViewController.h"
#import "AboutViewController.h"
#import "VerifyViewController.h"
#import "SystemNoticeViewController.h"

#define CursorImageViewY        42
#define TipView_Tag             1003
#define SystemNotice_Tag        1004
#define systemNoticeView_Tag    1005

@interface MainMenuViewController (){
    CGPoint _startPoint;
    CGPoint _endPoint;
}

@property (nonatomic, strong) CallListView      *callListView;
@property (nonatomic, strong) ContactListView   *contactListView;
@property (nonatomic, strong) FuncMenuView      *funcMeunView;
@property (nonatomic, strong) UIImageView       *cursorImageView;
@property (nonatomic, strong) UIView            *funcMeunBgView;

@end

@implementation MainMenuViewController

#pragma mark - liftCycle

- (void)viewDidLoad
{
    self.navigationItem.titleView = _headTitleView;
    [self.view setUserInteractionEnabled:YES];
    _msgIconImageView.hidden = YES;
    if ([ZdywAppDelegate appDelegate].isNewMsg) {
        _msgIconImageView.hidden = NO;
    }
    [super viewDidLoad];
    [self initMainView];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(showFuncMenuView)];
    }else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    /***
    if (![[NSUserDefaults standardUserDefaults] boolForKey:KZdywAppFristLaunch]) {
        [self addTipView];
    }
     ***/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustUI) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receviceNewMsg) name:kNotificationReceiveNewPushMsg object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(afferCall)
                                                 name:@"CallRecordRefresh"
                                               object:nil];
    
    //显示帮助提示监听(ios8)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showTipView)
                                                 name:kUserLoginSuccess
                                               object:nil];
    // frank
    [self addObservers];
    [self getactivityInfo];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title =@"返回";
    
    [self adjustUI];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.mianScrollView.contentOffset.x == 0) {             //防止错屏
        [UIView animateWithDuration:0.01 animations:^{
            [_mianScrollView setContentOffset:CGPointMake(1, 0)];
        } completion:^(BOOL finished) {
            [_mianScrollView setContentOffset:CGPointMake(0, 0)];
        }];
    } else if (self.mianScrollView.contentOffset.x == 320) {
        [UIView animateWithDuration:0.01 animations:^{
            [_mianScrollView setContentOffset:CGPointMake(319, 0)];
        } completion:^(BOOL finished) {
            [_mianScrollView setContentOffset:CGPointMake(320, 0)];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self removeObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - HttpReceiveData
- (void)showNoiceView:(NSNotification *)notification
{
    
    //_noticeView.hidden =  NO;
    if (IOS7)
    {
        if (kZdywClientIsIphone5)
        {
            _callListView.frame = CGRectMake(0, 64+kCallListViewOffSet, 320, self.mianScrollView.frame.size.height-64-kCallListViewOffSet);
            [_callListView updateSubViewFrame:NO];
        }
        else
        {
            _callListView.frame = CGRectMake(0, 64+kCallListViewOffSet, 320, 480 - self.mianScrollView.frame.origin.y-64-kCallListViewOffSet);
            [_callListView updateSubViewFrame:NO];
        }
    }
    else
    {
        if (kZdywClientIsIphone5)
        {
            _callListView.frame = CGRectMake(0, kCallListViewOffSet, 320, self.mianScrollView.frame.size.height-kCallListViewOffSet);
            [_callListView updateSubViewFrame:NO];
        }
        else
        {
            _callListView.frame = CGRectMake(0, kCallListViewOffSet, 320, 416 - self.mianScrollView.frame.origin.y-kCallListViewOffSet);
            [_callListView updateSubViewFrame:NO];
        }
    }



}
- (void)showCallList:(NSNotification *)notification
{
    [self showCallListView];
}
- (void)showBindView:(NSNotification *)notification
{
        VerifyViewController * verifyView   = [[VerifyViewController alloc] initWithNibName:NSStringFromClass([VerifyViewController class]) bundle:nil];
        verifyView.showType =1;
        [self.navigationController pushViewController:verifyView animated:YES];
}
- (void)getLocalDefaualCfg:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    
    switch ([[dic objectForKey:@"result"]intValue])
    {
        case 0:
        {
            NSString *Title = [dic objectForKey:@"pay_info"];
            NSString *subTitle = [dic objectForKey:@"favourable_info"];
            if(![Title isEqualToString:@""] && ![subTitle isEqualToString:@""])
            {
                _noticeView.hidden =  NO;
                _noticeLable.text =[NSString stringWithFormat:@"       %@:%@",Title,subTitle];
            }
            else
            {
                [self isHiddennoticeView:YES];
            }

        }
        break;
        default:
            _noticeLable.text = @"";
            [self isHiddennoticeView:YES];
            break;
    }
    
}
- (void)afferCall
{
    [self performSelector:@selector(adjustUI) withObject:self afterDelay:1.0];
}


#pragma mark - observers

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter ] addObserver:self
                                              selector:@selector(getLocalDefaualCfg:)
                                                  name:kNotificationSystemnoticeFinish
                                                object:nil];
    
    [[NSNotificationCenter defaultCenter ] addObserver:self
                                              selector:@selector(showNoiceView:)
                                                  name:kNotificationShowNoticeView
                                                object:nil];
    [[NSNotificationCenter defaultCenter ] addObserver:self
                                              selector:@selector(showBindView:)
                                                  name:kNotificationBindPhoneView
                                                object:nil];
    
    [[NSNotificationCenter defaultCenter ] addObserver:self
                                              selector:@selector(showCallList:)
                                                  name:kNotificationCallList
                                                object:nil];
    
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationDefaultConfigFinish object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationShowNoticeView object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationBindPhoneView object:nil];
}


#pragma mark - GestureRecognizerAction

- (void)receviceNewMsg{
    _msgIconImageView.hidden = NO;
}

-(void)handleSwipeFrom:(UIPanGestureRecognizer *)recognizer{
    if (_contactListView.searchTextField.isFirstResponder) {
        [_contactListView.searchTextField resignFirstResponder];
        return;
    }
    if (_funcMeunView.hidden == NO) {
        [self showFuncMenuView:NO];
    }
    CGPoint touchPoint = [recognizer locationInView:self.view];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _startPoint = touchPoint;
        return;
    }
    if (_mainMenuShowType == MainMenuShowType_CallList) {
        if ((_startPoint.x - touchPoint.x>0)) {
            _mianScrollView.contentOffset = CGPointMake(_startPoint.x - touchPoint.x, 0);
            _cursorImageView.center = CGPointMake(_callListBtn.center.x + (_startPoint.x - touchPoint.x)*(_contactListBtn.center.x - _callListBtn.center.x)/320, CursorImageViewY);
        } else {
            return;
        }
    } else {
        if (touchPoint.x - _startPoint.x>0) {
            _mianScrollView.contentOffset = CGPointMake(320-(touchPoint.x - _startPoint.x), 0);
            _cursorImageView.center = CGPointMake(_contactListBtn.center.x -(touchPoint.x - _startPoint.x)*(_contactListBtn.center.x - _callListBtn.center.x)/320, CursorImageViewY);
        }else {
            return;
        }
    }
    if (recognizer.state == UIGestureRecognizerStateEnded){
        if (_mainMenuShowType == MainMenuShowType_CallList) {
            if ((_startPoint.x - touchPoint.x>80)) {
                [UIView animateWithDuration:0.35 animations:^{
                    _mianScrollView.contentOffset = CGPointMake(320, 0);
                    _cursorImageView.center =CGPointMake( _contactListBtn.center.x, CursorImageViewY);
                    _mainMenuShowType = MainMenuShowType_ContactList;
                    [_contactListView loadFirstContact];//重新加载联系人
                    
                    [_contactListBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyMainSelectedFontColor] forState:UIControlStateNormal];
                    [_callListBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyMainNormalFontColor] forState:UIControlStateNormal];
                    [_contactListBtn setEnabled:NO];
                    [_callListBtn setEnabled:YES];
                }];
            } else {
                [UIView animateWithDuration:0.35 animations:^{
                    _mianScrollView.contentOffset = CGPointMake(0, 0);
                    _mainMenuShowType = MainMenuShowType_CallList;
                    _cursorImageView.center =CGPointMake( _callListBtn.center.x, CursorImageViewY);
                }];
            }
        } else {
            if (touchPoint.x - _startPoint.x>80) {
                [UIView animateWithDuration:0.35 animations:^{
                    _mianScrollView.contentOffset = CGPointMake(0, 0);
                    _mainMenuShowType = MainMenuShowType_CallList;
                    _cursorImageView.center =CGPointMake( _callListBtn.center.x, CursorImageViewY);
                    
                    [_callListBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyMainSelectedFontColor] forState:UIControlStateNormal];
                    [_contactListBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyMainNormalFontColor] forState:UIControlStateNormal];
                    [_contactListBtn setEnabled:YES];
                    [_callListBtn setEnabled:NO];
                }];
            }else {
                [UIView animateWithDuration:0.35 animations:^{
                    _mianScrollView.contentOffset = CGPointMake(320, 0);
                    _mainMenuShowType = MainMenuShowType_ContactList;
                    _cursorImageView.center =CGPointMake( _contactListBtn.center.x, CursorImageViewY);
                }];
            }
        }
    }
}

#pragma mark - BtnAction

- (void)enterDetailsView
{
   
    [self isHiddennoticeView:YES];
    SystemNoticeViewController * NoticeView   = [[SystemNoticeViewController alloc] initWithNibName:NSStringFromClass([SystemNoticeViewController class]) bundle:nil];
    
    NoticeView.noticeText = _noticeLable.text;
    [self.navigationController pushViewController:NoticeView animated:YES];

    
}

- (void)hideTipView{
    UIView *tipView = [[ZdywAppDelegate appDelegate].window viewWithTag:TipView_Tag];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KZdywAppFristLaunch];
    [tipView removeFromSuperview];
}

- (void)showCallListView{
    if (_funcMeunView.hidden == NO) {
        [self showFuncMenuView:NO];
    }
    if (_mainMenuShowType != MainMenuShowType_CallList) {
        [_contactListBtn setEnabled:YES];
        [_callListBtn setEnabled:NO];
        _mainMenuShowType = MainMenuShowType_CallList;
        [UIView animateWithDuration:0.35 animations:^{
            [_contactListView.searchTextField resignFirstResponder];
            _mianScrollView.contentOffset = CGPointMake(0, 0);
            _cursorImageView.center = CGPointMake(_callListBtn.center.x, CursorImageViewY);
            
            [_callListBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyMainSelectedFontColor] forState:UIControlStateNormal];
            [_contactListBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyMainNormalFontColor] forState:UIControlStateNormal];
        }];
    }
}

- (void)showContactListView{
    if (_funcMeunView.hidden == NO) {
        [self showFuncMenuView:NO];
    }
    if (_mainMenuShowType != MainMenuShowType_ContactList) {
        [_contactListBtn setEnabled:NO];
        [_callListBtn setEnabled:YES];
        _mainMenuShowType = MainMenuShowType_ContactList;
        [UIView animateWithDuration:0.35 animations:^{
            _mianScrollView.contentOffset = CGPointMake(320, 0);
            _cursorImageView.center = CGPointMake(_contactListBtn.center.x, CursorImageViewY);
            [_contactListView loadFirstContact];//重新加载联系人
            [_contactListBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyMainSelectedFontColor] forState:UIControlStateNormal];
            [_callListBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyMainNormalFontColor] forState:UIControlStateNormal];
        }];
    }
}

- (void)showFuncMenuView
{

    [self showFuncMenuView:_funcMeunBgView.hidden];
}

#pragma mark - PublicMethod



- (void)showSystemNoticeView{
    UIView *systemNoticeBgView = [[UIView alloc] initWithFrame:[ZdywAppDelegate appDelegate].window.frame];
    [systemNoticeBgView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7]];
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSystemNoticeView)];
    [systemNoticeBgView setUserInteractionEnabled:YES];
    [systemNoticeBgView addGestureRecognizer:tapGr];
    systemNoticeBgView.tag = SystemNotice_Tag;
    [[ZdywAppDelegate appDelegate].window addSubview:systemNoticeBgView];
    SystemNoticeView *systemNoticeView = [[SystemNoticeView alloc] initWithSysMessageObj:[ZdywAppDelegate appDelegate].sysMessage];
    systemNoticeView.delegate = self;
    systemNoticeView.tag = systemNoticeView_Tag;
    [systemNoticeView systemNoticeFrame];
    systemNoticeView.frame = CGRectMake(0, -systemNoticeView.frame.size.height, systemNoticeView.frame.size.width, systemNoticeView.frame.size.height);
    [systemNoticeBgView addSubview:systemNoticeView];
    [UIView animateWithDuration:0.35 animations:^{
        systemNoticeView.frame = [systemNoticeView systemNoticeFrame];
    }];
}

- (void)dismissSystemNoticeView{
    UIView *view = [[ZdywAppDelegate appDelegate].window viewWithTag:SystemNotice_Tag];
    SystemNoticeView *systemNoticeView = (SystemNoticeView*)[view viewWithTag:systemNoticeView_Tag];
    [UIView animateWithDuration:0.35 animations:^{
        systemNoticeView.frame = CGRectMake(0, -systemNoticeView.frame.size.height, systemNoticeView.frame.size.width, systemNoticeView.frame.size.height);
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}

#pragma mark - PrivateMethod
//显示帮助提示
- (void)showTipView{
    NSString *uidStr = [ZdywUtils getLocalIdDataValue:kZdywDataKeyUserID];
    NSString *pwdStr = [ZdywUtils getLocalIdDataValue:kZdywDataKeyUserPwd];
    NSString *phoneStr = [ZdywUtils getLocalIdDataValue:kZdywDataKeyUserPhone];
    if (![uidStr length] || ![pwdStr length] || ![phoneStr length]) {//表示未登陆
        
    }else{//表示已登陆
        if (![[NSUserDefaults standardUserDefaults] boolForKey:KZdywAppFristLaunch]) {
            [self addTipView];
        }
    }
}
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
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceSysMessage
                                              userInfo:nil
                                              postDict:dic];
    
}


-(void)isHiddennoticeView:(BOOL)show
{
    if (IOS7)
    {
        if (kZdywClientIsIphone5)
        {
            _callListView.frame = CGRectMake(0, 64, 320, self.mianScrollView.frame.size.height-64);
        }
        else
        {
            _callListView.frame = CGRectMake(0, 64, 320, 480 - self.mianScrollView.frame.origin.y-64);
        }
        
    }
    else
    {
        if (kZdywClientIsIphone5)
        {
            _callListView.frame = CGRectMake(0, 0, 320, self.mianScrollView.frame.size.height);
            
        }
        else
        {
            _callListView.frame = CGRectMake(0, 0, 320, 416 - self.mianScrollView.frame.origin.y);
        }
    }
    
    [_callListView updateSubViewFrame:show];
    _noticeView.hidden =YES;

    
}


- (void)adjustUI{
    [self performSelector:@selector(changeStatusBar) withObject:nil afterDelay:0.1];
    if (self.mianScrollView.contentOffset.x == 0) {             //防止错屏
        [UIView animateWithDuration:0.02 animations:^{
            [_mianScrollView setContentOffset:CGPointMake(1, 0)];
        } completion:^(BOOL finished) {
            [_mianScrollView setContentOffset:CGPointMake(0, 0)];
        }];
    } else if (self.mianScrollView.contentOffset.x == 320) {
        [UIView animateWithDuration:0.01 animations:^{
            [_mianScrollView setContentOffset:CGPointMake(319, 0)];
        } completion:^(BOOL finished) {
            [_mianScrollView setContentOffset:CGPointMake(320, 0)];
        }];
    }
}

- (void)changeStatusBar{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)addTipView{
    UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    tipView.tag = TipView_Tag;
    [tipView setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.1]];
    [[ZdywAppDelegate appDelegate].window addSubview:tipView];
    
    UIImageView *tipViewBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tipView.frame.size.width, tipView.frame.size.height)];
    tipViewBg.image = [[[UIImage imageNamed:@"menu_guide_bg.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:165] scaleToSize:CGSizeMake(tipView.frame.size.width*2, tipView.frame.size.height*2)];
    [tipViewBg setBackgroundColor:[UIColor clearColor]];
    [tipView addSubview:tipViewBg];
    
    GuideView *guideView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([GuideView class]) owner:self options:nil] objectAtIndex:0];
    guideView.frame = CGRectMake(0, 66, 320, guideView.frame.size.height);
    [tipView addSubview:guideView];
    
    tipView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideTipView)];
    tapGr.numberOfTapsRequired = 1;
    [tipView addGestureRecognizer:tapGr];
}

- (void)initMainView
{
    //系统颜色
    [_callListBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyMainSelectedFontColor] forState:UIControlStateNormal];
    [_contactListBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyMainNormalFontColor] forState:UIControlStateNormal];
    
    [_callListBtn addTarget:self action:@selector(showCallListView) forControlEvents:UIControlEventTouchUpInside];
    [_contactListBtn addTarget:self action:@selector(showContactListView) forControlEvents:UIControlEventTouchUpInside];
    [_funcMenuBtn addTarget:self action:@selector(showFuncMenuView) forControlEvents:UIControlEventTouchUpInside];
    
    _cursorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_callListBtn.center.x-7, 38, 14, 7)];
    [_cursorImageView setImage:[UIImage imageNamed:@"mian_triangle"]];
    [self.headTitleView addSubview:_cursorImageView];
    
    _mainMenuShowType = MainMenuShowType_CallList;
    if (kZdywClientIsIphone5)
    {
        if (IOS7)
        {
             _callListView = [[CallListView alloc] initWithFrame:CGRectMake(0, 64+kCallListViewOffSet, 320, self.mianScrollView.frame.size.height-64-kCallListViewOffSet)];
        }
        else
        {
            _callListView = [[CallListView alloc] initWithFrame:CGRectMake(0, kCallListViewOffSet, 320, self.mianScrollView.frame.size.height-44-kCallListViewOffSet)];
            
        }
       
    }
    else
    {
        if (IOS7)
        {
            _callListView = [[CallListView alloc] initWithFrame:CGRectMake(0, 64+kCallListViewOffSet, 320, 480 - self.mianScrollView.frame.origin.y-64-kCallListViewOffSet)];
        }
        else
        {
            _callListView = [[CallListView alloc] initWithFrame:CGRectMake(0, kCallListViewOffSet, 320, 460 - self.mianScrollView.frame.origin.y-44-kCallListViewOffSet)];
            
        }
        
    }
    _callListView.delegate = self;
    _callListView.backgroundColor = [UIColor clearColor];
    [self.mianScrollView addSubview:_callListView];
    
    _contactListView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ContactListView class]) owner:self options:nil] objectAtIndex:0];
    _contactListView.frame = CGRectMake(320, 64, 320, self.mianScrollView.frame.size.height-64);
    [_contactListView setDelegate:self];
    _contactListView.backgroundColor = [UIColor clearColor];
    [self.mianScrollView addSubview:_contactListView];

    if (IOS7)
    {
        _noticeView.frame = CGRectMake(0, 64, 320, kCallListViewOffSet);
    }
    else
    {
        _noticeView.frame = CGRectMake(0, 0, 320, kCallListViewOffSet);
    }
    
    [self.mianScrollView addSubview:_noticeView];
    

    [_detailsBtn addTarget:self action:@selector(enterDetailsView) forControlEvents:UIControlEventTouchUpInside];
    
    self.mianScrollView.contentSize = CGSizeMake(640, 0);
    self.mianScrollView.scrollEnabled = NO;
    self.mianScrollView.showsHorizontalScrollIndicator = NO;
    UIPanGestureRecognizer *panGr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [self.mianScrollView addGestureRecognizer:panGr];
    
    _funcMeunBgView = [[UIView alloc] initWithFrame:self.view.frame];
    [_funcMeunBgView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_funcMeunBgView];
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideFuncMenuView:)];
    [tapGr setDelegate:self];
    [_funcMeunBgView setUserInteractionEnabled:YES];
    [_funcMeunBgView addGestureRecognizer:tapGr];
    [_funcMeunBgView setHidden:YES];
    
    _funcMeunView = [[FuncMenuView alloc] initWithFrame:CGRectMake(140, 65, 178, 350)];
    [_funcMeunView setDelagate:self];
    [_funcMeunBgView addSubview:_funcMeunView];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)//ios7 以下界面适配
    {
//        if (kZdywClientIsIphone5)
//        {
//            _callListView.frame = CGRectMake(0, 0, 320, self.mianScrollView.frame.size.height-64);
//        }
//        else
//        {
//            _callListView.frame = CGRectMake(0, 0, 320, 480 - self.mianScrollView.frame.origin.y-64);
//        }
        _contactListView.frame = CGRectMake(320, 0, 320, self.mianScrollView.frame.size.height);
        _funcMeunView.frame  = CGRectMake(140, 1, 178, 350);
    }
}

- (void)showFuncMenuView:(BOOL)isShow{
    if (isShow) {
        [UIView animateWithDuration:0.35 animations:^{
            _funcMeunBgView.alpha = 1.0;
            _funcMeunBgView.hidden = NO;
            [_contactListView.searchTextField resignFirstResponder];
            [_funcMeunView updateMainUI];
        } completion:^(BOOL finished) {
        }];
    } else {
        [UIView animateWithDuration:0.35 animations:^{
            _funcMeunBgView.alpha = 0.0;
        } completion:^(BOOL finished) {
            _funcMeunBgView.hidden = YES;
        }];
    }
}

- (void)hideFuncMenuView:(UITapGestureRecognizer*)tapGr{
    if (_funcMeunBgView.hidden == NO) {
        [UIView animateWithDuration:0.35 animations:^{
            _funcMeunBgView.alpha = 0.0;
        } completion:^(BOOL finished) {
            _funcMeunBgView.hidden = YES;
        }];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (_funcMeunView.hidden == NO) {
        CGPoint point = [touch locationInView:self.view];
        if (CGRectContainsPoint(_funcMeunView.frame, point)) {
            return NO;
        }
        return YES;
    }
    return NO;
}

#pragma mark - ContactListViewDelegate

- (void)showContactDetailView:(ContactNode *)contactNodeInfo{
    ContactDetailViewController *contactDetailView = [[ContactDetailViewController alloc] initWithNibName:NSStringFromClass([ContactDetailViewController class]) bundle:nil];
    contactDetailView.contactNode = contactNodeInfo;
    contactDetailView.contactDetailType = ContactDetailViewTypeNormal;
    [self.navigationController pushViewController:contactDetailView animated:YES];
}

- (void)addNewContact{
    _myNewPersonController = [[ABNewPersonViewController alloc] init];
    _myNewPersonController.newPersonViewDelegate = self;
    [_myNewPersonController.navigationController setNavigationBarHidden:NO];
    ZdywBaseNavigationViewController *aNav = [[ZdywBaseNavigationViewController alloc] initWithRootViewController:self.myNewPersonController];
    [self.navigationController presentModalViewController:aNav animated:YES];
}

#pragma mark - FuncMenuViewDelegate

- (void)showFuncMenuDetailView:(FuncMenuModel *)funcMenuModel{
    [self showFuncMenuView:NO];
    switch (funcMenuModel.funcMenuType) {
        case FuncMenuType_Message:{
            if (_msgIconImageView.hidden == NO) {
                _msgIconImageView.hidden = YES;
            }
            UserMessageViewController *userMessageView = [[UserMessageViewController alloc] initWithNibName:NSStringFromClass([UserMessageViewController class]) bundle:nil];
            [self.navigationController pushViewController:userMessageView animated:YES];
            break;
        }
        case FuncMenuType_Balance:{
            
            BOOL hasBagYM=[ZdywUtils getLocalDataBoolen:kZdywDataKeyBagMonthOrYear];
            if (hasBagYM) {//有包年/月套餐
                UserYMBalanceViewController *userBalanceView = [[UserYMBalanceViewController alloc] initWithNibName:NSStringFromClass([UserYMBalanceViewController class]) bundle:nil];
                [self.navigationController pushViewController:userBalanceView animated:YES];
                
            }else{
                UserBalanceViewController *userBalanceView = [[UserBalanceViewController alloc] initWithNibName:NSStringFromClass([UserBalanceViewController class]) bundle:nil];
                [self.navigationController pushViewController:userBalanceView animated:YES];
            }
            
            break;
        }
        case FuncMenuType_Recharge:{
            UserRechargeViewController *userRechargeView = [[UserRechargeViewController alloc] initWithNibName:NSStringFromClass([UserRechargeViewController class]) bundle:nil];
            [self.navigationController pushViewController:userRechargeView animated:YES];
            break;
        }
        case FuncMenuType_Account:{
            WebsiteViewController *websiteView = [[WebsiteViewController alloc] initWithNibName:NSStringFromClass([WebsiteViewController class]) bundle:nil];
            [websiteView setTitle:@"账单" withURL:[ZdywCommonFun getCallLogUrl]];
            [self.navigationController pushViewController:websiteView animated:YES];
            break;
        }
        case FuncMenuType_Setup:{
            UserSetupViewController *userSetupView = [[UserSetupViewController alloc] initWithNibName:NSStringFromClass([UserSetupViewController class]) bundle:nil];
            [self.navigationController pushViewController:userSetupView animated:YES];
            break;
        }
        case FuncMenuType_Help:{
            HelpCenterViewController *helpCenterView = [[HelpCenterViewController alloc] initWithNibName:NSStringFromClass([HelpCenterViewController class]) bundle:nil];
            [self.navigationController pushViewController:helpCenterView animated:YES];
            break;
        }
        case FuncMenuType_Feedback:{
            UserFeedbackViewController *userFeedbackView = [[UserFeedbackViewController alloc] initWithNibName:NSStringFromClass([UserFeedbackViewController class]) bundle:nil];
            [self.navigationController pushViewController:userFeedbackView animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - CallListViewDelegate

- (void)showRecordMegerDetailView:(RecordMegerNode *)recordNode{
    ContactDetailViewController *contactDetailView = [[ContactDetailViewController alloc] initWithNibName:NSStringFromClass([ContactDetailViewController class]) bundle:nil];
    contactDetailView.recordMegerNode = recordNode;
    ContactNode *contactInfo = [[ContactManager shareInstance] getOneContactByID:recordNode.contactID];
    if (contactInfo) {
        contactDetailView.contactDetailType = ContactDetailViewTypeCall;
    } else {
        contactDetailView.contactDetailType = ContactDetailViewTypeUnKnowCall;
    }
    contactDetailView.contactNode = contactInfo;
    [self.navigationController pushViewController:contactDetailView animated:YES];
}

- (void)showContactDetailViewWithContactID:(NSInteger)contactID{
    ContactNode *contactNode = [[ContactManager shareInstance] getOneContactByID:contactID];
    [self showContactDetailView:contactNode];
}

- (void)addNewContact:(NSString *)phoneStr{
    ABRecordRef aContact = ABPersonCreate();
    CFErrorRef anError = NULL;
    ABMutableMultiValueRef phoneLabe = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(phoneLabe,(__bridge CFStringRef)phoneStr, kABPersonPhoneMobileLabel, NULL);
    ABRecordSetValue(aContact, kABPersonPhoneProperty, phoneLabe, &anError);
    _myNewPersonController = [[ABNewPersonViewController alloc] init];
    _myNewPersonController.newPersonViewDelegate = self;
    _myNewPersonController.displayedPerson = aContact;
    [_myNewPersonController.navigationController setNavigationBarHidden:NO];
    ZdywBaseNavigationViewController *aNav = [[ZdywBaseNavigationViewController alloc] initWithRootViewController:self.myNewPersonController];
    [self.navigationController presentModalViewController:aNav animated:YES];
}

- (void)addNewNumToContact:(NSString *)phoneStr{
    ContactViewController * contactView = [[ContactViewController alloc] initWithNibName:NSStringFromClass([ContactViewController class]) bundle:nil];
    contactView.contactListType = ContactListTypeSingleChoose;
    contactView.phoneNumberStr = phoneStr;
    [self.navigationController pushViewController:contactView animated:YES];
}

#pragma mark - ABNewPersonViewControllerDelegate

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
    [ContactManager shareInstance].canLoadData = YES;
    _myNewPersonController.newPersonViewDelegate = nil;
    [newPersonView.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - SystemNoticeViewDelegate

- (void)systemNoticeView:(SysMessageObj *)sysmessage dissMiss:(NSInteger)dismissWithButtonIndex{
    [self dismissSystemNoticeView];
    if (dismissWithButtonIndex == 103) {
        NSInteger goType = sysmessage.msg_Type;
        NSString  *goPage = sysmessage.msg_redirectPage;
        if (goType == 0) {
            switch ([goPage intValue]) {
                case 0000:{             //通话记录
                    return;
                }
                case 1000:{             //联系人
                    [_contactListBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
                }
                    break;
                case 2000:{             //充值
                    UserRechargeViewController *userRechargeView = [[UserRechargeViewController alloc] initWithNibName:NSStringFromClass([UserRechargeViewController class]) bundle:nil];
                    [self.navigationController pushViewController:userRechargeView animated:YES];
                }
                    break;
                case 3010:{             //消息中心
                    UserMessageViewController *userMessageView = [[UserMessageViewController alloc] initWithNibName:NSStringFromClass([UserMessageViewController class]) bundle:nil];
                    [self.navigationController pushViewController:userMessageView animated:YES];
                }
                    break;
                case 3011:{             //设置
                    UserSetupViewController *userSetupView = [[UserSetupViewController alloc] initWithNibName:NSStringFromClass([UserSetupViewController class]) bundle:nil];
                    [self.navigationController pushViewController:userSetupView animated:YES];
                }
                    break;
                case 3013:{             //登录
                    [[ZdywAppDelegate appDelegate] showLoginView];
                }
                    break;
                case 3016:{             //查询余额
                    BOOL hasBagYM=[ZdywUtils getLocalDataBoolen:kZdywDataKeyBagMonthOrYear];
                    if (hasBagYM) {//有包年/月套餐
                        UserYMBalanceViewController *userBalanceView = [[UserYMBalanceViewController alloc] initWithNibName:NSStringFromClass([UserYMBalanceViewController class]) bundle:nil];
                        [self.navigationController pushViewController:userBalanceView animated:YES];
                        
                    }else{
                        UserBalanceViewController *userBalanceView = [[UserBalanceViewController alloc] initWithNibName:NSStringFromClass([UserBalanceViewController class]) bundle:nil];
                        [self.navigationController pushViewController:userBalanceView animated:YES];
                    }
                }
                    break;
                case 3018:{             //联系客服
                    HelpCenterViewController *helpCenterView = [[HelpCenterViewController alloc] initWithNibName:NSStringFromClass([HelpCenterViewController class]) bundle:nil];
                    [self.navigationController pushViewController:helpCenterView animated:YES];
                }
                    break;
                case 3019:{             //帮助中心
                    HelpCenterViewController *helpCenterView = [[HelpCenterViewController alloc] initWithNibName:NSStringFromClass([HelpCenterViewController class]) bundle:nil];
                    [self.navigationController pushViewController:helpCenterView animated:YES];
                }
                    break;
                case 3021:{             //找回密码
                    FindPwdViewController *findPwdView = [[FindPwdViewController alloc] initWithNibName:NSStringFromClass([FindPwdViewController class]) bundle:nil];
                    [self.navigationController pushViewController:findPwdView animated:YES];
                }
                    break;
                case 3022:{             //修改密码
                    ModifyPWDViewController *modifyPwd = [[ModifyPWDViewController alloc] initWithNibName:NSStringFromClass([ModifyPWDViewController class]) bundle:nil];
                    [self.navigationController pushViewController:modifyPwd animated:YES];
                }
                    break;
                case 3023:{             //充值说明
                    RechargeInstructionViewController *rechareInstr = [[RechargeInstructionViewController alloc] initWithNibName:NSStringFromClass([RechargeInstructionViewController class]) bundle:nil];
                    [self.navigationController pushViewController:rechareInstr animated:YES];
                }
                    break;
                case 3024:{             //查询话单
                    UserAccountViewController *userAccout = [[UserAccountViewController alloc] initWithNibName:NSStringFromClass([UserAccountViewController class]) bundle:nil];
                    [self.navigationController pushViewController:userAccout animated:YES];
                }
                    break;
                case 3029:{             //拨打设置
                    DialTypeViewController *dialTypeView = [[DialTypeViewController alloc] initWithNibName:NSStringFromClass([DialTypeViewController class]) bundle:nil];
                    [self.navigationController pushViewController:dialTypeView animated:YES];
                }
                    break;
                case 3033:{             //关于
                    AboutViewController *aboutView = [[AboutViewController alloc] initWithNibName:NSStringFromClass([AboutViewController class]) bundle:nil];
                    [self.navigationController pushViewController:aboutView animated:YES];
                }
                    break;
                default:
                    break;
            }
        } else {
            NSString *msg_urlStr = sysmessage.msg_url;
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:msg_urlStr]];
        }
    }
}

@end
