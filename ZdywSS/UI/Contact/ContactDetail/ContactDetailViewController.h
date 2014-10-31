//
//  ContactDetailViewController.h
//  ZdywClient
//
//  Created by ddm on 6/11/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactNode.h"
#import <AddressBookUI/AddressBookUI.h>
#import "RecordMegerNode.h"
#import "ContactDetailCell.h"

//联系人详情类型
typedef enum
{
    ContactDetailViewTypeNormal = 0,   //联系人详情
    ContactDetailViewTypeCall,         //已知联系人通话记录详情
    ContactDetailViewTypeUnKnowCall,   //未知联系人通话记录详情
}ContactDetailViewType;

typedef enum{
    ContactDetailShowType_Nomal,
    ContactDetailShowType_call
} ContactDetailShowType;

@interface ContactDetailViewController : UIViewController<ABPersonViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,ABNewPersonViewControllerDelegate>

@property (nonatomic, strong) ContactNode               *contactNode;
@property (nonatomic, strong) ABPersonViewController    *personViewController;
@property (nonatomic, strong) IBOutlet UITableView      *contactDetailTableView;
@property (nonatomic, assign) ContactDetailViewType     contactDetailType;
@property (nonatomic, strong) RecordMegerNode           *recordMegerNode;
@property (nonatomic, strong) ABNewPersonViewController *myNewPersonViewController;
@property (nonatomic, assign) ContactDetailShowType     conDetailShowType;

@end
