//
//  DialTypeViewController.m
//  ZdywClient
//
//  Created by ddm on 6/21/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "DialTypeViewController.h"
#import "MoreSectionNode.h"
#import "MoreRowNode.h"

#define  kDialTypeTableViewCellHeight   70

@interface DialTypeViewController ()

@property (nonatomic, strong) NSMutableArray *dialModeTypeArray;

@end

@implementation DialTypeViewController

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
    self.title = @"拨打方式设置";
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self buildDialModeTypeDataModel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PrivateMethod

- (void)buildDialModeTypeDataModel{
    _dialModeTypeArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    //first section
    MoreSectionNode *sectionNode = [[MoreSectionNode alloc] init];
    sectionNode.title = @"";
    
    NSString *directFee = [ZdywUtils getLocalStringDataValue:kDialModelDirectFee];
    if (0 == [directFee length])
    {
        NSString *directFeeMsg=[ZdywCommonFun getAppConfigureInfoWithKey:kDialModelDirectFee];
        if ([directFeeMsg length]>0) {
            directFee = directFeeMsg;
        }else{
           directFee = @"0.1";
        }
        
    }
    NSString *directRate = [ZdywUtils getLocalStringDataValue:kDialModelDirectRate];
    if (0 == [directRate length])
    {
        directRate = @"4K";
    }
    NSString *callBackFee = [ZdywUtils getLocalStringDataValue:kDialModelCallBackFee];
    if (0 == [callBackFee length])
    {
        NSString *callBackFeeMsg=[ZdywCommonFun getAppConfigureInfoWithKey:kDialModelCallBackFee];
        if ([callBackFeeMsg length]>0) {
            callBackFee = callBackFeeMsg;
        }else{
            callBackFee = @"0.15";
        }
    }
    NSString *callBackRate = [ZdywUtils getLocalStringDataValue:kDialModelCallBackRate];
    if (0 == [callBackRate length])
    {
        callBackRate = @"1K";
    }
    MoreRowNode *rowNode = [[MoreRowNode alloc] init];
    sectionNode.title = @"";
    //默认回拨
    rowNode = [[MoreRowNode alloc] init];
    rowNode.imageName = @"";
    rowNode.mainTitle = @"默认回拨";
    rowNode.subTitle = @"回拨适用于绝大多数网络环境，且消耗极少的流量。回拨资费0.39元/分钟，每次通话仅需消耗流量约1-3KB";
    rowNode.dialModeType=ZdywDialModeCallBack;
    [sectionNode.child addObject:rowNode];
    [_dialModeTypeArray addObject:sectionNode];
    
    //second section
//    sectionNode = [[MoreSectionNode alloc] init];
//    sectionNode.title = @"";
//    
//    //默认直拨
//    rowNode = [[MoreRowNode alloc] init];
//    rowNode.imageName = @"";
//    rowNode.mainTitle = @"默认直拨";
//    rowNode.subTitle =  @"直拨对网络要求较高，建议在WiFi或3G情况下选择。直拨资费0.38元/分钟，每秒消耗约4KB流量。";
//    [sectionNode.child addObject:rowNode];
//    [_dialModeTypeArray addObject:sectionNode];
    
    //third section
    sectionNode = [[MoreSectionNode alloc] init];
    sectionNode.title = @"";
    //默认智能
    rowNode = [[MoreRowNode alloc] init];
    rowNode.imageName = @"";
    rowNode.mainTitle = @"默认智能";
    rowNode.subTitle = @"智能模式下,系统将自动根据您当前的网络环境为您匹配最佳的拨打方式。";
    rowNode.dialModeType=ZdywDialModeSmart;
    [sectionNode.child addObject:rowNode];
    [_dialModeTypeArray addObject:sectionNode];
    
    
    //fourth section
//    sectionNode = [[MoreSectionNode alloc] init];
//    sectionNode.title = @"";
//    
//    //手动拨打
//    rowNode = [[MoreRowNode alloc] init];
//    rowNode.imageName = @"";
//    rowNode.mainTitle = @"默认手动";
//    rowNode.subTitle = @"开启后，在您每次呼叫时，系统将让您自主选择拨打方式，适用于对说电话了解深入的用户";
//    [sectionNode.child addObject:rowNode];
//    [_dialModeTypeArray addObject:sectionNode];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_dialModeTypeArray count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[_dialModeTypeArray objectAtIndex:section] child] count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil] ;
    if(indexPath.section == 0)
    {
        UILabel *subLbl = [[UILabel alloc] initWithFrame:CGRectMake(87, 10, 100, 20)];
        [subLbl setBackgroundColor:[UIColor clearColor]];
        //subLbl.text = @"(推荐)";
        //subLbl.textColor = [UIColor colorWithRed:254.0/255 green:116.0/255 blue:49.0/255 alpha:1.0];
        [cell addSubview:subLbl];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    MoreRowNode *node = [[[_dialModeTypeArray objectAtIndex:indexPath.section] child] objectAtIndex:indexPath.row];
    int dialModeType = [[ZdywUtils getLocalIdDataValue:kDialModeType] intValue];
    NSString *imgName = @"more_dialmode_noselect_cell.png";
    if (node.dialModeType==dialModeType) {
        imgName = @"more_dialmode_select_cell.png";
    }else{
        imgName = @"more_dialmode_noselect_cell.png";
    }
    /***
    if (indexPath.section == dialModeType)
    {
        imgName = @"more_dialmode_select_cell.png";
    }
    else
    {
        imgName = @"more_dialmode_noselect_cell.png";
    }
     ***/
    UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
    accessoryView.frame = CGRectMake(0, 0, 28, 28);
    accessoryView.backgroundColor = [UIColor clearColor];
    cell.accessoryView = accessoryView;
    accessoryView = nil;
    cell.textLabel.text = node.mainTitle;
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.detailTextLabel.text = node.subTitle;
    return cell;
}

- (void) tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [atableView deselectRowAtIndexPath:indexPath animated:YES];
    MoreRowNode *node = [[[_dialModeTypeArray objectAtIndex:indexPath.section] child] objectAtIndex:indexPath.row];
    int dialModeType = [[ZdywUtils getLocalIdDataValue:kDialModeType] intValue];
    if(dialModeType != node.dialModeType)
    {
        //保存新的拨打方式
        UITableViewCell *newCell = [_tableView cellForRowAtIndexPath:indexPath];
        UIImageView *view = (UIImageView*)newCell.accessoryView;
        [view setImage:[UIImage imageNamed:@"more_dialmode_select_cell.png"]];
        [ZdywUtils setLocalIdDataValue:[NSNumber numberWithInt:node.dialModeType] key:kDialModeType];
        //取消旧的选中项
        NSInteger lastSection=[self getSelectedSectionWithModeType:dialModeType];
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:0 inSection:lastSection];
        UITableViewCell *oldCell = [_tableView cellForRowAtIndexPath:lastIndexPath];
        UIImageView *view2 = (UIImageView*)oldCell.accessoryView;
        [view2 setImage:[UIImage imageNamed:@"more_dialmode_noselect_cell.png"]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IOS7)
    {
        return kDialTypeTableViewCellHeight;
    }
    else
    {
        return kDialTypeTableViewCellHeight+25;
    }
    
}
- (NSInteger)getSelectedSectionWithModeType:(NSInteger)dialModeType{
    NSInteger total=0;
    for (MoreSectionNode *item in _dialModeTypeArray) {
        MoreRowNode *node=[[item child] objectAtIndex:0];
        if (node.dialModeType==dialModeType) {
            break;
        }
        total++;
    }
    return total;
}
@end
