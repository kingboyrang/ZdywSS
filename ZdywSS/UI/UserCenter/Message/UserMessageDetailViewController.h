//
//  UserMessageDetailViewController.h
//  ZdywClient
//
//  Created by ddm on 7/4/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserMessageDetailViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextView *userMsgStrTextView;
@property (nonatomic, strong) NSString *userMsgStr;

@end
