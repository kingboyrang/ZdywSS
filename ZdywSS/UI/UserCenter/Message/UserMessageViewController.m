//
//  UserMessageViewController.m
//  ZdywClient
//
//  Created by ddm on 6/12/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "UserMessageViewController.h"
#import "PushModel.h"
#import "UserMessageDetailViewController.h"

@interface UserMessageViewController ()

@property (nonatomic, strong) NSMutableArray *userMsgArray;
@property (nonatomic, assign) NSInteger      deleIndex;
@property (nonatomic, assign) BOOL           isShowMenuView;
@property (nonatomic, strong) UIView         *tipView;

@end

@implementation UserMessageViewController

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
    self.title = @"消息通知";
    
    [self.view setBackgroundColor:[UIColor colorWithRed:247.0/255 green:247.0/255 blue:247.0/255 alpha:1.0]];
    _userMsgArray = [[NSMutableArray alloc] initWithCapacity:0];
    _isShowMenuView = NO;
    
    NSArray *msgArray = [ZdywUtils getLocalIdDataValue:kPushMessageArray];
    for (NSDictionary *dic in msgArray) {
        PushModel *pushModel = [[PushModel alloc] initWithDic:dic];
        [_userMsgArray addObject:pushModel];
    }
    
    _msgListTableView.backgroundColor = [UIColor clearColor];
    [_msgListTableView setDelegate:self];
    [_msgListTableView setDataSource:self];
    [_msgListTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    _tipView = [[UIView alloc] initWithFrame:self.view.frame];
    [_tipView setBackgroundColor:[UIColor clearColor]];
    UILabel *tipLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 280, 30)];
    tipLable.textAlignment = NSTextAlignmentCenter;
    tipLable.text = @"暂无消息通知。";
    tipLable.backgroundColor = [UIColor clearColor];
    tipLable.font = [UIFont systemFontOfSize:16.0];
    tipLable.textColor = [UIColor lightGrayColor];
    [self.view addSubview:_tipView];
    [_tipView addSubview:tipLable];
    
    if ([_userMsgArray count]==0) {
        [_tipView setHidden:NO];
    }else {
        [_tipView setHidden:YES];
    }
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenuView)];
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:tapGr];
    
    UILongPressGestureRecognizer *longPressGr = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressDeleAction:)];
    [_msgListTableView addGestureRecognizer:longPressGr];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_msgListTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PrivateMethod

- (void)hideMenuView{
    if (_isShowMenuView == YES) {
        [_msgListTableView reloadData];
        _isShowMenuView = NO;
    }
}

- (void)longPressDeleAction:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint p = [recognizer locationInView:self.msgListTableView];
        NSIndexPath *indexPath = [self.msgListTableView indexPathForRowAtPoint:p];
        NSLog(@"indexPath.row......%d",indexPath.row);
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)deleteMsg{
    NSMutableArray *msgArray = [NSMutableArray arrayWithCapacity:2];
    
    NSArray *msgListArray = [ZdywUtils getLocalIdDataValue:kPushMessageArray];
    if ([msgListArray count]) {
        [msgArray addObjectsFromArray:msgListArray];
    }
    if ([msgArray objectAtIndex:_deleIndex]) {
        [msgArray removeObjectAtIndex:_deleIndex];
    }
    [ZdywUtils setLocalIdDataValue:msgArray key:kPushMessageArray];
    [_userMsgArray removeAllObjects];
    if ([msgArray count]) {
        for (NSDictionary *dic in msgArray) {
            PushModel *pushModel = [[PushModel alloc] initWithDic:dic];
            [_userMsgArray addObject:pushModel];
        }
    }
    if ([_userMsgArray count]==0) {
        [_tipView setHidden:NO];
    }else {
        [_tipView setHidden:YES];
    }
    [_msgListTableView reloadData];
}

- (void)cancelDele{
    [_msgListTableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_userMsgArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserMessageCell *userMsgCell = (UserMessageCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"[userMsgCell msgCellHeight] ... %d",[userMsgCell msgCellHeight]);
    return [userMsgCell msgCellHeight];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserMessageCell *userMessageCell = (UserMessageCell*)[tableView dequeueReusableCellWithIdentifier:@"userMessageCell"];
    if (userMessageCell == nil) {
        userMessageCell = [[UserMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userMessageCell"];
    }
    [userMessageCell setDelegate:self];
    [userMessageCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    PushModel *pushModel = [_userMsgArray objectAtIndex:_userMsgArray.count - indexPath.row - 1];
    userMessageCell.msgStr = pushModel.alert;
    userMessageCell.index = _userMsgArray.count - indexPath.row - 1;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        UIView *menuCellBackView = [[UIView alloc] initWithFrame:userMessageCell.frame];
        menuCellBackView.backgroundColor = [UIColor lightGrayColor];
        [userMessageCell setSelectedBackgroundView:menuCellBackView];
    }
    return userMessageCell;
}

#pragma mark - 

- (void)showMsgDetailView:(NSInteger)index{
    UserMessageDetailViewController *userMessageView = [[UserMessageDetailViewController alloc] initWithNibName:NSStringFromClass([UserMessageDetailViewController class]) bundle:nil];
    PushModel *pushModel = [_userMsgArray objectAtIndex:index];
    userMessageView.userMsgStr = pushModel.alert;
    [self.navigationController pushViewController:userMessageView animated:YES];
}

- (void)deleMsgIndex:(NSInteger)index{
    NSLog(@"index......%d",index);
    _deleIndex = index;
    _isShowMenuView = YES;
}


@end
