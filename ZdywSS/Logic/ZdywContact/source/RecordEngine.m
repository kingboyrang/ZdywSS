//
//  RecordEngine.m
//  ContactManager
//  通话记录管理
//  Created by mini1 on 13-6-7.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import "RecordEngine.h"
#import "SQL.h"
#import "ZdywDBManager.h"

@implementation RecordEngine

/*
 函数描述：插入通话记录
 输入参数：oneRecord    通话记录信息
 输出参数：N/A
 返 回 值：BOOL   成功与否
 作    者：刘斌
 */
- (BOOL)insertOneRecord:(ContactRecordNode *)oneRecord
{
    if (nil == oneRecord)
    {
        return NO;
    }
    
    return [[ZdywDBManager shareInstance] updataUserDBWithSql:kSQLInsertCallRecord,
            [NSNumber numberWithInt:oneRecord.contactID],
            oneRecord.phoneNum,
            [NSNumber numberWithInt:oneRecord.recordTotalTime],
            oneRecord.recordDateString,
            [NSNumber numberWithInt:oneRecord.recordType]];
}

/*
 函数描述：获取所有的通话记录
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSArray   通话记录列表
 作    者：刘斌
 */
- (NSArray *)allRecord
{
    NSArray *result = [[ZdywDBManager shareInstance] queryUserDBWithSql:kSQLQueryAllCallRecord];
    return result;
}

/*
 函数描述：删除一条通话记录
 输入参数：recordID   通话记录ID
 输出参数：N/A
 返 回 值：BOOL   成功与否
 作    者：刘斌
 */
- (BOOL)deleteOneRecord:(NSInteger)recordID
{
    if (recordID >= 0)
    {
        return [[ZdywDBManager shareInstance] updataUserDBWithSql:kSQLDeleteOneCallRecord,recordID];
    }
    
    return NO;
}

/*
 函数描述：批量删除通话记录
 输入参数：recordIDList   待删除的通话记录ID列表
 输出参数：N/A
 返 回 值：BOOL   成功与否
 作    者：刘斌
 */
- (BOOL)deleteRecords:(NSArray *)recordIDList
{
    if (0 == [recordIDList count])
    {
        return NO;
    }
    
    NSMutableArray *sqlList = [NSMutableArray arrayWithCapacity:2];
    for (NSNumber *recordIDNum in recordIDList)
    {
        [sqlList addObject:kSQLDeleteCallRecordMulity([recordIDNum intValue])];
    }
    
    return [[ZdywDBManager shareInstance] transactionUpdataUserDBWithSqlArray:sqlList];
}

/*
 函数描述：删除所有的通话记录
 输入参数：N/A
 输出参数：N/A
 返 回 值：BOOL   成功与否
 作    者：刘斌
 */
- (BOOL)deleteAllRecord
{
    return [[ZdywDBManager shareInstance] updataUserDBWithSql:kSQLDeleteAllCallRecord];
}

@end
