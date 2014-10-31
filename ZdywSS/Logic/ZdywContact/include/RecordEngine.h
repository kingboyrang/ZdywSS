//
//  RecordEngine.h
//  ContactManager
//  通话记录管理
//  Created by mini1 on 13-6-7.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactRecordNode.h"
#import "ZdywDBManager.h"

@interface RecordEngine : NSObject

/*
 函数描述：插入通话记录
 输入参数：oneRecord    通话记录信息
 输出参数：N/A
 返 回 值：BOOL   成功与否
 作    者：刘斌
 */
- (BOOL)insertOneRecord:(ContactRecordNode *)oneRecord;

/*
 函数描述：获取所有的通话记录
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSArray   通话记录列表
 作    者：刘斌
 */
- (NSArray *)allRecord;

/*
 函数描述：删除一条通话记录
 输入参数：recordID   通话记录ID
 输出参数：N/A
 返 回 值：BOOL   成功与否
 作    者：刘斌
 */
- (BOOL)deleteOneRecord:(NSInteger)recordID;

/*
 函数描述：批量删除通话记录
 输入参数：recordIDList   待删除的通话记录ID列表
 输出参数：N/A
 返 回 值：BOOL   成功与否
 作    者：刘斌
 */
- (BOOL)deleteRecords:(NSArray *)recordIDList;

/*
 函数描述：删除所有的通话记录
 输入参数：N/A
 输出参数：N/A
 返 回 值：BOOL   成功与否
 作    者：刘斌
 */
- (BOOL)deleteAllRecord;

@end
