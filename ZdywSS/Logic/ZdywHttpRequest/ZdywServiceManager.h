//
//  ZdywServiceManager.h
//  ZdywMini
//
//  Created by mini1 on 14-5-29.
//  Copyright (c) 2014年 Guoling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZdywRequestObj.h"

@interface ZdywServiceManager : NSObject
<ZdywRequestDelegate>
{
    NSMutableDictionary *_requestDict;
}

+ (ZdywServiceManager *)shareInstance;

- (void)requestService:(ZdywServiceType)serviceType
              userInfo:(NSDictionary *)userInfo
              postDict:(NSDictionary *)postDict;

- (void)stopRequestWithType:(ZdywServiceType)serviceType;

@end
