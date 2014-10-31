//
//  SelectVPSController.h
//  ZdywClient
//
//  Created by zhouww on 13-8-26.
//  Copyright (c) 2013年 guoling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocketController.h"

@interface SelectVPSController : NSObject <
GCDAsyncUdpSocketControllerDelegate>
{
    BOOL                        _bFindVPSFlag;
    
    NSMutableArray              *_testVPSArray;
}

// 单实例
+ (SelectVPSController *)shareInstance;

// 选择最优的vps
- (void)selectOptimalVPS;

@end
