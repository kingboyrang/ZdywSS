//
//  SystemNoticeView.h
//  ZdywClient
//
//  Created by ddm on 7/9/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SysMessageObj.h"

@protocol SystemNoticeViewDelegate;

@interface SystemNoticeView : UIView

@property (nonatomic, assign) id <SystemNoticeViewDelegate>delegate;
@property (nonatomic, strong) NSString *jumpPageIndex;
@property (nonatomic, strong) SysMessageObj *sysMessageObj;

- (id)initWithSysMessageObj:(SysMessageObj*)sysmessage;

- (CGRect)systemNoticeFrame;

@end


@protocol SystemNoticeViewDelegate <NSObject>

- (void)systemNoticeView:(SysMessageObj*)sysmessage dissMiss:(NSInteger)dismissWithButtonIndex;

@end