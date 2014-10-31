//
//  MoreSectionNode.m
//  WldhClient
//
//  Created by zhouww on 13-8-2.
//  Copyright (c) 2013年 guoling. All rights reserved.
//

#import "MoreSectionNode.h"

@implementation MoreSectionNode

- (id)init
{
    self = [super init];
    
    if(self)
    {
        self.title = nil;
        self.child = [NSMutableArray arrayWithCapacity:0];
    }
    
    return self;
}

@end
