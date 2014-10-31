//
//  UserBalanceViewController.m
//  ZdywClient
//
//  Created by ddm on 6/12/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "UserBalanceViewController.h"
#import "MonthBagModel.h"
#import "MonthBagDetailViewController.h"
#import "WebsiteViewController.h"

@interface UserBalanceViewController ()

@property (nonatomic, strong) NSArray *packagelist;

@end

@implementation UserBalanceViewController

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
    
    _packageTitle.hidden =YES;
    _packageTimeLable.hidden =YES;
    // Do any additional setup after loading the view from its nib.
    self.title = @"余额";
    [self addObservers];
    [self requstBalanceInfo];
    
    [_showPackageBtn addTarget:self action:@selector(showPackageDetail) forControlEvents:UIControlEventTouchUpInside];
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDataForQueryBalance:)
                                                 name:kNotificationSearchBalanceFinish
                                               object:nil];
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationSearchBalanceFinish
                                                  object:nil];
}

#pragma mark - HTTPAction

//请求用户余额
- (void)requstBalanceInfo
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceSearchBalance
                                              userInfo:nil
                                              postDict:dic];
}

- (void)receiveDataForQueryBalance:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    if([[dic objectForKey:@"result"] integerValue] == 0)
    {
        NSString *balanceStr = [dic objectForKey:@"balance"];
        if ([balanceStr length] && ![balanceStr isKindOfClass:[NSNull class]]) {
            _balanceLable.text = [NSString stringWithFormat:@"%@元",balanceStr];
        } else {
            _balanceLable.text = @"0.0元";
        }
        //包月套餐
        NSMutableArray *tempArray = [dic objectForKey:@"packagelist"];
        if ([tempArray count]) {
            _packagelist = (NSArray *)tempArray;
            MonthBagModel * monthBagModel = [[MonthBagModel alloc] initWithDict:[tempArray objectAtIndex:tempArray.count - 1]];
            NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd";
            NSDate *expDate = [dateFormatter dateFromString:monthBagModel.endTime];
            if ([expDate timeIntervalSinceDate:[NSDate date]] < 0) {
                _packageTimeLable.text = @"已过期";
            } else{
                NSArray *dateList = [[monthBagModel.endTime substringToIndex:10] componentsSeparatedByString:@"-"];
                NSInteger  year = [[dateList objectAtIndex:0] integerValue];
                NSInteger  month = [[dateList objectAtIndex:1] integerValue];
                NSInteger  day = [[dateList objectAtIndex:2] integerValue];
                _packageTimeLable.text = [NSString stringWithFormat:@"%d年%d月%d日",year,month,day];
            }
            [_packageTitle setTextColor:[UIColor blackColor]];
            [_packageTitle setHidden:NO];
            [_packageTimeLable setHidden:NO];
            [_showPackageBtn setHidden:NO];
            [_showPackageBtn setTitle:[NSString stringWithFormat:@"历次购买套餐详情（%d个）>",tempArray.count] forState:UIControlStateNormal];
        } else {
            _packageTimeLable.text = @"暂无包月套餐";
            [_packageTitle setTextColor:[UIColor lightGrayColor]];
            //[_showPackageBtn setHidden:YES];
        }
    }
}

#pragma mark - btnAction

- (void)showPackageDetail{
//    MonthBagDetailViewController *monthBagDetailView = [[MonthBagDetailViewController alloc] initWithNibName:NSStringFromClass([MonthBagDetailViewController class]) bundle:nil];
//    monthBagDetailView.monthBagArray = _packagelist;
//    [self.navigationController pushViewController:monthBagDetailView animated:YES];
    
    WebsiteViewController *websiteView = [[WebsiteViewController alloc] initWithNibName:NSStringFromClass([WebsiteViewController class]) bundle:nil];
    [websiteView setTitle:@"充值记录" withURL:[ZdywCommonFun getRechargeLogUrl]];
    [self.navigationController pushViewController:websiteView animated:YES];
}

@end
