//
//  PayTypeRechargeViewController.m
//  ZdywClient
//
//  Created by ddm on 6/25/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "PayTypeRechargeViewController.h"
#import "PayTypeHeadView.h"
#import "PayTypeCell.h"
#import "PayTypeNode.h"
#import "RechargeInPutViewController.h"
#import "UPPayPlugin.h"
#import "WebsiteViewController.h"
#import "AlixPayOb.h"
#define kRechargeSelectAlixPayTag       123

@interface PayTypeRechargeViewController ()

@property (nonatomic, strong) PayTypeHeadView               *payTypeHeadView;
@property (nonatomic, strong) NSMutableArray                *rechargeList;
@property (nonatomic, strong) RechargeInPutViewController   *payInputViewController;
@property (nonatomic, strong) NSString                      *orderNO;
@property (nonatomic, strong) AlixPayOb                     *alixPayObject;

@end

@implementation PayTypeRechargeViewController

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
    self.title = @"套餐充值";
    _payTypeHeadView = [[PayTypeHeadView alloc] initWithFrame:CGRectMake(0, 0, 320, 115)];
    _payTypeHeadView.packageName.text = _rechargeModel.nameStr;
    [_mainTableView setTableHeaderView:_payTypeHeadView];
    
    _rechargeList = [ZdywUtils getLocalIdDataValue:kRechargePayTypeArray];
    
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    [_mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_mainTableView setScrollEnabled:NO];
    
    [self addObservers];
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(AlixPayRechargeFinish:)
                                                 name:kNotificationAlixPayRechargeFininsh
                                               object:nil];
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationRechargeFinish object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationAlixPayRechargeFininsh object:nil];
}

#pragma mark - PrivateMethod

- (void)payActionViewIndex:(NSInteger)index
{
    {
        PhoneNetType currentNetType = [ZdywUtils getCurrentPhoneNetType];
        
        if(index<[_rechargeList count])
        {
            PayTypeNode *cellNode = [NSKeyedUnarchiver unarchiveObjectWithData:
                                     [_rechargeList objectAtIndex:index]];
            self.accountInfo.payKindStr = cellNode.payKindStr;
            self.accountInfo.paytypeStr = cellNode.payTypeStr;
            self.accountInfo.payCodeStr = cellNode.descStr;
            if([self.accountInfo.payKindStr isEqualToString:@"701"]||[self.accountInfo.payKindStr isEqualToString:@"702"]||[self.accountInfo.payKindStr isEqualToString:@"703"])
            {
                //移动，联通电信充值
                if(_payInputViewController==NULL)
                {
                    _payInputViewController = [[RechargeInPutViewController alloc] init];
                }
                else
                {
                    _payInputViewController = NULL;
                }
                _payInputViewController = [[RechargeInPutViewController alloc] initWithNibName:NSStringFromClass([RechargeInPutViewController class]) bundle:nil];
                [_payInputViewController setContentInfo:_accountInfo] ;
                [self.navigationController pushViewController:_payInputViewController animated:YES];
            }
        }
        if([self.accountInfo.payKindStr isEqualToString:@"704"])
        {
            if(PNT_UNKNOWN == currentNetType)
            {
                [self showNetErrorAlert];
                return;
            }
            [self AlixpayRecharge];
            return;
        }
        //支付宝网页支付
        else if([self.accountInfo.payKindStr isEqualToString:@"707"])
        {
            if(PNT_UNKNOWN == currentNetType)
            {
                [self showNetErrorAlert];
                return;
            }
            [self AlixpayRecharge];
            return;
        }
        else if([self.accountInfo.payKindStr isEqualToString:@"705"])
        {
            //      银联充值
            if(PNT_UNKNOWN == currentNetType)
            {
                [self showNetErrorAlert];
                return;
            }
            [self unionRechargeAction: self.accountInfo];
        }
    }
}

//打开银联充值
-(void)unionRechargeAction: (MoneyInfoNode *)node
{
    NSString *strData = @"account=%@&paytype=%@&goodsid=%@&src=%@&wmlflag=%@&cardno=%@&cardpwd=%@&subbank=%@";
    
    strData = [NSString stringWithFormat:strData,
               [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserID],
               self.accountInfo.paytypeStr,
               self.accountInfo.goodIDStr,
               @"35",
               @"n",
               @"012345678901234",
               @"0123456789012345678",
               @""];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setValue:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceRecharge
                                              userInfo:nil
                                              postDict:dic];
    [SVProgressHUD showInView:self.navigationController.view status:@"数据提交中，请稍候..." networkIndicator:NO posY:-1 maskType:SVProgressHUDMaskTypeClear];
}

//支付宝充值
-(void)AlixpayRecharge
{
    NSString *strData = @"account=%@&paytype=%@&goodsid=%@&src=%@&wmlflag=%@&cardno=%@&cardpwd=%@&subbank=%@";
    strData = [NSString stringWithFormat:strData,
               [ZdywUtils getLocalStringDataValue:kZdywDataKeyUserID],
               self.accountInfo.paytypeStr,
               self.accountInfo.goodIDStr,
               @"35",
               @"n",
               @"012345678901234",
               @"0123456789012345678",
               @""];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setValue:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceRecharge
                                              userInfo:nil
                                              postDict:dic];
    [SVProgressHUD showInView:self.navigationController.view status:@"数据提交中，请稍候..." networkIndicator:NO posY:-1 maskType:SVProgressHUDMaskTypeClear];
}

- (void) showNetErrorAlert
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil
                                                         message:@"请检查您的网络后重试"
                                                        delegate:nil
                                               cancelButtonTitle:@"我知道了"
                                               otherButtonTitles:nil];
    [alertView show];
}

-(void)requestUnionPay: (NSDictionary *)dic{
    NSString *strTN = nil;
    
    NSString *strEpayResult = [dic objectForKey:@"epayresult"];
    NSArray *array = [strEpayResult componentsSeparatedByString:@"&"];
    for(NSString *str in array)
    {
        if([str rangeOfString:@"tn="].location != NSNotFound)
        {
            strTN = [str substringFromIndex:3];
            break;
        }
    }
    [UPPayPlugin startPay:strTN mode:@"00" viewController:self delegate:self];
}

- (void)requestAlixPay{
    if ([_orderNO length] == 0)
    {
        [SVProgressHUD dismiss];
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                             message:@"下单失败，请重新提交!"
                                                            delegate:self
                                                   cancelButtonTitle:@"确定"
                                                   otherButtonTitles:nil];
        [alertView show];
        return;
    }
    _alixPayObject = [[AlixPayOb alloc] init];
    NSString *backName = [ZdywCommonFun getAppConfigureInfoWithKey:kZdywDataKeyBrandID];
    //NSInteger result = [_alixPayObject requestAlixPay:[NSString stringWithFormat:@"%d",[self.accountInfo.moneyStr intValue]*1] schemaStr:backName orderIdStr:_orderNO];
    NSInteger result = [_alixPayObject requestAlixPay:self.accountInfo.moneyStr
                                            schemaStr:backName
                                           orderIdStr:_orderNO];
    switch (result)
    {
            //充值成功
        case 0:
        {
            [SVProgressHUD dismiss];
            
        }
            break;
            //用户味安装支付宝
        case 1:
        {
            [SVProgressHUD dismiss];
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                 message:@"您还没有安装支付宝的客户端，请先装。"
                                                                delegate:self
                                                       cancelButtonTitle:@"确定"
                                                       otherButtonTitles:nil];
            alertView.tag = kRechargeSelectAlixPayTag;
            [alertView show];
        }
            break;
            //证书签名失败
        case 2:
        {
            [SVProgressHUD dismissWithError:@"签名错误！"  afterDelay:2];
        }
            break;
        default:
            break;
    }
}

- (NSString *)replaceUnicode:(NSString *)unicodeStr {
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    NSLog(@"Output = %@", returnStr);
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}

#pragma mark - receive recharge data

- (void)receiveRechargeData:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    int nRet = [[dic objectForKey:@"result"] intValue];
    if([self.accountInfo.payKindStr isEqualToString:@"705"])
    {
        switch (nRet)
        {
            case 0:
            {
                [SVProgressHUD dismiss];
                [self requestUnionPay: dic];
            }
                break;
            default:
            {
                [SVProgressHUD dismissWithError:[dic objectForKey:@"reason"] afterDelay:2];
            }
                break;
        }
    }
    else if ([self.accountInfo.payKindStr isEqualToString:@"704"])
    {
        int nRet = [[dic objectForKey:@"result"] intValue];
        switch (nRet)
        {
            case 0:
            {
                _orderNO = [dic objectForKey: @"orderid"];
                [self requestAlixPay];
            }
                break;
            default:
            {
                [SVProgressHUD dismissWithError: [dic objectForKey:@"reason"] afterDelay:2];
            }
                break;
        }
    }
    else if([self.accountInfo.payKindStr isEqualToString:@"707"])
    {
        int  resultInt =[[dic objectForKey:@"result"] intValue];
        switch (resultInt) {
            case 0:
            {
                [SVProgressHUD dismiss];
                NSDictionary *dataDic = [dic objectForKey:@"epayresult"];
                if(dataDic&& [dataDic count]>0)
                {
                    NSString *methodStr = [dataDic objectForKey:@"method"];
                    if(methodStr && [methodStr length]>0)
                    {
                        NSMutableArray *parasArray = [ dataDic objectForKey:@"tags"];
                        NSString *parasStr = @"";
                        NSString *valueStr= @"";
                        if(parasArray && [parasArray count]>0)
                        {
                            for(int i = 0;i<[parasArray count]-1;i++)
                            {
                                NSDictionary *dic = [parasArray objectAtIndex:i];
                                valueStr  = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                                 (CFStringRef)[self replaceUnicode:[dic objectForKey:@"value"]],
                                                                                                                 NULL,
                                                                                                                 CFSTR(":/?#[]@!$&’()*+,;="),
                                                                                                                 kCFStringEncodingUTF8));
                                parasStr =[parasStr stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",[self replaceUnicode:[dic objectForKey:@"name"]],valueStr]];
                                
                            }
                            NSDictionary *dic = [parasArray objectAtIndex:[parasArray count]-1];
                            valueStr  = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                             (CFStringRef)[self replaceUnicode:[dic objectForKey:@"value"]],
                                                                                                             NULL,
                                                                                                             CFSTR(":/?#[]@!$&’()*+,;="),
                                                                                                             kCFStringEncodingUTF8));
                            parasStr =[parasStr stringByAppendingString:[NSString stringWithFormat:@"%@=%@",[self replaceUnicode:[dic objectForKey:@"name"]],valueStr]];
                            
                        }
                        if([methodStr isEqualToString:@"get"])
                        {
                            
                            NSString *targetURL = [NSString stringWithFormat:@"%@%@",[dataDic objectForKey:@"url"],parasStr];
                            
                            WebsiteViewController *tipWebViewController = [[WebsiteViewController alloc] init];
                            [tipWebViewController setTitle:@"支付宝网页支付" withURL:targetURL];
                            
                            [self.navigationController pushViewController:tipWebViewController animated:YES];
                        }
                    }
                }
            }
                break;
                
            default:
            {
                [SVProgressHUD dismissWithError: [dic objectForKey:@"reason"] afterDelay:2];
                
            }
                break;
        }
    }
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_rechargeList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PayTypeCell *payTypeCell = (PayTypeCell*)[tableView dequeueReusableCellWithIdentifier:@"payTypeCell"];
    if (payTypeCell == nil) {
        payTypeCell = [[PayTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"payTypeCell"];
    }
    PayTypeNode *cellNode = [NSKeyedUnarchiver unarchiveObjectWithData:[_rechargeList objectAtIndex:indexPath.row]];
    payTypeCell.payTypeName.text = cellNode.descStr;
    payTypeCell.payTypeImageview.image = [UIImage imageNamed:cellNode.leftIconImageName];
    if ([cellNode.payKindStr isEqualToString:@"704"]) {
        UILabel * tipLable = [[UILabel alloc] initWithFrame:CGRectMake(75, 28, 245, 15)];
        tipLable.text = @"推荐已安装支付宝客户端用户使用";
        tipLable.backgroundColor = [UIColor clearColor];
        tipLable.textColor = [UIColor lightGrayColor];
        tipLable.font = [UIFont systemFontOfSize:11.0];
        [payTypeCell addSubview:tipLable];
        payTypeCell.payTypeName.frame = CGRectMake(75, 9, 245, 23);
    }
    if ([cellNode.payKindStr isEqualToString:@"707"]) {
        UILabel * tipLable = [[UILabel alloc] initWithFrame:CGRectMake(75, 28, 245, 15)];
        tipLable.text = @"无需安装支付宝客户端直接支付";
        tipLable.backgroundColor = [UIColor clearColor];
        tipLable.textColor = [UIColor lightGrayColor];
        tipLable.font = [UIFont systemFontOfSize:11.0];
        [payTypeCell addSubview:tipLable];
        payTypeCell.payTypeName.frame = CGRectMake(75, 9, 245, 23);
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        UIView *menuCellBackView = [[UIView alloc] initWithFrame:payTypeCell.frame];
        menuCellBackView.backgroundColor = [UIColor lightGrayColor];
        [payTypeCell setSelectedBackgroundView:menuCellBackView];
    }
    return payTypeCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self payActionViewIndex:indexPath.row];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == kRechargeSelectAlixPayTag)
    {
        if(buttonIndex==0){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/cn/app/id333206289?mt=8"]];
        }
	}
}

#pragma mark - TCLUPPay Delegate

- (void)UPPayPluginResult:(NSString*)result
{
    NSLog(@"UPPayPluginResult = %@", result);
    
    if([result isEqualToString:@"success"])
    {
        [ZdywCommonFun ShowMessageBox:-1
                            titleName:@"提示"
                          contentText:@"正在为您核实支付情况，请在2分钟后查询余额"
                        cancelBtnName:@"继续充值"
                             delegate:nil];
    }
}

#pragma mark - AlixPay Delegate

- (void)AlixPayRechargeFinish:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    NSURL *returnURL  = [dic objectForKey:@"alixpayURL"];
    NSString*returnStr = [_alixPayObject handleOpenAppWithURL:returnURL];
    if([returnStr isEqualToString:@"正在为您核实支付情况，请在2分钟后查询余额"])
    {
        [ZdywCommonFun ShowMessageBox:-1
                            titleName:@"提示"
                          contentText:@"正在为您核实支付情况，请在2分钟后查询余额"
                        cancelBtnName:@"继续充值"
                             delegate:nil];
        
    }
}

@end
