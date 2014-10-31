//
//  FuncMenuView.h
//  ZdywClient
//
//  Created by ddm on 6/9/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FuncMenuModel.h"

@protocol FuncMenuViewDelegate;

@interface FuncMenuView : UIView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, assign) id <FuncMenuViewDelegate> delagate;
@property (nonatomic, strong) NSMutableArray *dataModelArray;

- (void)updateMainUI;

@end

@protocol FuncMenuViewDelegate <NSObject>

- (void)showFuncMenuDetailView:(FuncMenuModel*)funcMenuModel;

@end