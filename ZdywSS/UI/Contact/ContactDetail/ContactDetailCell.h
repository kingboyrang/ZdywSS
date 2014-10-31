//
//  ContactDetailCell.h
//  ZdywClient
//
//  Created by ddm on 6/16/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContactDetailCellDelegate;

@interface ContactDetailCell : UITableViewCell

@property (nonatomic, strong) UILabel      *phoneLable;              //电话号码
@property (nonatomic, strong) UILabel      *phoneTypeLable;          //电话类型
@property (nonatomic, strong) UILabel      *phoneAreaLable;          //电话所属区域
@property (nonatomic, strong) UILabel      *phoneOperatorsLable;     //电话运营商
@property (nonatomic, strong) UIImageView  *separateLine;
@property (nonatomic, strong) UIButton     *callPhoneBtn;
@property (nonatomic, strong) NSString     *callName;                //联系人名称
@property (nonatomic, assign) NSInteger     callContactID;           //联系人标识
@property (nonatomic, strong) NSString     *callNumber;              //联系人电话

@end

