//
//  PayTypeNode.m
//  WebServerCore
//
//  Created by dyn on 13-6-17.
//  Copyright (c) 2013年 dyn. All rights reserved.
//

#import "PayTypeNode.h"

@implementation PayTypeNode

- (id)init
{
    if(self  = [super init])
    {
        self.descStr = @"";
        self.payTypeStr = @"";
        self.payKindStr = @"";
        self.leftIconImageName = @"";
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.descStr forKey:@"descStr"];
    [aCoder encodeObject:self.payKindStr forKey:@"payKindStr"];
    [aCoder encodeObject:self.payTypeStr forKey:@"payTypeStr"];
    [aCoder encodeObject:self.leftIconImageName forKey:@"leftIconImageName"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    self.descStr = [aDecoder decodeObjectForKey:@"descStr"];
    self.payKindStr = [aDecoder decodeObjectForKey:@"payKindStr"];
    self.payTypeStr = [aDecoder decodeObjectForKey:@"payTypeStr"];
    self.leftIconImageName = [aDecoder decodeObjectForKey:@"leftIconImageName"];
    
    return self;
}

/*
 功能：比较节点数据是否相同
 输入参数：node ： 传入节点
 返回值：YES 表示相同。NO：表示不相同
 说明：是传入节点和自身数据比较
 */
- (BOOL)isEqualPayTypeCell:(PayTypeNode*)node
{
    if([self.descStr isEqualToString: node.descStr]
       && [self.payKindStr isEqualToString: node.payKindStr]
       &&[self.payTypeStr isEqualToString: node.payTypeStr])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
