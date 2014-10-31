//
//  FindPwdViewController.h
//  ZdywClient
//
//  Created by ddm on 6/12/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindPwdViewController : UIViewController<UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *phoneTextFieldBg;
@property (nonatomic, strong) IBOutlet UITextField *phoneTextField;
@property (nonatomic, strong) IBOutlet UIButton    *findPwdBtn;
@property (nonatomic, strong) IBOutlet UIButton    *findPwdErrorBtn;
@property (nonatomic, strong) IBOutlet UIView      *findPwdTipView;
@property (nonatomic, strong) IBOutlet UILabel     *findPwdTipLable;

@end
