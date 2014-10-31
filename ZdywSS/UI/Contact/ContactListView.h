//
//  ContactListView.h
//  ZdywClient
//
//  Created by ddm on 6/10/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactListCell.h"
#import "ContactManager.h"

@protocol ContactListViewDelegate;

@interface ContactListView : UIView<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,ContactListCellDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *contactListTableView;
@property (nonatomic, strong) IBOutlet UIImageView *seachBarBgView;
@property (nonatomic, strong) IBOutlet UITextField *searchTextField;
@property (nonatomic, strong) UIView *notReadTipsView;
@property (nonatomic, assign) id <ContactListViewDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIButton              *addNewContactBtn;

//解决第一次安装时无法取得通讯录问题
- (void)loadFirstContact;
@end

@protocol ContactListViewDelegate <NSObject>

- (void)showContactDetailView:(ContactNode*)contactNodeInfo;

- (void)addNewContact;

@end