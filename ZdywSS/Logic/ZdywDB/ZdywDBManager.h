//
//  ZdywDBManager.h
//  ZdywDBManager
//
//  Created by mini1 on 14-5-12.
//  Copyright (c) 2014年 Guoling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface ZdywDBManager : NSObject
{
    FMDatabaseQueue  *_userDBQueue;
    FMDatabaseQueue  *_globalDBQueue;
}

@property(nonatomic,strong) FMDatabaseQueue *userDBQueue;
@property(nonatomic,strong) FMDatabaseQueue *globalDBQueue;

+ (ZdywDBManager *)shareInstance;

/*********************************************************************
 函数名称 : createUserDatabase
 函数描述 : 创建用户数据库，生成所有的表
 参数 :
 userID : 用户ID
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL)createUserDatabase:(NSString *)userID;

/*********************************************************************
 函数名称 : createGloabDatabase
 函数描述 : 创建全局数据库，生成所有的表
 参数 :
 dbName : 数据库全路径名
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL)createGloabDatabase:(NSString *)dbName;

/*********************************************************************
 函数名称 : updataUserDBWithSql
 函数描述 : 执行创建、删除、新增、更新数据库操作
 参数 :
 sql : 数据库执行语句
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL)updataUserDBWithSql:(NSString *)sql, ...;

/*********************************************************************
 函数名称 : transactionUpdataUserDBWithSqlArray
 函数描述 : 执行多条创建、删除、新增、更新数据库操作
 参数 :
 sql : 数据库执行语句
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL)transactionUpdataUserDBWithSqlArray:(NSArray *)sqlArray;

/*********************************************************************
 函数名称 : queryUserDBWithSql
 函数描述 : 查询数据库返回结果集
 参数 :
 sql : 数据库执行语句
 返回值 : 查询结果集合
 作者 : 刘斌
 *********************************************************************/
- (NSArray *)queryUserDBWithSql:(NSString*)sql, ... ;

/*********************************************************************
 函数名称 : updataGlobalDBWithSql
 函数描述 : 执行创建、删除、新增、更新数据库操作
 参数 :
 sql : 数据库执行语句
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL)updataGlobalDBWithSql:(NSString *)sql, ...;

/*********************************************************************
 函数名称 : transactionUpdataGlobalDBWithSqlArray
 函数描述 : 执行多条创建、删除、新增、更新数据库操作
 参数 :
 sql : 数据库执行语句
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL)transactionUpdataGlobalDBWithSqlArray:(NSArray *)sqlArray;

/*********************************************************************
 函数名称 : queryGlobalDBWithSql
 函数描述 : 查询数据库返回结果集
 参数 :
 sql : 数据库执行语句
 返回值 : 查询结果集合
 作者 : 刘斌
 *********************************************************************/
- (NSArray *)queryGlobalDBWithSql:(NSString*)sql, ... ;

@end
