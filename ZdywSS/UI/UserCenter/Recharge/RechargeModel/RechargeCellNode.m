//
//  RechargeCellNode.m
//  WebServerCore
//
//  Created by dyn on 13-6-17.
//  Copyright (c) 2013年 dyn. All rights reserved.
//

#import "RechargeCellNode.h"
#define  ReInit(R)       if(!R){R=@"";}\
else if([R isKindOfClass:[NSNull class]])\
{R=@"";} else if(R&&R.length == 0){R=@"";}


@implementation RechargeCellNode
@synthesize totalFlagStr = _totalFlagStr;
@synthesize nameStr      = _nameStr;
@synthesize goodsID      = _goodsID;
@synthesize bidStr       = _bidStr;
@synthesize desStr       = _desStr;
@synthesize buyLimit     = _buyLimit;
@synthesize appleIdStr   = _appleIdStr;
@synthesize sortID       = _sortID;
@synthesize goodsTypeStr = _goodsTypeStr;
@synthesize priceNumStr  = _priceNumStr;
@synthesize recommendFlag= _recommendFlag;
@synthesize jumpURL = _jumpURL;
@synthesize adImageURL = _adImageURL;
@synthesize jumpFlag = _jumpFlag;
@synthesize minuteStr = _minuteStr;
- (void)dealloc
{
    self.totalFlagStr = nil;
    self.nameStr = nil;
    self.bidStr = nil;
    self.desStr = nil;
    self.appleIdStr = nil;
    self.goodsTypeStr = nil;
    self.priceNumStr = nil;
    self.recommendFlag = nil;
    self.adImageURL = nil;
    self.jumpFlag = nil;
    self.jumpURL = nil;
    self.minuteStr = nil;
}
- (id)init
{
    if(self = [super init])
    {
        self.totalFlagStr = @"";
        self.nameStr = @"";
        self.goodsID  = 0;
        self.bidStr = @"";
        self.desStr = @"";
        self.buyLimit = 0;
        self.appleIdStr = @"";
        self.sortID = 0;
        self.goodsTypeStr = @"";
        self.priceNumStr= @"";
        self.recommendFlag = @"";
        self.adImageURL = @"";
        self.jumpFlag = @"";
        self.jumpURL = @"";
        self.minuteStr = @"";

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.totalFlagStr forKey:@"totalFlagStr"];
    [aCoder encodeObject:self.nameStr forKey:@"nameStr"];
    [aCoder encodeObject:[NSNumber  numberWithInteger:self.goodsID] forKey:@"goodsID"];
    [aCoder encodeObject:self.bidStr forKey:@"bidStr"];
    [aCoder encodeObject:self.desStr forKey:@"desStr"];
    [aCoder encodeObject:[NSNumber  numberWithInteger:self.buyLimit] forKey:@"buyLimit"];
    [aCoder encodeObject:self.appleIdStr forKey:@"appleIdStr"];
    [aCoder encodeObject:[NSNumber  numberWithInteger:self.sortID] forKey:@"sortID"];
    [aCoder encodeObject:self.goodsTypeStr forKey:@"goodsTypeStr"];
    [aCoder encodeObject:self.priceNumStr forKey:@"priceNumStr"];
    [aCoder encodeObject:self.recommendFlag forKey:@"recommendFlag"];
    [aCoder encodeObject:self.adImageURL forKey:@"adImageURL"];
    [aCoder encodeObject:self.jumpURL forKey:@"jumpURL"];
    [aCoder encodeObject:self.jumpFlag forKey:@"jumpFlag"];
    [aCoder encodeObject:self.minuteStr forKey:@"minuteStr"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    self.totalFlagStr = [aDecoder decodeObjectForKey:@"totalFlagStr"];
    self.nameStr = [aDecoder decodeObjectForKey:@"nameStr"];
    self.goodsID = [[aDecoder decodeObjectForKey:@"goodsID"] intValue];
    self.bidStr = [aDecoder decodeObjectForKey:@"bidStr"];
    self.desStr = [aDecoder decodeObjectForKey:@"desStr"];
    self.buyLimit = [[aDecoder decodeObjectForKey:@"buyLimit"] intValue];
    self.appleIdStr = [aDecoder decodeObjectForKey:@"appleIdStr"];
    self.sortID = [[aDecoder decodeObjectForKey:@"sortID"] intValue];
    self.goodsTypeStr = [aDecoder decodeObjectForKey:@"goodsTypeStr"];
    self.priceNumStr = [aDecoder decodeObjectForKey:@"priceNumStr"];
    self.recommendFlag = [aDecoder decodeObjectForKey:@"recommendFlag"];
    self.adImageURL = [aDecoder decodeObjectForKey:@"adImageURL"];
    self.jumpFlag = [aDecoder decodeObjectForKey:@"jumpFlag"];
    self.jumpURL = [aDecoder decodeObjectForKey:@"jumpURL"];
    self.minuteStr = [aDecoder decodeObjectForKey:@"minuteStr"];
    return self;
}

/*
 功能：比较节点数据是否相同
 输入参数：node ： 传入节点
 返回值：YES 表示相同。NO：表示不相同
 说明：是传入节点和自身数据比较
 */
- (BOOL)isEqualRechargeCell:(RechargeCellNode*)node
{
    
    //容错处理如果某项数据没有值就自动负值为@“”
    ReInit(self.totalFlagStr);
    ReInit(node.totalFlagStr);
    
    ReInit(self.nameStr);
    ReInit(node.nameStr);
    
    ReInit(self.bidStr);
    ReInit(node.bidStr);
    
    ReInit(self.desStr);
    ReInit(node.desStr);
    
    ReInit(self.appleIdStr);
    ReInit(node.appleIdStr);
    
    ReInit(self.goodsTypeStr);
    ReInit(node.goodsTypeStr);
    
    ReInit(self.recommendFlag);
    ReInit(node.recommendFlag);
    
    ReInit(self.adImageURL);
    ReInit(node.adImageURL);
    
    ReInit(self.jumpURL);
    ReInit(node.jumpURL);
    
    ReInit(self.jumpFlag);
    ReInit(node.jumpFlag);

    ReInit(self.minuteStr);
    ReInit(node.minuteStr);
    if([self.totalFlagStr isEqualToString: node.totalFlagStr]
       && [self.nameStr isEqualToString: node.nameStr]
       &&self.goodsID == node.goodsID
       &&[self.bidStr isEqualToString:node.bidStr]
       &&[self.desStr isEqualToString:node.desStr]
       &&self.buyLimit == node.buyLimit
       &&[self.appleIdStr isEqualToString:node.appleIdStr]
       &&self.sortID == node.sortID
       &&[self.goodsTypeStr isEqualToString:node.goodsTypeStr]
       &&[self.priceNumStr isEqualToString: node.priceNumStr]
       &&[self.recommendFlag isEqualToString:node.recommendFlag]
       &&[self.jumpFlag isEqualToString:node.jumpFlag]
       &&[self.adImageURL isEqualToString:node.adImageURL]
       &&[self.minuteStr isEqualToString:node.minuteStr]
       &&[self.jumpURL isEqualToString:node.jumpURL]  )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
