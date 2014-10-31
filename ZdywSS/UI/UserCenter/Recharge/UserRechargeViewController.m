//
//  UserRechargeViewController.m
//  ZdywClient
//
//  Created by ddm on 6/12/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "UserRechargeViewController.h"
#import "UIImage+Scale.h"
#import "ZdywServiceManager.h"
#import "RechargeCellNode.h"
#import "UserRechargeCell.h"
#import "PayTypeRechargeViewController.h"
#import "MoneyInfoNode.h"

@interface UserRechargeViewController ()

@property (nonatomic, strong) NSMutableArray *rechargeList;
@property (nonatomic, assign) BOOL           isShowMoreCharge;

@end

@implementation UserRechargeViewController

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
    self.title = @"充值";
    _uidLable.text = [ZdywUtils getLocalIdDataValue:kZdywDataKeyUserID];
    _phoneLable.text = [ZdywUtils getLocalIdDataValue:kZdywDataKeyUserPhone];
    
    _isShowMoreCharge = NO;
    
    _textFieldBg.layer.borderWidth = 1.0;
    _textFieldBg.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _textFieldBg.layer.masksToBounds = YES;
    _textFieldBg.layer.cornerRadius = 10.0;
    
    _cardPwdTextField.delegate = self;
    
    _rechargeList = [ZdywUtils getLocalIdDataValue:kRechargeListNodeArray];
    
    
    [_chargeListTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_chargeListTable setScrollEnabled:YES];
    
    if (_rechargeList.count <=1) {
        _moreChargeBtn.hidden = YES;
    }
    if (!_rechargeList.count) {
        _onLineRechargeLable.hidden = YES;
    }
    BOOL appVersion=[ZdywUtils getLocalDataBoolen:kZdywDataKeyAppStoreVersion];
    if (appVersion) {
        if (![ZdywUtils getLocalDataBoolen:kShowHiddenFunction]) {
            _onLineRechargeLable.hidden = YES;
            _moreChargeBtn.hidden = YES;
            _chargeListTable.hidden = YES;
        }
    }
    [_moreChargeBtn addTarget:self action:@selector(showMoreRecharge) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGrAction)];
    [tapGr setDelegate:self];
    [self.view addGestureRecognizer:tapGr];
    
    UIImage * loginDefaultImage = [[[UIImage imageNamed:@"login_btn_default"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    UIImage * loginLightImage = [[[UIImage imageNamed:@"login_btn_light"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    

    _rechargeBtn.layer.masksToBounds = YES;
    _rechargeBtn.layer.cornerRadius = 10.0;
    [_rechargeBtn setBackgroundImage:loginDefaultImage forState:UIControlStateNormal];
    [_rechargeBtn setBackgroundImage:loginLightImage forState:UIControlStateHighlighted];
    //[_rechargeBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:25.0/255 green:150.0/255 blue:216.0/255 alpha:1.0]] forState:UIControlStateNormal];
    [_rechargeBtn addTarget:self action:@selector(rechargeAction) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        _onLineRechargeLable.frame = CGRectMake(26, self.view.frame.size.height-110, 111, 21);
        _chargeListTable.frame = CGRectMake(0, self.view.frame.size.height-87, 320, 87);
        _moreChargeBtn.frame = CGRectMake(218, self.view.frame.size.height-30, 82, 30);
    }
    
    [_moreChargeBtn setTitleColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyZdywFontColor] forState:UIControlStateNormal];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - btnAction

- (void)rechargeAction{
    [self addObservers];
    if ([_cardPwdTextField.text length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"请输入充值卡密码"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    [_cardPwdTextField resignFirstResponder];
    NSString *tempStr = [_cardPwdTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *strData = @"account=%@&paytype=%@&src=%@&wmlflag=%@&cardno=%@&cardpwd=%@&subbank=%@";
    strData = [NSString stringWithFormat:strData,
               [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserID],
               @"5",
               @"35",
               @"n",
               tempStr,
               tempStr,
               @""];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setValue:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceRecharge
                                              userInfo:nil
                                              postDict:dic];
    [SVProgressHUD showInView:self.navigationController.view status:@"数据提交中，请稍候..." networkIndicator:NO posY:-1 maskType:SVProgressHUDMaskTypeClear];
}

#pragma mark - tapGrAction

- (void)tapGrAction
{
    
    if (_isShowMoreCharge)
    {
        /***
        RechargeCellNode *copyNode = [[RechargeCellNode alloc] init] ;
        copyNode.priceNumStr= @"100";
        copyNode.desStr = @"100";
        copyNode.goodsID= 1;
        copyNode.nameStr = @"充100";
        copyNode.goodsTypeStr = @"money";
        [self doSomethingWithListNode:copyNode];
         ***/

    }
    [_cardPwdTextField resignFirstResponder];
}

#pragma mark - Observers

- (void)addObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRechargeData:) name:kNotificationRechargeFinish object:nil];
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationRechargeFinish object:nil];
}

#pragma mark - PrivateMethod

- (void)doSomethingWithListNode:(RechargeCellNode *)cellNode{
    PayTypeRechargeViewController *payTypeRechargeView = [[PayTypeRechargeViewController alloc] initWithNibName:NSStringFromClass([PayTypeRechargeViewController class]) bundle:nil];
    payTypeRechargeView.rechargeModel = cellNode;
    
    MoneyInfoNode * seletedMoneyInfo = [[MoneyInfoNode alloc] init];
    seletedMoneyInfo.moneyStr =cellNode.priceNumStr;
    seletedMoneyInfo.moneyDescriptStr = cellNode.desStr;
    seletedMoneyInfo.goodIDStr = [NSString stringWithFormat:@"%d",cellNode.goodsID];
    seletedMoneyInfo.moneyNameStr = cellNode.nameStr;
    payTypeRechargeView.accountInfo = seletedMoneyInfo;
    
    [self.navigationController pushViewController:payTypeRechargeView animated:YES];
}

- (void)showMoreRecharge
{
    [_moreChargeBtn setHidden:YES];
    _isShowMoreCharge = YES;
    
    int offSet = 54;
    if (kZdywClientIsIphone5)
    {
        offSet = 108;
    }
    
    _onLineRechargeLable.frame =CGRectMake(_onLineRechargeLable.frame.origin.x, _onLineRechargeLable.frame.origin.y-(offSet), _onLineRechargeLable.frame.size.width, _onLineRechargeLable.frame.size.height);
    
    _chargeListTable.frame = CGRectMake(_chargeListTable.frame.origin.x, _chargeListTable.frame.origin.y-(offSet), _chargeListTable.frame.size.width, ([_rechargeList count]*54));
    [self.mainScrollView setContentSize:CGSizeMake(320, _chargeListTable.frame.origin.y+([_rechargeList count]*54))];
    [_chargeListTable reloadData];
}

- (void)receiveRechargeData:(NSNotification *)notification
{
    [self removeObservers];
    NSDictionary *dic = [notification userInfo];
    int nRet = [[dic objectForKey:@"result"] intValue];
    NSString *str  = [dic objectForKey:@"reason"];
    
    switch (nRet)
    {
        case 0:
        {
            _cardPwdTextField.text = nil;
            [SVProgressHUD dismissWithSuccess:@"正在为您核实支付情况，请在2分钟后查询余额"];
        }
            break;
        default:
        {
            [SVProgressHUD dismissWithError:str afterDelay:2];
            self.cardPwdTextField.text = @"";
        }
            break;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_isShowMoreCharge == NO) {
        return 1;
    }
    return [_rechargeList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserRechargeCell *userRechargeCell = (UserRechargeCell*)[tableView dequeueReusableCellWithIdentifier:@"userRechargeCell"];
    if (userRechargeCell == nil) {
        userRechargeCell = [[UserRechargeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userRechargeCell"];
    }
    
    RechargeCellNode *cellNode  =nil;
    if([_rechargeList count])
    {
        cellNode = [NSKeyedUnarchiver unarchiveObjectWithData:[_rechargeList objectAtIndex:indexPath.row]];
    }
    else
    {
        cellNode = [[RechargeCellNode alloc]init];
        cellNode.nameStr =@"冲100元到账100";
    }
    if (indexPath.row == 0) {
        UIImageView * separateLineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
        [separateLineImage setBackgroundColor:[UIColor colorWithRed:228.0/255 green:228.0/255 blue:228.0/255 alpha:1.0]];
        [userRechargeCell addSubview:separateLineImage];
    }
    userRechargeCell.rechargeNameLable.text = cellNode.nameStr;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        UIView *menuCellBackView = [[UIView alloc] initWithFrame:userRechargeCell.frame];
        menuCellBackView.backgroundColor = [UIColor lightGrayColor];
        [userRechargeCell setSelectedBackgroundView:menuCellBackView];
    }
    return userRechargeCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_rechargeList&&[_rechargeList count]>0) {
        RechargeCellNode *cellNode = [NSKeyedUnarchiver unarchiveObjectWithData:[_rechargeList objectAtIndex:indexPath.row]];
        RechargeCellNode *copyNode = [[RechargeCellNode alloc] init] ;
        copyNode.priceNumStr= cellNode.priceNumStr;
        copyNode.desStr = cellNode.desStr;
        copyNode.goodsID= cellNode.goodsID;
        copyNode.nameStr = cellNode.nameStr;
        copyNode.goodsTypeStr = cellNode.goodsTypeStr;
        [self doSomethingWithListNode:copyNode];
    }else{
        RechargeCellNode *copyNode = [[RechargeCellNode alloc] init] ;
        copyNode.priceNumStr= @"100";
        copyNode.desStr = @"100";
        copyNode.goodsID= 1;
        copyNode.nameStr = @"充100";
        copyNode.goodsTypeStr = @"money";
        [self doSomethingWithListNode:copyNode];
    }
   
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (_cardPwdTextField == textField) {
        [_cardPwdTextField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if ((range.location  ==4||range.location ==9||range.location  ==14||range.location ==19) && string.length >0)
    {
        textField.text = [NSString stringWithFormat:@"%@ ",textField.text];
    }
    return (range.location<24);
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    CGPoint point = [touch locationInView:self.view];
    if (CGRectContainsPoint(_chargeListTable.frame, point)||[NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    if (_isShowMoreCharge &&point.y <285) {
        [_cardPwdTextField resignFirstResponder];
        return NO;
    }
    return YES;
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSLog(@"%f---%f",targetContentOffset->x,targetContentOffset->y);
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}

@end
