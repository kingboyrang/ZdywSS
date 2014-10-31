//
//  PayTypeNode.h
//  WebServerCore
//
//  Created by dyn on 13-6-17.
//  Copyright (c) 2013年 dyn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayTypeNode : NSObject<NSCoding>
@property(nonatomic,copy)NSString  *descStr;
@property(nonatomic,copy)NSString  *payTypeStr;
@property(nonatomic,copy)NSString  *payKindStr;
@property(nonatomic,copy)NSString  *leftIconImageName;
/*
 功能：比较节点数据是否相同
 输入参数：node ： 传入节点
 返回值：YES 表示相同。NO：表示不相同
 说明：是传入节点和自身数据比较
 */
- (BOOL)isEqualPayTypeCell:(PayTypeNode*)node;
@end
