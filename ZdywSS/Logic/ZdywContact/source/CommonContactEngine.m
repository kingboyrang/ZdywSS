//
//  CommonContactEngine.m
//  ContactManager
//  常用联系人引擎
//  Created by mini1 on 13-6-7.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import "CommonContactEngine.h"
#import "ZdywDBManager.h"
#import "ContactType.h"
#import "SQL.h"

@implementation CommonContactEngine

/*
 函数描述：添加常用联系人
 输入参数：contactID    联系人ID
 输出参数：N/A
 返 回 值：BOOL   成功与否
 作    者：刘斌
 */
- (BOOL)addCommonContact:(NSInteger)contactID
{
    if (kInValidContactID == contactID)
    {
        return NO;
    }
    
    //    return [[FMDataBaseManager shareInstance] updataUserDatabaseWithSql:kSQLInsertTableCommonContact,
    //            [NSNumber numberWithInt:contactID]];
    BOOL ret = NO;
    @synchronized([ZdywDBManager shareInstance].globalDBQueue)
    {
        FMDatabaseQueue *dbHandle = [ZdywDBManager shareInstance].globalDBQueue;
        if (nil != dbHandle)
        {
            ret = [[ZdywDBManager shareInstance] updataGlobalDBWithSql:kSQLInsertTableCommonContact,
                   [NSNumber numberWithInt:contactID]];
        }
    }
    return ret;
}

/*
 函数描述：移除常用联系人
 输入参数：contactID    联系人ID
 输出参数：N/A
 返 回 值：BOOL   成功与否
 作    者：刘斌
 */
- (BOOL)removeCommonContact:(NSInteger)contactID
{
    if (kInValidContactID == contactID)
    {
        return NO;
    }
    
    //    BOOL ret = [[FMDataBaseManager shareInstance] updataUserDatabaseWithSql:kSQLDeleteCommonContact,
    //                [NSNumber numberWithInt:contactID]];
    //
    //    return ret;
    
    BOOL ret = NO;
    @synchronized([ZdywDBManager shareInstance].globalDBQueue)
    {
        FMDatabaseQueue *dbHandle = [ZdywDBManager shareInstance].globalDBQueue;
        if (nil != dbHandle)
        {
            ret = [[ZdywDBManager shareInstance] updataGlobalDBWithSql:kSQLDeleteCommonContact,
                   [NSNumber numberWithInt:contactID]];
        }
    }
    
    
    return ret;
}

/*
 函数描述：所有常有联系人ID
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSArray   结果
 作    者：刘斌
 */
- (NSArray *)commonContactList
{
    NSMutableArray *aList = [NSMutableArray arrayWithCapacity:2];
    
//    FMResultSet *result = [[FMDataBaseManager shareInstance] queryUserDatabaseWithSql:kSQLQueryAllCommonContact];
//    if (nil != result)
//    {
//        while ([result next])
//        {
//            int contactID = [result intForColumn:@"contactID"];
//            [aList addObject:[NSNumber numberWithInt:contactID]];
//        }
//    }
//    [result close];
//    
//    [[FMDataBaseManager shareInstance] closeUserDatabase];
    
    @synchronized([ZdywDBManager shareInstance].globalDBQueue)
    {
        FMDatabaseQueue *dbHandle = [ZdywDBManager shareInstance].globalDBQueue;
        if (nil != dbHandle)
        {
                NSArray *result = [[ZdywDBManager shareInstance] queryGlobalDBWithSql:kSQLQueryAllCommonContact];
            [aList addObjectsFromArray:result];
        }
    }
    return aList;
}

@end
