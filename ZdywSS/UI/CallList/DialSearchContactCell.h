//
//  DialSearchContactCell.h
//  WldhClient
//  拨号盘搜索联系人界面
//  Created by mini1 on 13-8-1.
//  Copyright (c) 2013年 guoling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FontLabel.h"
#import "T9ContactRecord.h"

@protocol  DialSearchCellDelegate;

@interface DialSearchContactCell : UITableViewCell

@property (nonatomic, assign) id <DialSearchCellDelegate> delegate;
@property (nonatomic, strong)  FontLabel  *contactNameLab;
@property (nonatomic, strong)  FontLabel  *phoneNumberLab;
@property (nonatomic, strong)  UIButton   *detailBtn;
@property (nonatomic, assign)  NSInteger   contactID;

- (void)createCustomColorLabe:(T9ContactRecord*)contactRecordA;

@end

@protocol DialSearchCellDelegate <NSObject>

- (void)showContactDetail:(NSInteger)contactID;

@end
