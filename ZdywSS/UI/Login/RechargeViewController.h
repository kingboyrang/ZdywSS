//
//  RechargeViewController.h
//  ZdywXY
//
//  Created by zhongduan on 14-8-4.
//  Copyright (c) 2014年 zhongduan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RechargeViewController : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate>
{
    NSString    *_rechargeCardText;
}
@property (strong, nonatomic) IBOutlet UILabel *phoneNo;
@property (strong, nonatomic) IBOutlet UITextField *rechargeCardNo;
@property (strong, nonatomic) IBOutlet UIButton *submitBtn;
@property (strong, nonatomic) IBOutlet UIButton *jumpNextStepBtn;
@property (strong, nonatomic) IBOutlet UIImageView *rechargeNoTextFieldBg;

@end
