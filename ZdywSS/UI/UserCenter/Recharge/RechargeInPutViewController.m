//
//  RechargeInPutViewController.m
//  WldhClient
//
//  Created by dyn on 13-8-8.
//  Copyright (c) 2013年 guoling. All rights reserved.
//

#import "RechargeInPutViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Scale.h"

@interface RechargeInPutViewController ()

@property (nonatomic, assign) NSInteger         iIntRechargeMoneyCount;//已经充值金额总数
@property (nonatomic, assign) NSInteger         iIntRechargeMoney;//充值套餐金额

@end

@implementation RechargeInPutViewController

#pragma mark - lifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
          _moneyInfoObject = [[MoneyInfoNode alloc] init];
    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _cardNoBg.layer.cornerRadius = 10.0;
    _cardNoBg.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _cardNoBg.layer.borderWidth = 1.0;
    _cardNoBg.layer.masksToBounds = YES;
    
    _cardPwdBg.layer.cornerRadius = 10.0;
    _cardPwdBg.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _cardPwdBg.layer.borderWidth = 1.0;
    _cardPwdBg.layer.masksToBounds = YES;
    
    UIImage * loginDefaultImage = [[[UIImage imageNamed:@"login_btn_default"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    UIImage * loginLightImage = [[[UIImage imageNamed:@"login_btn_light"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    
    _rechargeBtn.layer.masksToBounds = YES;
    _rechargeBtn.layer.cornerRadius = 10.0;
    [_rechargeBtn setBackgroundImage:loginDefaultImage forState:UIControlStateNormal];
    [_rechargeBtn setBackgroundImage:loginLightImage forState:UIControlStateHighlighted];

    //[_rechargeBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:25.0/255 green:151.0/255 blue:216.0/255 alpha:1.0]] forState:UIControlStateNormal];
    [_rechargeBtn addTarget:self action:@selector(rechargeAction) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dissMissKeyboard)];
    tapGr.delegate = self;
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:tapGr];
    
    UISwipeGestureRecognizer *swipGrUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dissMissKeyboard)];
    [swipGrUp setDirection:UISwipeGestureRecognizerDirectionUp];
    swipGrUp.delegate = self;
    [self.view addGestureRecognizer:swipGrUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dissMissKeyboard)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    swipeDown.delegate = self;
    [self.view addGestureRecognizer:swipeDown];
    
    [_cardNoTextField setDelegate:self];
    [_cardPwdTextField setDelegate:self];
    [_cardNoTextField addTarget:self
                           action:@selector(textFieldDidChange:)
                 forControlEvents:UIControlEventEditingChanged];
    [_cardPwdTextField addTarget:self
                         action:@selector(textFieldDidChange:)
               forControlEvents:UIControlEventEditingChanged];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    switch ([_moneyInfoObject.payKindStr intValue]) {
        case 701:{
            self.title = @"移动卡充值";
        }
            break;
        case 702:{
            self.title = @"联通卡充值";
        }
            break;
        case 703:{
            self.title = @"电信卡充值";
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self removeObservers];
}

#pragma mark - Observers

- (void)addObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRechargeData:) name:kNotificationRechargeFinish object:nil];
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationRechargeFinish object:nil];
}

#pragma mark - PublicMethod

- (void)dissMissKeyboard{
    [_cardNoTextField resignFirstResponder];
    [_cardPwdTextField resignFirstResponder];
}

- (void)receiveRechargeData:(NSNotification *)notification{
    NSDictionary *dic = [notification userInfo];
    int nRet = [[dic objectForKey:@"result"] intValue];
    NSString *str  = [dic objectForKey:@"reason"];
    [self removeObservers];
    switch (nRet)
    {
        case 0:
        {
            [SVProgressHUD dismiss];
            _cardNoTextField.text = @"";
            _cardPwdTextField.text = @"";
            [ZdywCommonFun ShowMessageBox:-1
                                titleName:@"提示"
                              contentText:@"正在为您核实支付情况，请在2分钟后查询余额"
                            cancelBtnName:@"继续充值"
                                 delegate:nil];
        }
            break;
        default:
        {
            [SVProgressHUD dismissWithError: str afterDelay:2];
        }
            break;
    }
}

-(void)setContentInfo:(MoneyInfoNode*)info{
    NSString *oldGoodId = [ZdywUtils getLocalStringDataValue:kNowSelectGoodId];
    if(!oldGoodId && [oldGoodId isEqualToString:info.goodIDStr ]){
        _iIntRechargeMoneyCount = 0 ;
    } else {
        _iIntRechargeMoneyCount = [[ZdywUtils getLocalStringDataValue:kNowPayMoneyString] intValue];
    }
    NSString *oldPayType = [ZdywUtils getLocalStringDataValue:kNowSelectRechargeType];
    if(! oldPayType &&[ oldPayType isEqualToString: info.payCodeStr]){
        _cardNoTextField.text = @"";
        [_cardNoTextField resignFirstResponder];
        _cardPwdTextField.text = @"";
        [_cardPwdTextField resignFirstResponder];
        _iIntRechargeMoneyCount = 0 ;
    }
    _moneyInfoObject.payCodeStr = info.payCodeStr;
    _moneyInfoObject.payKindStr = info.payKindStr;
    _moneyInfoObject.paytypeStr = info.paytypeStr;
    _moneyInfoObject.moneyStr = info.moneyStr;
    _moneyInfoObject.goodIDStr = info.goodIDStr;
    //把新的数据复制给用户选择的充值卡方式页
    [ZdywUtils setLocalDataString:info.goodIDStr key:kNowSelectGoodId];
    [ZdywUtils setLocalDataString:info.payCodeStr key:kNowSelectRechargeType];
}

#pragma mark - PrivateMethod

- (void)rechargeAction{
    [self RequestNetStart];
}

//调用网络请求充值
- (void) RequestNetStart
{
    if ([_cardNoTextField isFirstResponder])
    {
        [_cardNoTextField resignFirstResponder];
    }
    if ([_cardPwdTextField isFirstResponder])
    {
        [_cardPwdTextField resignFirstResponder];
    }
    [self addObservers];
    NSString *strCardNo = [NSString stringWithFormat:@"%@",[[_cardNoTextField text] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    
    NSString *strCardPwd = [NSString stringWithFormat:@"%@",[[_cardPwdTextField text] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    
    if(strCardNo.length == 0 || [strCardNo isKindOfClass:[NSNull class]])
    {
        [ZdywCommonFun ShowMessageBox:1
                             titleName:nil
                           contentText:@"请输入充值卡号"
                         cancelBtnName:@"我知道了"
                              delegate:nil];
        return;
    }
    
    if(strCardPwd.length == 0|| [strCardPwd isKindOfClass:[NSNull class]]){
        
        [ZdywCommonFun ShowMessageBox:1
                             titleName:nil
                           contentText:@"请输入充值卡密码"
                         cancelBtnName:@"我知道了"
                              delegate:nil];
        return;
    }
    
    NSString *strData = @"account=%@&paytype=%@&goodsid=%@&src=%@&wmlflag=%@&cardno=%@&cardpwd=%@&subbank=%@";
    
    strData = [NSString stringWithFormat:strData,
               [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserID],
               self.moneyInfoObject.paytypeStr,
               self.moneyInfoObject.goodIDStr,
               @"56",
               @"n",
               strCardNo,
               strCardPwd,
               @""];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setValue:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceRecharge
                                              userInfo:nil
                                              postDict:dic];
    [SVProgressHUD showInView:self.navigationController.view status:@"数据提交中，请稍候..." networkIndicator:NO posY:-1 maskType:SVProgressHUDMaskTypeClear];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField==self.cardNoTextField)
    {
        [self.cardPwdTextField becomeFirstResponder];
    }
    else if(textField==self.cardPwdTextField)
    {
        [self dissMissKeyboard];
    }
    return YES;
}

- (void)textFieldDidChange:(UITextField *)TextField{
    if(TextField == self.cardNoTextField){
        NSString *strCardNo = [self.cardNoTextField text];
        int lengthSpace = [strCardNo length];
        
        strCardNo = [strCardNo stringByReplacingOccurrencesOfString:@" "
                                                         withString:@""];
        int length = [strCardNo length];
        NSMutableString *strTemp= [NSMutableString stringWithCapacity:0];
        int i = length/4;
        if( i==0 ){
            [strTemp setString:[strTemp stringByAppendingFormat:@"%@",strCardNo]];
        }
        int j=0;
        while ( j<i) {
            int index = j*4;
            NSRange range = NSMakeRange(index, 4);
            [strTemp setString:[strTemp stringByAppendingFormat:@"%@ ",[strCardNo substringWithRange:range]]];
            j++;
            if( j>=i){
                if( [strTemp length] >= lengthSpace+1)
                    [strTemp setString:[strTemp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                break;
            }
        }
        int intTemp= length - (4*i);
        if(intTemp > 0 && i != 0 ){
            [strTemp setString:[strTemp stringByAppendingFormat:@"%@",[strCardNo substringFromIndex:4*i]]];
        }
        self.cardNoTextField.text = strTemp;
    }
    if(TextField == self.cardPwdTextField)
    {
        
        NSString *strCardPwd = [self.cardPwdTextField text];
        int lengthSpace = [strCardPwd length];
        
        strCardPwd = [strCardPwd stringByReplacingOccurrencesOfString:@" "
                                                           withString:@""];
        int length = [strCardPwd length];
        NSMutableString *strTemp= [NSMutableString stringWithCapacity:0];
        int i = length/4;
        if( i==0 ){
            [strTemp setString:[strTemp stringByAppendingFormat:@"%@",strCardPwd]];
        }
        int j=0;
        while ( j<i) {
            int index = j*4;
            NSRange range = NSMakeRange(index, 4);
            [strTemp setString:[strTemp stringByAppendingFormat:@"%@ ",[strCardPwd substringWithRange:range]]];
            j++;
            if( j>=i){
                if( [strTemp length] >= lengthSpace+1)
                    [strTemp setString:[strTemp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                break;
            }
        }
        int intTemp= length - (4*i);
        if(intTemp > 0 && i != 0 ){
            [strTemp setString:[strTemp stringByAppendingFormat:@"%@",[strCardPwd substringFromIndex:4*i]]];
        }
        self.cardPwdTextField.text = strTemp;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

@end
