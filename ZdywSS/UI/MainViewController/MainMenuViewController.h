//
//  MainMenuViewController.h
//  ZdywClient
//
//  Created by ddm on 5/21/14.
//  Copyright (c) 2014 ddm GuoLing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallListView.h"
#import "ContactListView.h"
#import "FuncMenuView.h"
#import <AddressBookUI/AddressBookUI.h>
#import "SystemNoticeView.h"

typedef enum{
    MainMenuShowType_CallList,
    MainMenuShowType_ContactList
} MainMenuShowType;

@interface MainMenuViewController : UIViewController<ContactListViewDelegate,FuncMenuViewDelegate,CallListViewDelegate,UIGestureRecognizerDelegate,ABNewPersonViewControllerDelegate,SystemNoticeViewDelegate>

@property (nonatomic, strong) IBOutlet UIView           *headTitleView;
@property (nonatomic, strong) IBOutlet UIButton         *callListBtn;//通话记录
@property (nonatomic, strong) IBOutlet UIButton         *contactListBtn;//联系人
@property (nonatomic, strong) IBOutlet UIButton         *funcMenuBtn;
@property (nonatomic, strong) IBOutlet UIScrollView     *mianScrollView;
@property (nonatomic, strong) ABNewPersonViewController *myNewPersonController;
@property (nonatomic, strong) IBOutlet UIImageView      *msgIconImageView;
@property (strong, nonatomic) IBOutlet UILabel *noticeLable;

@property (nonatomic, strong) IBOutlet UIView * noticeView;
@property (strong, nonatomic) IBOutlet UIButton *detailsBtn;

@property (nonatomic, assign) MainMenuShowType mainMenuShowType;


- (void)showSystemNoticeView;

@end
