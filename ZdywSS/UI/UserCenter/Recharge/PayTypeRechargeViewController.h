//
//  PayTypeRechargeViewController.h
//  ZdywClient
//
//  Created by ddm on 6/25/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RechargeCellNode.h"
#import "MoneyInfoNode.h"
#import "UPPayPluginDelegate.h"

@interface PayTypeRechargeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UPPayPluginDelegate>

@property (nonatomic, strong) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) RechargeCellNode *rechargeModel;
@property (nonatomic, strong) MoneyInfoNode    *accountInfo;
//设置金额列表界面的信息

@end
