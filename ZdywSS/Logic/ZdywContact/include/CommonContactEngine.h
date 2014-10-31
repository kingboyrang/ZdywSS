//
//  CommonContactEngine.h
//  ContactManager
//  常用联系人引擎
//  Created by mini1 on 13-6-7.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonContactEngine : NSObject

/*
 函数描述：添加常用联系人
 输入参数：contactID    联系人ID
 输出参数：N/A
 返 回 值：BOOL   成功与否
 作    者：刘斌
 */
- (BOOL)addCommonContact:(NSInteger)contactID;

/*
 函数描述：移除常用联系人
 输入参数：contactID    联系人ID
 输出参数：N/A
 返 回 值：BOOL   成功与否
 作    者：刘斌
 */
- (BOOL)removeCommonContact:(NSInteger)contactID;

/*
 函数描述：所有常有联系人ID
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSArray   结果
 作    者：刘斌
 */
- (NSArray *)commonContactList;

@end
