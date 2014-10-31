//
//  UserMessageCell.h
//  ZdywClient
//
//  Created by ddm on 7/3/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserMessageCellDelegate;

@interface UserMessageCell : UITableViewCell

@property (nonatomic, assign) id <UserMessageCellDelegate> delegate;
@property (nonatomic, strong) NSString  *msgStr;
@property (nonatomic, strong) UIView    *msgDetailView;
@property (nonatomic, strong) UIView    *showView;
@property (nonatomic, assign) NSInteger index;

- (NSInteger)msgCellHeight;

@end

@protocol UserMessageCellDelegate <NSObject>

- (void)showMsgDetailView:(NSInteger)index;
- (void)deleMsgIndex:(NSInteger)index;

@end