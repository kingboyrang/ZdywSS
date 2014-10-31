//
//  ContactListCell.h
//  ZdywClient
//
//  Created by ddm on 5/23/14.
//  Copyright (c) 2014 GuoLing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactNode.h"

@protocol ContactListCellDelegate;

@interface ContactListCell : UITableViewCell

@property (nonatomic, assign) id <ContactListCellDelegate> contactListCellDelegate;
@property (nonatomic, strong) UILabel *contactNameLable;
@property (nonatomic) BOOL isLastCell;
@property (nonatomic, strong) UIButton *callPhoneBtn;
@property (nonatomic, strong) ContactNode *contactInfo;

@end

@protocol ContactListCellDelegate <NSObject>

- (void)makeCallToContact:(ContactNode*)contactInfo;

@end