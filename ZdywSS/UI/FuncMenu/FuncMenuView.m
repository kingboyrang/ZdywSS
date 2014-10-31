//
//  FuncMenuView.m
//  ZdywClient
//
//  Created by ddm on 6/9/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "FuncMenuView.h"
#import "FuncMenuCell.h"
#import "UIImage+Scale.h"

@interface FuncMenuView ()

@property (nonatomic, strong) UITableView *menuTableView;
@property (nonatomic, strong) UILabel     *uidLable;
@property (nonatomic, strong) UILabel     *phoneLabel;
@property (nonatomic, strong) UIImageView *tipImageView;

@end

@implementation FuncMenuView

#pragma mark - liftCycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

#pragma mark - PrivateMethod

- (void)commonInit{
    _dataModelArray = [NSMutableArray arrayWithCapacity:0];
    [self bulidModel];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    UIImage *backgroundImage = [[[UIImage imageNamed:@"menu_bg"] stretchableImageWithLeftCapWidth:7  topCapHeight:25] scaleToSize:CGSizeMake(self.frame.size.width*2, self.frame.size.height*2)];
    [backgroundImageView setImage:backgroundImage];
    [self addSubview:backgroundImageView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receviceNewMsg) name:kNotificationReceiveNewPushMsg object:nil];
    
    _menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 8, self.frame.size.width, self.frame.size.height)];
    [_menuTableView setDelegate:self];
    [_menuTableView setDataSource:self];
    [_menuTableView setBackgroundColor:[UIColor clearColor]];
    [_menuTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_menuTableView setScrollEnabled:NO];
    [self addSubview:_menuTableView];
}

- (void)bulidModel{
    FuncMenuModel * funcMenuModel = [[FuncMenuModel alloc] init];
    funcMenuModel.funcName = @"消息通知";
    funcMenuModel.funcIcon = [UIImage imageNamed:@"menu_logo_message"];
    funcMenuModel.funcMenuType = FuncMenuType_Message;
    [_dataModelArray addObject:funcMenuModel];
    
    funcMenuModel = [[FuncMenuModel alloc] init];
    funcMenuModel.funcName = @"余额";
    funcMenuModel.funcIcon = [UIImage imageNamed:@"menu_logo_balance"];
    funcMenuModel.funcMenuType = FuncMenuType_Balance;
    [_dataModelArray addObject:funcMenuModel];
    
    funcMenuModel = [[FuncMenuModel alloc] init];
    funcMenuModel.funcName = @"充值";
    funcMenuModel.funcIcon = [UIImage imageNamed:@"menu_logo_recharge"];
    funcMenuModel.funcMenuType = FuncMenuType_Recharge;
    [_dataModelArray addObject:funcMenuModel];
    
    funcMenuModel = [[FuncMenuModel alloc] init];
    funcMenuModel.funcName = @"账单";
    funcMenuModel.funcIcon = [UIImage imageNamed:@"menu_logo_account"];
    funcMenuModel.funcMenuType = FuncMenuType_Account;
    [_dataModelArray addObject:funcMenuModel];
    
    funcMenuModel = [[FuncMenuModel alloc] init];
    funcMenuModel.funcName = @"设置";
    funcMenuModel.funcIcon = [UIImage imageNamed:@"menu_logo_setup"];
    funcMenuModel.funcMenuType = FuncMenuType_Setup;
    [_dataModelArray addObject:funcMenuModel];
    
    funcMenuModel = [[FuncMenuModel alloc] init];
    funcMenuModel.funcName = @"帮助中心";
    funcMenuModel.funcIcon = [UIImage imageNamed:@"menu_logo_help"];
    funcMenuModel.funcMenuType = FuncMenuType_Help;
    [_dataModelArray addObject:funcMenuModel];
    
    funcMenuModel = [[FuncMenuModel alloc] init];
    funcMenuModel.funcName = @"意见反馈";
    funcMenuModel.funcIcon = [UIImage imageNamed:@"menu_logo_feedback"];
    funcMenuModel.funcMenuType = FuncMenuType_Feedback;
    [_dataModelArray addObject:funcMenuModel];
}

- (void)receviceNewMsg{
    [_menuTableView reloadData];
}

#pragma mark - PublicMethod

- (void)updateMainUI{
    _phoneLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:kZdywDataKeyUserPhone];
    _uidLable.text = [[NSUserDefaults standardUserDefaults] objectForKey:kZdywDataKeyUserID];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 75)];
    UIImageView *appIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 24, 32, 32)];
    [appIcon setImage:[UIImage imageNamed:@"menu_logo"]];
    [headerView addSubview:appIcon];
    
    UILabel *memberLable = [[UILabel alloc] initWithFrame:CGRectMake(48, 24, 40, 16)];
    [memberLable setText:@"会员号:"];
    [memberLable setFont:[UIFont systemFontOfSize:12.0]];
    [memberLable setTextColor:[UIColor colorWithRed:152.0/255 green:152.0/255 blue:152.0/255 alpha:1.0]];
    memberLable.backgroundColor = [UIColor clearColor];
    [headerView addSubview:memberLable];
    
    _uidLable = [[UILabel alloc] initWithFrame:CGRectMake(88, 24, tableView.frame.size.width-60, 16)];
    _uidLable.text = [[NSUserDefaults standardUserDefaults] objectForKey:kZdywDataKeyUserID];
    [_uidLable setTextColor:[UIColor whiteColor]];
    [_uidLable setFont:[UIFont systemFontOfSize:12.0]];
    _uidLable.backgroundColor = [UIColor clearColor];
    [headerView addSubview:_uidLable];
    
    UILabel *phLable = [[UILabel alloc] initWithFrame:CGRectMake(48, 40, 40, 16)];
    [phLable setText:@"手机号:"];
    [phLable setFont:[UIFont systemFontOfSize:12.0]];
    [phLable setTextColor:[UIColor colorWithRed:152.0/255 green:152.0/255 blue:152.0/255 alpha:1.0]];
    phLable.backgroundColor = [UIColor clearColor];
    [headerView addSubview:phLable];
    
    _phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(88, 40, tableView.frame.size.width-60, 16)];
    _phoneLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:kZdywDataKeyUserPhone];
    [_phoneLabel setFont:[UIFont systemFontOfSize:12.0]];
    [_phoneLabel setTextColor:[UIColor whiteColor]];
    _phoneLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:_phoneLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 74.5, _menuTableView.frame.size.width, 0.5)];
    [imageView setBackgroundColor:[UIColor colorWithRed:76.0/255 green:76.0/255 blue:76.0/255 alpha:1.0]];
    [headerView addSubview:imageView];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 75;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataModelArray count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FuncMenuCell *funcMenuCell = (FuncMenuCell*)[tableView dequeueReusableCellWithIdentifier:@"funcMenuCell"];
    if (funcMenuCell == nil) {
        funcMenuCell = [[FuncMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"funcMenuCell"];
    }
    FuncMenuModel *funcMenuModel = [_dataModelArray objectAtIndex:indexPath.row];
    funcMenuCell.funcIconImageView.image = funcMenuModel.funcIcon;
    funcMenuCell.funcNameLable.text = funcMenuModel.funcName;
    if (indexPath.row == _dataModelArray.count -1) {
        funcMenuCell.separatorLine.hidden = YES;
    }
    if (indexPath.row == 0) {
        if ([ZdywAppDelegate appDelegate].isNewMsg == YES) {
            _tipImageView = [[UIImageView alloc] initWithFrame:CGRectMake(110, 8, 6, 6)];
            _tipImageView.image = [UIImage imageNamed:@"func_msg_icon.png"];
        }
        funcMenuCell.funcNameLable.textColor = [UIColor colorWithRed:255.0/255.0 green:249.0/255.0 blue:160.0/255.0 alpha:1.0];
        [funcMenuCell addSubview:_tipImageView];
    }
    UIView *menuCellBackView = [[UIView alloc] initWithFrame:funcMenuCell.frame];
    menuCellBackView.backgroundColor = [UIColor colorWithRed:49.0/255 green:49.0/255 blue:49.0/255 alpha:1.0];
    [funcMenuCell setSelectedBackgroundView:menuCellBackView];
    return funcMenuCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 38.0;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([ZdywAppDelegate appDelegate].isNewMsg == YES) {
        _tipImageView.hidden = YES;
        [_tipImageView removeFromSuperview];
        [ZdywAppDelegate appDelegate].isNewMsg = NO;
    }
    FuncMenuModel *funcMenuModel = [_dataModelArray objectAtIndex:indexPath.row];
    if (_delagate && [_delagate respondsToSelector:@selector(showFuncMenuDetailView:)]) {
        [_delagate showFuncMenuDetailView:funcMenuModel];
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
