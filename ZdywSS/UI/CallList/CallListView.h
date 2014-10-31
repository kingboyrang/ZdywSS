//
//  CallListView.h
//  ZdywClient
//
//  Created by ddm on 6/9/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DialPlateView.h"
#import "ContactNode.h"
#import "DialSearchContactCell.h"
#import "CallListCell.h"
#import "RecordMegerNode.h"
#define kCallListViewOffSet     70
typedef enum {
    EditStatus_Normal,
    EditStatus_Finish
} EditStatus;

@protocol CallListViewDelegate;

@interface CallListView : UIView<DialPlateViewDelegate,UITableViewDataSource,
UITableViewDelegate,UIActionSheetDelegate,DialSearchCellDelegate,UIScrollViewDelegate,CallListCellDelegate>

- (void)updateSubViewFrame:(BOOL)bUpdata;

@property (nonatomic, assign) id <CallListViewDelegate> delegate;
@property (nonatomic, strong) UIView *bottomView;

@end

@protocol CallListViewDelegate <NSObject>

- (void)addNewContact:(NSString *)phoneStr;
- (void)addNewNumToContact:(NSString *)phoneStr;
- (void)showContactDetailViewWithContactID:(NSInteger)contactID;
- (void)showRecordMegerDetailView:(RecordMegerNode *)recordNode;

@end