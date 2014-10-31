//
//  UserSetupViewController.m
//  ZdywClient
//
//  Created by ddm on 6/12/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "UserSetupViewController.h"
#import "MoreRowNode.h"
#import "MoreSectionNode.h"
#import "UserSetUpCell.h"
#import "ModifyPWDViewController.h"
#import "ChangeBindPhoneViewController.h"
#import "DialTypeViewController.h"
#import "ContactBackupViewController.h"
#import "AboutViewController.h"
#import "UIImage+Scale.h"
#import "ResetViewController.h"


@interface UserSetupViewController ()

@property (nonatomic, strong) NSMutableArray  *moreDataModelArray;
@property (nonatomic, assign) BOOL             bNewVersionFlag;

@end

@implementation UserSetupViewController

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
    self.title = @"设置";
    _bNewVersionFlag = NO;
    [self buildMoreDataModel];
    [_setUpTableView setDataSource:self];
    [_setUpTableView setDelegate:self];
    [_logoutBtn addTarget:self action:@selector(clickLogout:) forControlEvents:UIControlEventTouchUpInside];
    _logoutBtn.layer.masksToBounds = YES;
    _logoutBtn.layer.cornerRadius = 10.0;
    _logoutBtn.layer.borderWidth = 1.0;
    _logoutBtn.layer.borderColor = [UIColor colorWithRed:219.0/255 green:219.0/255 blue:219.0/255 alpha:1.0].CGColor;
    [_logoutBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    
    NSString *updateVersion = [ZdywUtils getLocalStringDataValue:kUpdateVersion];
    if([updateVersion length] <= 0)
    {
        updateVersion = [ZdywUtils getLocalStringDataValue:kZdywDataKeyVersion];
    }
    if ([updateVersion compare:[ZdywUtils getLocalStringDataValue:kZdywDataKeyVersion] options:NSNumericSearch] > 0)
    {
        _bNewVersionFlag = YES;
    }
    [_logoutBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyZdywFontColor] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 && !kZdywClientIsIphone5) {
        _setUpTableView.frame = CGRectMake(0, 0, 320, 340);
        _logoutBtn.frame = CGRectMake(20, 360, 280, 40);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PrivateMethod

- (void)buildMoreDataModel
{
    _moreDataModelArray = [[NSMutableArray alloc] initWithCapacity:0];
    //first section
    MoreSectionNode *sectionNode = [[MoreSectionNode alloc] init];
    MoreRowNode *rowNode = [[MoreRowNode alloc] init];
    rowNode.tag = Setup_ModifyPwd;
    rowNode.mainTitle = @"修改密码";
    [sectionNode.child addObject:rowNode];
    
    rowNode = [[MoreRowNode alloc] init];
    rowNode.tag = Setup_BindPhone;
    rowNode.mainTitle = @"改绑手机号";
    [sectionNode.child addObject:rowNode];
    [_moreDataModelArray addObject:sectionNode];
    
    sectionNode = [[MoreSectionNode alloc] init];
    rowNode = [[MoreRowNode alloc] init];
    rowNode.tag = Setup_DialType;
    rowNode.mainTitle = @"拨打方式设置";
    [sectionNode.child addObject:rowNode];
    
    rowNode = [[MoreRowNode alloc] init];
    rowNode.tag = Setup_KeySound;
    rowNode.mainTitle = @"按键音效";
    [sectionNode.child addObject:rowNode];
    
    [_moreDataModelArray addObject:sectionNode];
    
    sectionNode = [[MoreSectionNode alloc] init];
    rowNode = [[MoreRowNode alloc] init];
    rowNode.tag = Setup_BackUpContact;
    rowNode.mainTitle = @"备份联系人";
    [sectionNode.child addObject:rowNode];
    [_moreDataModelArray addObject:sectionNode];
    
    sectionNode = [[MoreSectionNode alloc] init];
    rowNode = [[MoreRowNode alloc] init];
    rowNode.tag = Setup_Update;
    rowNode.mainTitle = @"软件升级";
    [sectionNode.child addObject:rowNode];
    
    rowNode = [[MoreRowNode alloc] init];
    rowNode.tag = Setup_About;
    rowNode.mainTitle = @"关于";
    [sectionNode.child addObject:rowNode];
    
    [_moreDataModelArray addObject:sectionNode];
}

- (void)swithAction:(UISwitch *)swith{
    int soundOpen = [[ZdywUtils getLocalIdDataValue:kDialSoundFlag] intValue];
    if (soundOpen == 0)
    {
        soundOpen = 1;
    } else {
        soundOpen = 0;
    }
    [ZdywUtils setLocalIdDataValue:[NSString stringWithFormat:@"%d",soundOpen] key:kDialSoundFlag];
}

#pragma mark - btnAction

// 退出登录
- (IBAction)clickLogout:(id)sender
{
    NSString *alertTitle=[NSString stringWithFormat:@"%@提示",[ZdywCommonFun getAppConfigureInfoWithKey:kZdywDataKeyDisplayName]];
    UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:alertTitle
                                                     message:@"退出登录后想打电话会比较麻烦，您确认要这么做吗？"
                                                    delegate:self
                                           cancelButtonTitle:@"我还要用"
                                           otherButtonTitles:@"确认退出", nil];
    [msgbox show];
}

- (void)logout{
    
    [ZdywUtils setLocalDataString:NULL key:kZdywDataKeyUserID];
    [ZdywUtils setLocalDataString:NULL key:kZdywDataKeyUserPhone];
    [ZdywUtils setLocalDataString:NULL key:kZdywDataKeyUserPwd];
    
    if(IOS6)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCallList
                                                        object:nil
                                                       userInfo:nil];
    }

    [self.navigationController popToRootViewControllerAnimated:YES];
    [[ZdywAppDelegate appDelegate] showLoginView];
}

#pragma mark - UIAlertViewDelegate
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1)
    {
        [self logout];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_moreDataModelArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[_moreDataModelArray objectAtIndex:section] child] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserSetUpCell *setUpCell = (UserSetUpCell*)[tableView dequeueReusableCellWithIdentifier:@"UserSetupCell"];
    if (setUpCell == nil) {
        setUpCell = [[UserSetUpCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserSetupCell"];
    }
    MoreRowNode *node = [[[_moreDataModelArray objectAtIndex:indexPath.section] child]
                         objectAtIndex:indexPath.row];
    setUpCell.textLabel.text = node.mainTitle;
    switch (node.tag) {
        case Setup_ModifyPwd:
        case Setup_BindPhone:
        case Setup_DialType:
        case Setup_BackUpContact:
        case Setup_Update:
        case Setup_About:{
            UIImageView *jumpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(285, 14, 15, 18)];
            jumpImageView.image = [UIImage imageNamed:@"contact_detail_btn.png"];
            [setUpCell addSubview:jumpImageView];
        }
            break;
        case Setup_KeySound:{
            
            UISwitch *swithBtn = [[UISwitch alloc] initWithFrame:CGRectMake(250, 8, 30, 30)];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] <= 7.0) {
                swithBtn.frame = CGRectMake(220, 8, 30, 30);
            }
            int soundOpen = [[ZdywUtils getLocalIdDataValue:kDialSoundFlag] intValue];
            if (soundOpen == 0)
            {
                swithBtn.on = NO;
            } else {
                swithBtn.on = YES;
            }
            [swithBtn addTarget:self action:@selector(swithAction:) forControlEvents:UIControlEventValueChanged];
            [setUpCell addSubview:swithBtn];
        }
            break;
        default:
            break;
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        UIView *menuCellBackView = [[UIView alloc] initWithFrame:setUpCell.frame];
        menuCellBackView.backgroundColor = [UIColor lightGrayColor];
        [setUpCell setSelectedBackgroundView:menuCellBackView];
    }
    return setUpCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MoreRowNode *node = [[[_moreDataModelArray objectAtIndex:indexPath.section] child]
                         objectAtIndex:indexPath.row];
    switch (node.tag) {
        case Setup_ModifyPwd:{
//            ModifyPWDViewController *modifyPwdView = [[ModifyPWDViewController alloc] initWithNibName:NSStringFromClass([ModifyPWDViewController class]) bundle:nil];
             ResetViewController *modifyPwdView = [[ResetViewController alloc] initWithNibName:NSStringFromClass([ResetViewController class]) bundle:nil];
            [self.navigationController pushViewController:modifyPwdView animated:YES];
            break;
        }
        case Setup_BindPhone:{
            ChangeBindPhoneViewController *bindPhoneView = [[ChangeBindPhoneViewController alloc] initWithNibName:NSStringFromClass([ChangeBindPhoneViewController class]) bundle:nil];
            [self.navigationController pushViewController:bindPhoneView animated:YES];
            break;
        }
        case Setup_DialType:{
            DialTypeViewController *dialTypeView = [[DialTypeViewController alloc] initWithNibName:NSStringFromClass([DialTypeViewController class]) bundle:nil];
            [self.navigationController pushViewController:dialTypeView animated:YES];
            break;
        }
        case Setup_BackUpContact:{
            ContactBackupViewController *backUpView = [[ContactBackupViewController alloc] initWithNibName:NSStringFromClass([ContactBackupViewController class]) bundle:nil];
            [self.navigationController pushViewController:backUpView animated:YES];
            break;
        }
        case Setup_Update:{
            [self displayCheckVersion];
        }
            break;
        case Setup_About:{
            AboutViewController *aboutView = [[AboutViewController alloc] initWithNibName:NSStringFromClass([AboutViewController class]) bundle:nil];
            [self.navigationController pushViewController:aboutView animated:YES];
            break;
        }
        case Setup_KeySound:
            break;
        default:
            break;
    }
}

- (void)displayCheckVersion
{
    if(self.bNewVersionFlag)
    {
        [[ZdywAppDelegate appDelegate] displayUpdateView];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                         message:@"已经是最新版本"
                                                        delegate: nil
                                               cancelButtonTitle: nil
                                               otherButtonTitles:@"确认", nil] ;
        [alert show];
    }
}

@end
