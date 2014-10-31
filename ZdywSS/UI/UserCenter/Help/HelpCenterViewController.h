//
//  HelpCenterViewController.h
//  ZdywClient
//
//  Created by ddm on 6/20/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpCenterViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) IBOutlet UITableView *helpMenuTable;
@property (nonatomic, strong) IBOutlet UILabel     *servicePhoneLable;
@property (nonatomic, strong) IBOutlet UIButton    *callBtn;
@property (nonatomic, strong) UIImageView *callImageView;

@end
