//
//  bindPhoneNumberViewController.h
//  WldhClient
//
//  Created by ddm on 4/30/14.
//  Copyright (c) 2014 guoling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BindPhoneNumberViewController : UIViewController<UIGestureRecognizerDelegate,UITextFieldDelegate>

@property (nonatomic, retain)IBOutlet UITextField *captachaTextField;
@property (nonatomic, retain)IBOutlet UITextField *phoneTextField;
@property (nonatomic, retain)IBOutlet UIImageView *numberBgImageView;
@property (nonatomic, retain)IBOutlet UIImageView *captchaBgImageView;
@property (nonatomic, retain)IBOutlet UILabel *loginSuccesLable;
@property (nonatomic, retain)IBOutlet UIButton *captchaButton;
@property (nonatomic, retain)IBOutlet UIButton *bindPhoneButton;

@end
