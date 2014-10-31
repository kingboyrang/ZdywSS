//
//  ModifyPWDViewController.h
//  UXinClient
//
//  Created by Liam Peng on 11-11-18.
//  Copyright (c) 2011年 D-TONG-TELECOM. All rights reserved.
//

#import <UIKit/UIKit.h>
 
@interface ModifyPWDViewController :  UIViewController<
UITextFieldDelegate,
UIAlertViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UITextField         *pTextFiledOldPwd;              // 旧密码
@property (nonatomic, strong) IBOutlet UITextField         *pTextFiledNewPwd;              // 新密码
@property (nonatomic, strong) IBOutlet UITextField         *pTextFiledNewPwdConfire;       // 确认密码
@property (nonatomic, strong) IBOutlet UIButton            *modifyPwdBtn;
@property (nonatomic, strong) IBOutlet UIImageView         *textFieldBg;
@property (nonatomic, strong) IBOutlet UIImageView         *pwdBg;
@property (nonatomic, strong) IBOutlet UIImageView         *pwdConfireBg;
@property (nonatomic, strong) IBOutlet UIButton            *findPwdBtn;

- (IBAction)clickModify:(id)sender;

@end
