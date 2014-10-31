//
//  LoginViewController.h
//  ZdywClient
//
//  Created by ddm on 6/12/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView   *textFieldBg;
@property (nonatomic, strong) IBOutlet UIButton      *loginBtn;
@property (nonatomic, strong) IBOutlet UIButton      *findPwdBtn;
@property (nonatomic, strong) IBOutlet UIButton      *showServiceBtn;
@property (nonatomic, strong) IBOutlet UITextField   *phoneTextField;
@property (nonatomic, strong) IBOutlet UITextField   *pwdTextField;

@end
