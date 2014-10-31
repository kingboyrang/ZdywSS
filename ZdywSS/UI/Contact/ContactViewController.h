//
//  ContactViewController.h
//  ZdywClient
//
//  Created by ddm on 5/22/14.
//  Copyright (c) 2014 GuoLing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordMegerNode.h"
#import <AddressBookUI/AddressBookUI.h>

//联系人列表类型
typedef enum
{
    ContactListTypeNormal = 0,  //常用类型，仅做列表展示
    ContactListTypeCall,        //通话中查看模式
    ContactListTypeSingleChoose, //单选模式
    ContactListTypeMulityChoose, //多选模式
    ContactListTypeChooseWithoutCommon, //无常用联系人的选择
}ContactListType;

@interface ContactViewController :UIViewController <UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,ABPersonViewControllerDelegate>

@property (nonatomic, strong) ABPersonViewController    *personViewController;
@property (nonatomic, strong) IBOutlet UITableView *contactListTable;
@property (nonatomic, strong) IBOutlet UIView *notReadTipsView;
@property (nonatomic) ContactListType contactListType;
@property (nonatomic, strong) NSDictionary *contactDataDict;     //所有的联系人
@property (nonatomic, strong) NSString  *phoneNumberStr;
@property (nonatomic, strong) RecordMegerNode        *callMegerRecord;  //通话记录
@property (nonatomic, strong) IBOutlet UIImageView *seachBarBgView;
@property (nonatomic, strong) IBOutlet UITextField *searchTextField;

@end
