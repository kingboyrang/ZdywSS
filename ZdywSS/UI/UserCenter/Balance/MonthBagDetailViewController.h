//
//  MonthBagDetailViewController.h
//  ZdywClient
//
//  Created by ddm on 6/24/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MonthBagDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSArray * monthBagArray;
@property (nonatomic, strong) IBOutlet UITableView *monthBagTable;

@end
