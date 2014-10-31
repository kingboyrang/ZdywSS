//
//  CallListCell.h
//  WldhClient
//
//  Created by mini1 on 13-8-6.
//  Copyright (c) 2013年 guoling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordMegerNode.h"
#import "ContactNode.h"

@protocol CallListCellDelegate;

@interface CallListCell : UITableViewCell

@property (nonatomic, assign) id <CallListCellDelegate> delegate;
@property (nonatomic, strong) UILabel           *nameLabel;
@property (nonatomic, strong) UILabel           *phoneLabel;
@property (nonatomic, strong) UILabel           *timeLabel;
@property (nonatomic, strong) UILabel           *attributionLabel;
@property (nonatomic, strong) NSIndexPath       *cellIndexPath;
@property (nonatomic, strong) UIImageView       *buttomLine;
@property (nonatomic, strong) RecordMegerNode   *recordMegerNode;
@property (nonatomic, strong) UIButton          *showCallRecordsBtn;
@property (nonatomic, strong) UIImageView       *btnImageView;

@end

@protocol CallListCellDelegate <NSObject>

- (void)showRecordMegerDetail:(RecordMegerNode*)recordNode;

@end