//
//  ContactAddressNode.m
//  ContactManager
//  联系人地址信息
//  Created by mini1 on 13-6-5.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import "ContactAddressNode.h"

@implementation ContactAddressNode

@synthesize countryName;
@synthesize stateName;
@synthesize cityName;
@synthesize streetName;
@synthesize addressLine;
@synthesize postCode;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.countryName = @"";
        self.stateName = @"";
        self.cityName = @"";
        self.streetName = @"";
        self.addressLine = @"";
        self.postCode = @"";
    }
    
    return self;
}

/*
 函数描述：获取地址字符串
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSString   地址
 作    者：刘斌
 */
- (NSString *)contactAddressString
{
    NSMutableString *addresStr = [NSMutableString stringWithString:@""];
    if (0 != self.countryName)
    {
        [addresStr appendString:self.countryName];
    }
    if (0 != self.stateName)
    {
        [addresStr appendString:self.stateName];
    }
    if (0 != self.cityName)
    {
        [addresStr appendString:self.cityName];
    }
    if (0 != self.streetName)
    {
        [addresStr appendString:self.streetName];
    }
    if (0 != self.addressLine)
    {
        [addresStr appendString:self.addressLine];
    }
    return addresStr;
}

@end
