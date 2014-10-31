//
//  ContactAddressNode.h
//  ContactManager
//  联系人地址信息
//  Created by mini1 on 13-6-4.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactAddressNode : NSObject

@property(nonatomic,retain) NSString         *countryName;
@property(nonatomic,retain) NSString         *stateName;
@property(nonatomic,retain) NSString         *cityName;
@property(nonatomic,retain) NSString         *streetName;
@property(nonatomic,retain) NSString         *addressLine;
@property(nonatomic,retain) NSString         *postCode;

/*
 函数描述：获取地址字符串
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSString   地址
 作    者：刘斌
 */
- (NSString *)contactAddressString;

@end
