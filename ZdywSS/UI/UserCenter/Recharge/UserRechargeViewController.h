//
//  UserRechargeViewController.h
//  ZdywClient
//
//  Created by ddm on 6/12/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserRechargeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate,UIScrollViewDelegate>
{
    NSString    *_rechargeCardText;
}

@property (nonatomic, strong) IBOutlet UILabel      *uidLable;
@property (nonatomic, strong) IBOutlet UILabel      *phoneLable;
@property (nonatomic, strong) IBOutlet UIImageView  *textFieldBg;
@property (nonatomic, strong) IBOutlet UITextField  *cardPwdTextField;
@property (nonatomic, strong) IBOutlet UITableView  *chargeListTable;
@property (nonatomic, strong) IBOutlet UIButton     *rechargeBtn;
@property (nonatomic, strong) IBOutlet UIButton     *moreChargeBtn;
@property (nonatomic, strong) IBOutlet UILabel      *onLineRechargeLable;
@property (nonatomic, strong) IBOutlet UIScrollView *mainScrollView;

@end
