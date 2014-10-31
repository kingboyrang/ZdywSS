//
//  UserBalanceViewController.h
//  ZdywClient
//
//  Created by ddm on 6/12/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserBalanceViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel  *balanceLable;
@property (nonatomic, strong) IBOutlet UILabel  *packageTimeLable;
@property (nonatomic, strong) IBOutlet UIButton *showPackageBtn;
@property (nonatomic, strong) IBOutlet UILabel  *packageTitle;

@end
