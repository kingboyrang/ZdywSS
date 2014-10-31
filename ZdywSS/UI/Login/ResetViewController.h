//
//  ResetViewController.h
//  ZdywXY
//
//  Created by zhongduan on 14-8-7.
//  Copyright (c) 2014年 zhongduan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetViewController : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *phoneNoBg;
@property (strong, nonatomic) IBOutlet UIImageView *userPSWTextBg;
@property (strong, nonatomic) IBOutlet UIImageView *checkNewPSWTextBg;
@property (strong, nonatomic) IBOutlet UITextField *phoneNoText;
@property (strong, nonatomic) IBOutlet UITextField *userPSWText;
@property (strong, nonatomic) IBOutlet UITextField *checkNewPSWText;
@property (strong, nonatomic) IBOutlet UIButton *nextStepBtn;
@property (strong, nonatomic) IBOutlet UILabel *lableText;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (assign,nonatomic) NSInteger  showType;

@end
