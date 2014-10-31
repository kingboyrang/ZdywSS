//
//  CallWrapper.h
//  WldhClient
//
//  Created by zhouww on 13-8-3.
//  Copyright (c) 2013年 guoling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomPointView.h"

@class CallInfoNode;
@class CallViewController;

@interface CallWrapper : NSObject
<UIActionSheetDelegate,CustomPointViewDelegate>
{
    CallViewController              *_callViewController;
}

@property(nonatomic,retain) CallInfoNode  *myCallInfoNode;
@property(nonatomic,assign) BOOL          isCalling;

// 单实例
+ (CallWrapper *)shareCallWrapper;

// 发起呼叫
- (void)initiatingCall:(CallInfoNode *)callInfoNode;

@end
