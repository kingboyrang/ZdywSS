//
//  DirectCallViewController.h
//  ZdywClient
//
//  Created by ddm on 7/1/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallInfoNode.h"

@interface DirectCallViewController : UIViewController<UIAlertViewDelegate>



@property (nonatomic, strong) CallInfoNode *callInfoNode;
@property (weak, nonatomic) IBOutlet UIView *callInfoView;

@property (nonatomic, strong) IBOutlet UIScrollView *mianScrollView;
@property (nonatomic, strong) IBOutlet UIButton     *muteBtn;
@property (nonatomic, strong) IBOutlet UIButton     *handsfreeBtn;
@property (nonatomic, strong) IBOutlet UIButton     *dialKeyBtn;
@property (nonatomic, strong) IBOutlet UIButton     *contactBtn;
@property (nonatomic, strong) IBOutlet UIButton     *hangupCallBtn;

@property (nonatomic, strong) IBOutlet UILabel      *contactNameLable;
@property (nonatomic, strong) IBOutlet UIImageView  *signalsImageView;
@property (nonatomic, strong) IBOutlet UILabel      *directLable;

@property (nonatomic, strong) IBOutlet UIView       *dialPlateView;
@property (nonatomic, strong) IBOutlet UIButton     *dialHangupCallBtn;
@property (nonatomic, strong) IBOutlet UIButton     *hideDialPlateBtn;

@property (nonatomic, strong) IBOutlet UILabel      *phoneArea;
@property (nonatomic, strong) UILabel  *clickKeyLable;

@property  (nonatomic,strong) UIAlertView *AlertView;
@property  (nonatomic, assign)    BOOL   isShowAlertView;


- (IBAction)clickDialPlate:(id)sender;

- (void)startCall:(CallInfoNode *)callInfoNode;

@end
