//
//  ZdywDBManager.m
//  ZdywDBManager
//
//  Created by mini1 on 14-5-12.
//  Copyright (c) 2014年 Guoling. All rights reserved.
//

#import "ZdywDBManager.h"
#import "SQL.h"

static ZdywDBManager *stat_dataBaseManager = nil;

@implementation ZdywDBManager
@synthesize userDBQueue = _userDBQueue;
@synthesize globalDBQueue = _globalDBQueue;

+ (ZdywDBManager *)shareInstance
{
    @synchronized(self)
    {
        if (nil == stat_dataBaseManager)
        {
            stat_dataBaseManager = [[ZdywDBManager alloc] init];
        }
        return stat_dataBaseManager;
    }
}

- (BOOL)createGloabDatabase:(NSString *)dbName
{
    @synchronized(self.globalDBQueue)
    {
        if (0 == [dbName length])
        {
            NSLog(@"数据库路径错误!");
            [self.globalDBQueue close];
            self.globalDBQueue = nil;
            return NO;
        }
        
        self.globalDBQueue = [FMDatabaseQueue databaseQueueWithPath:dbName];
        if (self.globalDBQueue)
        {
            __block BOOL flag = NO;
            [self.globalDBQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                NSArray *sqlList = [NSArray arrayWithObjects:
                                    kSQLSysMessageCreateTable,
                                    kSQLCreateTableCommonContact,
                                    kSQLActivityCreateTable,
                                    kSQLUserStatisticCreateTable,
                                    nil];
                for (NSString *sqlStr in sqlList)
                {
                    flag = [db executeUpdate:sqlStr];
                    if (!flag)
                    {
                        *rollback = YES;
                        break;
                    }
                }
            }];
            if (!flag)
            {
                NSLog(@"全局数据库创建表失败");
            }
            return flag;
        }
        else
        {
            NSLog(@"全局数据库创建失败");
        }
    }
    
    return NO;
}

- (BOOL)createUserDatabase:(NSString *)userID
{
    @synchronized(self.userDBQueue)
    {
        if (0 == [userID length])
        {
            NSLog(@"用户ID错误!");
            [self.userDBQueue close];
            self.userDBQueue = nil;
            return NO;
        }
        
        NSArray *aLis = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                            NSUserDomainMask, YES);
        if ([aLis count] > 0)
        {
            NSString *basePath = [aLis objectAtIndex:0];
            NSString *filePath = [basePath stringByAppendingPathComponent:userID];
            
            BOOL ret = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
            if (!ret)
            {
                ret = [[NSFileManager defaultManager] createDirectoryAtPath:filePath
                                                withIntermediateDirectories:YES
                                                                 attributes:NULL
                                                                      error:NULL];
            }
            
            if (ret)
            {
                NSString *dbName = [filePath stringByAppendingPathComponent:@"user.db"];
                self.userDBQueue = [FMDatabaseQueue databaseQueueWithPath:dbName];
                if (self.userDBQueue)
                {
                    __block BOOL flag = NO;
                    [self.userDBQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                        NSArray *sqlList = [NSArray arrayWithObjects:
                                            kSQLCreateTableCallRecord,
                                            kSQLUserRichMsgCreateTable,
                                            kSQLUserRichMsgContentCreateTable,
                                            nil];
                        for (NSString *sqlStr in sqlList)
                        {
                            flag = [db executeUpdate:sqlStr];
                            if (!flag)
                            {
                                *rollback = YES;
                                break;
                            }
                        }
                    }];
                    
                    if (!flag)
                    {
                        NSLog(@"用户数据库创建表失败");
                    }
                    
                    return flag;
                }
                else
                {
                    NSLog(@"用户数据库创建失败");
                }
            }
            else
            {
                NSLog(@"用户数据库目录创建失败");
            }
        }
    }
    
    return NO;
}

- (BOOL)updataGlobalDBWithSql:(NSString *)sql, ...
{
    @synchronized(self.globalDBQueue)
    {
        if (!self.globalDBQueue || 0 == [sql length])
        {
            return NO;
        }
        
        va_list args;
        va_start(args, sql);
        __block NSString *sqlStr = [self createSqlWithSqlStr:sql arguments:args];
        
        __block BOOL flag = NO;
        
        [self.globalDBQueue inDatabase:^(FMDatabase *db) {
            flag = [db executeUpdate:sqlStr];
        }];
        va_end(args);
        
        return flag;
    }
}

- (BOOL)transactionUpdataGlobalDBWithSqlArray:(NSArray *)sqlArray
{
    @synchronized(self.globalDBQueue)
    {
        if (!self.globalDBQueue || 0 == [sqlArray count])
        {
            return NO;
        }
        
        __block NSMutableArray *aList = [NSMutableArray arrayWithCapacity:2];
        [aList addObjectsFromArray:sqlArray];
        
        __block BOOL flag = NO;
        
        [self.globalDBQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for (NSString *sqlStr in aList)
            {
                flag = [db executeUpdate:sqlStr];
                if (!flag)
                {
                    *rollback = YES;
                    break;
                }
            }
        }];
        
        return flag;
    }
}

- (NSArray *)queryGlobalDBWithSql:(NSString *)sql, ...
{
    @synchronized(self.globalDBQueue)
    {
        if (!self.globalDBQueue || 0 == [sql length])
        {
            return nil;
        }
        
        va_list args;
        va_start(args, sql);
        __block NSString *sqlStr = [self createSqlWithSqlStr:sql arguments:args];
        
        __block NSMutableArray *aList = [[NSMutableArray alloc] initWithCapacity:2];
        
        [self.globalDBQueue inDatabase:^(FMDatabase *db) {
            FMResultSet *result = [db executeQuery:sqlStr];
            if (result)
            {
                while ([result next])
                {
                    NSMutableDictionary  *aDict = [[NSMutableDictionary alloc] initWithCapacity:2];
                    NSArray *keyList = [[result columnNameToIndexMap] allKeys];
                    for (NSString *aKey in keyList)
                    {
                        id obj = [result objectForColumnName:aKey];
                        [aDict setObject:obj forKey:aKey];
                    }
                    [aList addObject:aDict];
                }
                [result close];
            }
            
        }];
        va_end(args);
        
        return aList;
    }
}

- (BOOL)updataUserDBWithSql:(NSString *)sql, ...
{
    @synchronized(self.userDBQueue)
    {
        if (!self.userDBQueue || 0 == [sql length])
        {
            return NO;
        }
        
        va_list args;
        va_start(args, sql);
        __block NSString *sqlStr = [self createSqlWithSqlStr:sql arguments:args];
        
        __block BOOL flag = NO;
        
        [self.userDBQueue inDatabase:^(FMDatabase *db) {
            flag = [db executeUpdate:sqlStr];
        }];
        va_end(args);
        
        return flag;
    }
}

- (BOOL)transactionUpdataUserDBWithSqlArray:(NSArray *)sqlArray
{
    @synchronized(self.userDBQueue)
    {
        if (!self.userDBQueue || 0 == [sqlArray count])
        {
            return NO;
        }
        
        __block NSMutableArray *aList = [NSMutableArray arrayWithCapacity:2];
        [aList addObjectsFromArray:sqlArray];
        
        __block BOOL flag = NO;
        
        [self.userDBQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for (NSString *sqlStr in aList)
            {
                flag = [db executeUpdate:sqlStr];
                if (!flag)
                {
                    *rollback = YES;
                    break;
                }
            }
        }];
        
        return flag;
    }
}

- (NSArray *)queryUserDBWithSql:(NSString *)sql, ...
{
    @synchronized(self.userDBQueue)
    {
        if (!self.userDBQueue || 0 == [sql length])
        {
            return nil;
        }
        
        va_list args;
        va_start(args, sql);
        __block NSString *sqlStr = [self createSqlWithSqlStr:sql arguments:args];
        
        __block NSMutableArray *aList = [[NSMutableArray alloc] initWithCapacity:2];
        
        [self.userDBQueue inDatabase:^(FMDatabase *db) {
            FMResultSet *result = [db executeQuery:sqlStr];
            if (result)
            {
                while ([result next])
                {
                    NSMutableDictionary  *aDict = [[NSMutableDictionary alloc] initWithCapacity:2];
                    NSArray *keyList = [[result columnNameToIndexMap] allKeys];
                    for (NSString *aKey in keyList)
                    {
                        id obj = [result objectForColumnName:aKey];
                        [aDict setObject:obj forKey:aKey];
                    }
                    [aList addObject:aDict];
                }
                [result close];
            }
            
        }];
        va_end(args);
        
        return aList;
    }
}

- (NSString *)createSqlWithSqlStr:(NSString *)sqlStr arguments:(va_list)args
{
    if (0 == [sqlStr length])
    {
        return sqlStr;
    }
    
    NSMutableString *resultStr = [NSMutableString stringWithString:@""];
    NSInteger len = [sqlStr length];
    unichar last = '\0';
    
    for (int i = 0; i < len;)
    {
        unichar current = [sqlStr characterAtIndex:i];
        
        if (last == '%')
        {
            id add = nil;
            switch (current)
            {
                case '@':
                    add = [NSString stringWithFormat:@"%@",va_arg(args, id)];
                    break;
                case 'c':
                    add = [NSString stringWithFormat:@"%c", va_arg(args, int)];
                    break;
                case 'd':
                case 'D':
                case 'i':
                    add = [NSNumber numberWithInt:va_arg(args, int)];
                    break;
                case 'u':
                case 'U':
                    add = [NSNumber numberWithUnsignedInt:va_arg(args, unsigned int)];
                    break;
                case 'h':
                    i++;
                    if (i < len && [sqlStr characterAtIndex:i] == 'i')
                    {
                        //  warning: second argument to 'va_arg' is of promotable type 'short'; this va_arg has undefined behavior because arguments will be promoted to 'int'
                        add = [NSNumber numberWithShort:(short)(va_arg(args, int))];
                    }
                    else if (i < len && [sqlStr characterAtIndex:i] == 'u') {
                        // warning: second argument to 'va_arg' is of promotable type 'unsigned short'; this va_arg has undefined behavior because arguments will be promoted to 'int'
                        add = [NSNumber numberWithUnsignedShort:(unsigned short)(va_arg(args, uint))];
                    }
                    else
                    {
                        i--;
                    }
                    break;
                case 'q':
                    i++;
                    if (i < len && [sqlStr characterAtIndex:i] == 'i') {
                        add = [NSNumber numberWithLongLong:va_arg(args, long long)];
                    }
                    else if (i < len && [sqlStr characterAtIndex:i] == 'u') {
                        add = [NSNumber numberWithUnsignedLongLong:va_arg(args, unsigned long long)];
                    }
                    else {
                        i--;
                    }
                    break;
                case 'f':
                    add = [NSNumber numberWithDouble:va_arg(args, double)];
                    break;
                case 'g':
                    // warning: second argument to 'va_arg' is of promotable type 'float'; this va_arg has undefined behavior because arguments will be promoted to 'double'
                    add = [NSNumber numberWithFloat:(float)(va_arg(args, double))];
                    break;
                case 'l':
                    i++;
                    if (i < len) {
                        unichar next = [sqlStr characterAtIndex:i];
                        if (next == 'l') {
                            i++;
                            if (i < len && [sqlStr characterAtIndex:i] == 'd') {
                                //%lld
                                add = [NSNumber numberWithLongLong:va_arg(args, long long)];
                            }
                            else if (i < len && [sqlStr characterAtIndex:i] == 'u') {
                                //%llu
                                add = [NSNumber numberWithUnsignedLongLong:va_arg(args, unsigned long long)];
                            }
                            else {
                                i--;
                            }
                        }
                        else if (next == 'd') {
                            //%ld
                            add = [NSNumber numberWithLong:va_arg(args, long)];
                        }
                        else if (next == 'u') {
                            //%lu
                            add = [NSNumber numberWithUnsignedLong:va_arg(args, unsigned long)];
                        }
                        else {
                            i--;
                        }
                    }
                    else {
                        i--;
                    }
                    break;
                default:
                    // something else that we can't interpret. just pass it on through like normal
                    break;
            }
            
            if (add)
            {
                if ([add isKindOfClass:[NSNumber class]])
                {
                    [resultStr appendFormat:@"%@",add];
                }
                else
                {
                    [resultStr appendFormat:@"\"%@\"",add];
                }
            }
        }
        else if (current == '%')
        {
            
        }
        else if (current == '?')
        {
            id addStr = va_arg(args, id);
            if ([addStr isKindOfClass:[NSNumber class]])
            {
                [resultStr appendFormat:@"%@",addStr];
            }
            else
            {
                [resultStr appendFormat:@"\"%@\"",addStr];
            }
        }
        else
        {
            [resultStr appendFormat:@"%C",current];
        }
        
        last = current;
        ++i;
    }
    
    return resultStr;
}

@end
