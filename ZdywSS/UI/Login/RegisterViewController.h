//
//  RegisterViewController.h
//  ZdywXY
//
//  Created by zhongduan on 14-8-1.
//  Copyright (c) 2014年 zhongduan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate>
{
    NSString *   _phoneNoText;
}
@property (strong, nonatomic) IBOutlet UITextField *phoneNo;
@property (strong, nonatomic) IBOutlet UITextField *phoneNoCheck;
@property (strong, nonatomic) IBOutlet UIButton *nextStepBtn;
@property (strong, nonatomic) IBOutlet UIImageView *phoneNoTextBg;
@property (strong, nonatomic) IBOutlet UIImageView *phoneNoCheckTextBg;

@end
