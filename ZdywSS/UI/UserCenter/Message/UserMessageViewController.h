//
//  UserMessageViewController.h
//  ZdywClient
//
//  Created by ddm on 6/12/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserMessageCell.h"

@interface UserMessageViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UserMessageCellDelegate>

@property (nonatomic, strong) IBOutlet UITableView *msgListTableView;

@end
