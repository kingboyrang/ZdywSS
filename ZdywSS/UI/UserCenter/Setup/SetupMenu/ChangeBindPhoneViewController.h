//
//  ChangeBindPhoneViewController.h
//  ZdywClient
//
//  Created by ddm on 6/21/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeBindPhoneViewController : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UILabel      *phoneLable;
@property (nonatomic, strong) IBOutlet UIImageView  *oldPwdTextBg;
@property (nonatomic, strong) IBOutlet UIImageView  *pwdTextBg;
@property (nonatomic, strong) IBOutlet UIImageView  *verificaTextBg;
@property (nonatomic, strong) IBOutlet UITextField  *oldPwdTextField;
@property (nonatomic, strong) IBOutlet UITextField  *phoneTextField;
@property (nonatomic, strong) IBOutlet UITextField  *verificaTextField;
@property (nonatomic, strong) IBOutlet UIButton     *findPwdBtn;
@property (nonatomic, strong) IBOutlet UIButton     *changPhoneBtn;
@property (nonatomic, strong) IBOutlet UIButton     *sendVericaBtn;
@property (nonatomic, strong) IBOutlet UIScrollView *mianScrollView;
@property (strong, nonatomic) IBOutlet UILabel *timeLableText;

@end
