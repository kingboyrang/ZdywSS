//
//  RechargeInPutViewController.h
//  WldhClient
//
//  Created by dyn on 13-8-8.
//  Copyright (c) 2013年 guoling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoneyInfoNode.h"
@interface RechargeInPutViewController : UIViewController
<UITextFieldDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *cardNoBg;
@property (nonatomic, strong) IBOutlet UIImageView *cardPwdBg;
@property (nonatomic, strong) IBOutlet UITextField *cardNoTextField;
@property (nonatomic, strong) IBOutlet UITextField *cardPwdTextField;
@property (nonatomic, strong) IBOutlet UIButton    *rechargeBtn;

@property (nonatomic, strong) MoneyInfoNode *moneyInfoObject;

-(void)setContentInfo:(MoneyInfoNode*)info;

@end
