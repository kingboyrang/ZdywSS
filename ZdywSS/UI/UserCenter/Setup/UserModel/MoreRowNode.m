//
//  MoreRowNode.m
//  WldhClient
//
//  Created by zhouww on 13-8-2.
//  Copyright (c) 2013年 guoling. All rights reserved.
//

#import "MoreRowNode.h"

@implementation MoreRowNode

- (id)init
{
    self = [super init];
    
    if(self)
    {
        self.tag = -1;
        
        self.imageName = nil;
        self.mainTitle = nil;
        self.subTitle = nil;
    }
    
    return self;
}

@end
