//
//  MoneyInfoNode.m
//  WldhClient
//
//  Created by dyn on 13-8-6.
//  Copyright (c) 2013年 guoling. All rights reserved.
//

#import "MoneyInfoNode.h"

@implementation MoneyInfoNode

-(id)init{
    if(self = [super init]){
        self.paytypeStr     = @"";
        self.moneyStr       = @"";
        self.payCodeStr     = @"";
        self.goodIDStr      = @"";
        self.payKindStr = @"";
        self.moneyDescriptStr = @"";
        self.moneyNameStr = @"";
    }
    return self;
}

@end
