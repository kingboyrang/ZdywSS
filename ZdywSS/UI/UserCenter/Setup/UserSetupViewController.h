//
//  UserSetupViewController.h
//  ZdywClient
//
//  Created by ddm on 6/12/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    Setup_ModifyPwd,
    Setup_BindPhone,
    Setup_DialType,
    Setup_KeySound,
    Setup_BackUpContact,
    Setup_Update,
    Setup_About
}Setup;

@interface UserSetupViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UIButton     *logoutBtn;
@property (nonatomic, strong) IBOutlet UITableView  *setUpTableView;

@end
