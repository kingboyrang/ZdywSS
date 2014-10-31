//
//  VerifyErrorViewController.h
//  ZdywXY
//
//  Created by zhongduan on 14-8-6.
//  Copyright (c) 2014年 zhongduan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerifyErrorViewController : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIView *voiceView;
@property (strong, nonatomic) IBOutlet UIImageView *verifyNoTextBg;
@property (strong, nonatomic) IBOutlet UITextField *verifyNoText;
@property (strong, nonatomic) IBOutlet UIButton *verifyNoBtn;
@property (strong, nonatomic) IBOutlet UIButton *checkVerfityBtn;
@property (strong, nonatomic) IBOutlet UIButton *callServiceBtn;
@property (strong, nonatomic) IBOutlet UILabel *timeLableText;

@property (assign,nonatomic) NSInteger  showType;
@property (strong,nonatomic) NSString * userNewPSW;
@property (strong,nonatomic) NSString * userPhoneNo;

@end
