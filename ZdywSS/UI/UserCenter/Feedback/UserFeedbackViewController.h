//
//  UserFeedbackViewController.h
//  ZdywClient
//
//  Created by ddm on 6/12/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserFeedbackViewController : UIViewController<UITextViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UITextView   *contentTextView;
@property (nonatomic, strong) IBOutlet UITextField  *contactTextField;
@property (nonatomic, strong) IBOutlet UIButton     *sendBtn;
@property (nonatomic, strong) IBOutlet UILabel      *wordsCountLable;
@property (nonatomic, strong) IBOutlet UIScrollView *mainScrollView;
@property (nonatomic, strong) IBOutlet UIImageView  *contactTextFieldBg;

@end
