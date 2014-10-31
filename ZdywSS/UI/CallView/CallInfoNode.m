//
//  CallInfoNode.m
//  WldhClient
//
//  Created by zhouww on 13-8-3.
//  Copyright (c) 2013年 guoling. All rights reserved.
//

#import "CallInfoNode.h"

@implementation CallInfoNode

- (id)init
{
    self = [super init];
    
    if(self)
    {
        self.calleePhone = nil;
        self.calleeName = nil;
        self.calleeRecordID = -1;
        
        self.calltype = ZdywCallNoneType;
    }
    
    return self;
}

@end
