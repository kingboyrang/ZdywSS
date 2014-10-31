//
//  VerifyViewController.h
//  ZdywXY
//
//  Created by zhongduan on 14-8-6.
//  Copyright (c) 2014年 zhongduan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerifyViewController : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *phoneNo;
@property (strong, nonatomic) IBOutlet UITextField *verifyNoText;
@property (strong, nonatomic) IBOutlet UIButton *verfityNoBtn;
@property (strong, nonatomic) IBOutlet UIButton *checkVerfityBtn;
@property (strong, nonatomic) IBOutlet UIButton *unReceiveMsgBtn;
@property (strong, nonatomic) IBOutlet UIImageView *_verifyNoTextFieldBg;
@property (strong, nonatomic) IBOutlet UILabel *labelText;
@property (strong, nonatomic) IBOutlet UILabel *timeLableText;

@property (assign,nonatomic) NSInteger  showType;
@property (strong,nonatomic) NSString * userNewPSW;
@property (strong,nonatomic) NSString * userPhoneNo;

@end
