//
//  HelpCenterViewController.m
//  ZdywClient
//
//  Created by ddm on 6/20/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "HelpCenterViewController.h"
#import "HelpCenterMenuCell.h"
#import "ProblemAnswerViewController.h"
#import "RechargeInstructionViewController.h"
#import "TariffViewController.h"
#import "CallTypeViewController.h"
#import "CallInfoNode.h"
#import "CallWrapper.h"
#import "ContactType.h"
#import "UIImage+Scale.h"

@interface HelpCenterViewController ()

@property (nonatomic, strong) NSArray    *dataArray;

@end

@implementation HelpCenterViewController

#pragma mark - liftCycle

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
    self.title = @"帮助中心";
    [self.view setBackgroundColor:[UIColor colorWithRed:247.0/255 green:247.0/255 blue:247.0/255 alpha:1.0]];
    _dataArray = [[NSArray alloc] initWithObjects:@"常见问题解答",@"直拨/回拨介绍",@"充值说明",@"资费说明",nil];
    [_helpMenuTable setDataSource:self];
    [_helpMenuTable setDelegate:self];
    [_helpMenuTable setScrollEnabled:NO];
    [_helpMenuTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _servicePhoneLable.text = [ZdywCommonFun getCustomerPhone];
    
    [_callBtn.layer setMasksToBounds:YES];
    [_callBtn.layer setCornerRadius:10.0];
    [_callBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:86.0/255 green:193.0/255 blue:3.0/255 alpha:1.0]] forState:UIControlStateNormal];
    [_callBtn addTarget:self action:@selector(callServicePhone) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

#pragma mark - PrivateMethod

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HelpCenterMenuCell  *helpCenterCell = (HelpCenterMenuCell*)[tableView dequeueReusableCellWithIdentifier:@"helpCenterMenuCell"];
    if (helpCenterCell == nil) {
        helpCenterCell = [[HelpCenterMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"helpCenterMenuCell"];
    }
    helpCenterCell.helpNameStr = [_dataArray objectAtIndex:indexPath.row];
    [helpCenterCell setBackgroundColor:[UIColor whiteColor]];
    if (indexPath.row == [_dataArray count]-1) {
        helpCenterCell.separateLineImage.hidden = YES;
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        UIView *menuCellBackView = [[UIView alloc] initWithFrame:helpCenterCell.frame];
        menuCellBackView.backgroundColor = [UIColor lightGrayColor];
        [helpCenterCell setSelectedBackgroundView:menuCellBackView];
    }
    return helpCenterCell;
}

- (void)callServicePhone{
    NSString *strphone = [ZdywCommonFun getCustomerPhone];
    NSString *strURL = [NSString stringWithFormat:@"tel://%@", strphone];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:strURL]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strURL]];
    }
//    NSString *strTitile = [NSString stringWithFormat:@"客服电话：%@\n服务时间：8:00-23:00", [ZdywCommonFun getCustomerPhone]];
//    UIActionSheet *uas = [[UIActionSheet alloc] initWithTitle:strTitile
//                                                     delegate:self
//                                            cancelButtonTitle:nil
//                                       destructiveButtonTitle:nil
//                                            otherButtonTitles:nil];
//    uas.tag = 101;
//    
//    uas.actionSheetStyle = UIActionSheetStyleAutomatic;
//    [uas addButtonWithTitle:[NSString stringWithFormat:@"通过顶讯免费拨打"]];
//    [uas addButtonWithTitle:@"通过系统手机拨打"];
//    [uas addButtonWithTitle:@"取消"];
//    uas.cancelButtonIndex =  2;
//    [uas showInView:self.view];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

#pragma mark - UIActionSheetDelegate

- (void) actionSheet:(UIActionSheet *) actionSheet clickedButtonAtIndex:(NSInteger) buttonIndex
{
    
    if (actionSheet.tag == 101)
    {
        if (buttonIndex == 0)
        {
            [self callCustomerServiceType:0];
        }
        else if(buttonIndex == 1)
        {
            [self callCustomerServiceType:1];
        }
        else if(buttonIndex == 2)
        {
            return;
        }
    }
}

- (void)callCustomerServiceType:(int)type{
    switch (type) {
        case 0:{
            CallInfoNode *infoNode = [[CallInfoNode alloc] init];
            infoNode.calleePhone = [ZdywCommonFun getCustomerPhone];
            infoNode.calleeName = @"客服电话";
            infoNode.calleeRecordID = kInValidContactID;
            infoNode.calltype = ZdywDirectCallType;
            [[CallWrapper shareCallWrapper] initiatingCall:infoNode];
            break;
        }
        case 1:{
            NSString *strphone = [ZdywCommonFun getCustomerPhone];
            NSString *strURL = [NSString stringWithFormat:@"tel://%@", strphone];
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:strURL]])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strURL]];
            }
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:{
            ProblemAnswerViewController *problemView = [[ProblemAnswerViewController alloc] initWithNibName:NSStringFromClass([ProblemAnswerViewController class]) bundle:nil];
            [self.navigationController pushViewController:problemView animated:YES];
            break;
        }
        case 1:{
            CallTypeViewController *callTypeView = [[CallTypeViewController alloc] initWithNibName:NSStringFromClass([CallTypeViewController class]) bundle:nil];
            [self.navigationController pushViewController:callTypeView animated:YES];
            break;
        }
        case 2:{
            RechargeInstructionViewController *rechargeView = [[RechargeInstructionViewController alloc] initWithNibName:NSStringFromClass([RechargeInstructionViewController class]) bundle:nil];
            [self.navigationController pushViewController:rechargeView animated:YES];
            break;
        }
        case 3:{
            TariffViewController *tariffView = [[TariffViewController alloc] initWithNibName:NSStringFromClass([TariffViewController class]) bundle:nil];
            [self.navigationController pushViewController:tariffView animated:YES];
            break;
        }
        default:
            break;
    }
}

@end
