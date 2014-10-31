//
//  NewModifyPwdViewController.h
//  ZdywClient
//
//  Created by ddm on 6/20/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewModifyPwdViewController : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *textFieldBg;
@property (nonatomic, strong) IBOutlet UITextField *secretTextField;
@property (nonatomic, strong) IBOutlet UITextField *sureNewPwdTextField;

@property (nonatomic, strong) IBOutlet UIButton    *modifyBtn;
@property (nonatomic, strong) IBOutlet UIButton    *skipBtn;

@end
