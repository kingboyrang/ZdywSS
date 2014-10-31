//
//  UserFeedbackViewController.m
//  ZdywClient
//
//  Created by ddm on 6/12/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "UserFeedbackViewController.h"
#import "UIImage+Scale.h"

@interface UserFeedbackViewController ()

@end

@implementation UserFeedbackViewController

#pragma mark - lifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"意见反馈";
    [_contentTextView.layer setBorderColor:[UIColor colorWithRed:185.0/255 green:185.0/255 blue:185.0/255 alpha:1.0].CGColor];
    [_contentTextView.layer setBorderWidth:1.0];
    [_contentTextView.layer setCornerRadius:10.0];
    [_contentTextView.layer setMasksToBounds:YES];
    [_contentTextView setDelegate:self];
    [_contentTextView setTextColor:[UIColor lightGrayColor]];
    
    [_contactTextFieldBg setBackgroundColor:[UIColor clearColor]];
    [_contactTextFieldBg.layer setBorderColor:[UIColor colorWithRed:185.0/255 green:185.0/255 blue:185.0/255 alpha:1.0].CGColor];
    [_contactTextFieldBg.layer setBorderWidth:1.0];
    [_contactTextFieldBg.layer setCornerRadius:10.0];
    [_contactTextFieldBg.layer setMasksToBounds:YES];
    [_contactTextField setDelegate:self];
 
    UIImage * loginDefaultImage = [[[UIImage imageNamed:@"login_btn_default"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];
    UIImage * loginLightImage = [[[UIImage imageNamed:@"login_btn_light"] stretchableImageWithLeftCapWidth:36 topCapHeight:35] scaleToSize:CGSizeMake(560, 88)];

    
    [_sendBtn addTarget:self action:@selector(feedbackAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_sendBtn setBackgroundImage:loginDefaultImage forState:UIControlStateNormal];
    [_sendBtn setBackgroundImage:loginLightImage forState:UIControlStateHighlighted];

    //[_sendBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:25.0/255 green:151.0/255 blue:216.0/255 alpha:1.0]] forState:UIControlStateNormal];
    [_sendBtn.layer setMasksToBounds:YES];
    [_sendBtn.layer setCornerRadius:10.0];
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(missKeyBoard)];
    tapGr.delegate = self;
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:tapGr];
    [self addObservers];
    
    UISwipeGestureRecognizer *swipeGrDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(missKeyBoard)];
    swipeGrDown.delegate = self;
    [swipeGrDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipeGrDown];
    
    UISwipeGestureRecognizer *swipeGrUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(missKeyBoard)];
    swipeGrUp.delegate = self;
    [swipeGrUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:swipeGrUp];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self removeObservers];
}

#pragma mark - Observers

- (void)addObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedbackFinish:) name:kNotificationFeedbackFinish object:nil];
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationFeedbackFinish object:nil];
}

#pragma mark - PrivateMethod

- (void)feedbackFinish:(NSNotification *)notification{
    NSDictionary * dic = [notification userInfo];
    NSString *result = [dic objectForKey:@"result"];
    NSString *reason = [dic objectForKey:@"reason"];
    if ([result intValue] == 0) {
        _contentTextView.textColor = [UIColor lightGrayColor];
        _contentTextView.text = @"请输入您的意见或建议";
        _wordsCountLable.text = @"200";
        _contactTextField.text = nil;
        [SVProgressHUD dismissWithSuccess:@"反馈成功" afterDelay:1.0];
    } else {
        [SVProgressHUD dismissWithError:reason afterDelay:1.0];
    }
}

- (void)missKeyBoard{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        [_mainScrollView setContentOffset:CGPointMake(0, -64)];
    } else {
        [_mainScrollView setContentOffset:CGPointMake(0, 0)];
    }
    [_contentTextView resignFirstResponder];
    [_contactTextField resignFirstResponder];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"请输入您的意见或建议"]) {
        textView.text = nil;
    }
    textView.textColor = [UIColor blackColor];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [self.mainScrollView setContentOffset:CGPointMake(0, -10)];
    } else {
        [self.mainScrollView setContentOffset:CGPointMake(0, 50)];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    if (([textView.text length] >0) && ([textView.text length] <= 200)) {
        textView.textColor = [UIColor blackColor];
        _wordsCountLable.text = [NSString stringWithFormat:@"%d",200-textView.text.length];
    } else if(textView.text.length > 200){
        _wordsCountLable.text = @"0";
    } else {
        _wordsCountLable.text = @"200";
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSLog(@"range.location:%d",range.location);
    /***
    if (range.location > 200)
    {
        return  NO;
    }
    else
    {
        return YES;
    }
    ****/
    if ([textView.text length]+1 > 200)
    {
        if ([text isEqualToString:@""])
        {
            return YES;
        }
        
        return  NO;
    }
    else
    {
        return YES;
    }

}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if (![textView.text length]) {
        _contentTextView.textColor = [UIColor lightGrayColor];
        _contentTextView.text = @"请输入您的意见或建议";
        _wordsCountLable.text = @"200";
    }
    /***
    if ([textView.text length] > 200) {
        return NO;
    }
     ***/
    return YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        [self.mainScrollView setContentOffset:CGPointMake(0, 50)];
    } else {
        [self.mainScrollView setContentOffset:CGPointMake(0, 110)];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_sendBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    return YES;
}

#pragma mark - BtnAction

- (void)feedbackAction{
    [self missKeyBoard];
    if (![_contentTextView.text length] || [_contentTextView.text isEqualToString:@"请输入您的意见或建议"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"请输入反馈内容"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    NSString *strData = @"content=%@&clientVer=%@&mobile=%@&title=%@&email=%@&productId=%@";
    NSString *contentStr = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                (CFStringRef)self.contentTextView.text,
                                                                                                NULL,
                                                                                                CFSTR(":/?#[]@!$&’()*+,;="),
                                                                                                kCFStringEncodingUTF8)) ;
    NSString *clientVerStr = [ZdywUtils getLocalIdDataValue:kZdywDataKeyVersion];
    NSString *mobile = [ZdywCommonFun getCustomerPhone];
    NSString *contactStr = nil;
    if ([_contactTextField.text length]) {
        if ([ZdywCommonFun validateEmail:_contactTextField.text]||[ZdywCommonFun validateQQ:_contactTextField.text]) {
            contactStr = _contactTextField.text;
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"请输入邮箱或QQ"
                                                               delegate:nil
                                                      cancelButtonTitle:@"我知道了"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
    }
    NSString *titleStr = nil;
    NSString *productIdStr = [ZdywUtils getLocalIdDataValue:kZdywDataKeyBrandID];
    strData = [NSString stringWithFormat:strData,contentStr,clientVerStr,mobile,titleStr,contactStr,productIdStr];
    [SVProgressHUD showInView:self.navigationController.view
                       status:@"正在发送..."
             networkIndicator:NO
                         posY:-1
                     maskType:SVProgressHUDMaskTypeClear];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:strData forKey:kAGWDataString];
    [[ZdywServiceManager shareInstance]requestService:ZdywServiceFeedback
                                             userInfo:nil
                                             postDict:dic];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

@end
