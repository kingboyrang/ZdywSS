//
//  RechargeCellNode.h
//  WebServerCore
//
//  Created by dyn on 13-6-17.
//  Copyright (c) 2013年 dyn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RechargeCellNode : NSObject<NSCoding>
@property(nonatomic,copy)NSString    *totalFlagStr;
@property(nonatomic,copy)NSString    *nameStr;
@property(nonatomic,assign)NSInteger goodsID;
@property(nonatomic,copy)NSString    *bidStr;
@property(nonatomic,copy)NSString    *desStr;
@property(nonatomic,assign)NSInteger buyLimit;
@property(nonatomic,copy)NSString    *appleIdStr;
@property(nonatomic,assign)NSInteger sortID;
@property(nonatomic,copy)NSString    *goodsTypeStr;
@property(nonatomic,copy)NSString    *priceNumStr;
@property(nonatomic,copy)NSString    *recommendFlag;
@property(nonatomic,copy)NSString    *jumpFlag;//是否跳转
@property(nonatomic,copy)NSString    *adImageURL;//广告图片地址
@property(nonatomic,copy)NSString    *jumpURL;//调转链接地址
@property(nonatomic,copy)NSString    *minuteStr;
/*
 功能：比较节点数据是否相同
 输入参数：node ： 传入节点
 返回值：YES 表示相同。NO：表示不相同
 说明：是传入节点和自身数据比较
 */
- (BOOL)isEqualRechargeCell:(RechargeCellNode*)node;
@end
