//
//  CallBackViewController.h
//  ZdywClient
//
//  Created by ddm on 7/2/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallInfoNode.h"

@interface CallBackViewController : UIViewController <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *callInfoView;
@property (weak, nonatomic) IBOutlet UILabel *waitLabel;
@property (weak, nonatomic) IBOutlet UILabel *strangeCallLabel;

@property (nonatomic, strong) IBOutlet UIImageView *pointImageView;
@property (nonatomic, strong) CallInfoNode  *myCallInfoNode;
@property (nonatomic, strong) IBOutlet UILabel     *nameLable;
@property (nonatomic, strong) IBOutlet UILabel     *areaLable;

- (void)startCall:(CallInfoNode *)callInfoNode;

@end
