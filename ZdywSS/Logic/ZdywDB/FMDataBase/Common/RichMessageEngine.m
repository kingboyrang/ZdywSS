//
//  RichMessageEngine.m
//  ZdywDBManager
//
//  Created by mini1 on 14-4-15.
//  Copyright (c) 2014年 dyn. All rights reserved.
//

#import "RichMessageEngine.h"
#import "ZdywDBManager.h"
#import "SQL.h"

@implementation RichMessageObj

@synthesize rmId;
@synthesize msgId;
@synthesize msgType;
@synthesize msgTypeName;
@synthesize msgStyle;
@synthesize effectTime;
@synthesize topFlag;
@synthesize msgTime;

@synthesize msgContentList;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.msgType = @"";
        self.msgTypeName = @"";
        self.effectTime = @"";
        self.msgContentList = [NSMutableArray arrayWithCapacity:2];
    }
    return self;
}

- (NSString *)createValues
{
    NSMutableString *cValueStr = [NSMutableString stringWithString:@""];
    [cValueStr appendString:@"("];
    [cValueStr appendFormat:@"%d,",self.msgId];
    [cValueStr appendFormat:@"\"%@\",",self.msgType];
    [cValueStr appendFormat:@"\"%@\",",self.msgTypeName];
    [cValueStr appendFormat:@"%d,",self.msgStyle];
    [cValueStr appendFormat:@"\"%@\",",self.effectTime];
    [cValueStr appendFormat:@"%d,",self.topFlag];
    [cValueStr appendFormat:@"\"%@\")",self.msgTime];
    return cValueStr;
}

- (void)createDataWithDict:(NSDictionary *)dict
{
    self.msgId = [[dict objectForKey:@"msg_id"] integerValue];
    self.msgType = [dict objectForKey:@"rn_type"];
    self.msgTypeName = [dict objectForKey:@"rn_type_name"];
    self.msgStyle = [[dict objectForKey:@"rn_style"] integerValue];
    self.effectTime = [dict objectForKey:@"effect_time"];
    self.topFlag = [[dict objectForKey:@"top"] integerValue];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.msgTime = [formatter stringFromDate:[NSDate date]];
    
    NSArray *cList = [dict objectForKey:@"list"];
    for (NSInteger i = [cList count] - 1; i >=0; --i)
    {
        NSDictionary *cDict = [cList objectAtIndex:i];
        RichContentObj *oneContent = [[RichContentObj alloc] init];
        [oneContent createDataWithDict:cDict];
        oneContent.msgId = self.msgId;
        [self.msgContentList addObject:oneContent];
    }
    
    if (!self.msgType)
    {
        self.msgType = @"";
    }
    if (!self.msgTypeName)
    {
        self.msgTypeName = @"";
    }
    if (!self.effectTime)
    {
        self.effectTime = @"";
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"id:%d,msgId:%d,msgType:%@,msgTypeName:%@,msgStyle:%d,effectTime:%@,topFlag:%d,msgTime:%@,msgContent:%d",
            self.rmId,
            self.msgId,
            self.msgType,
            self.msgTypeName,
            self.msgStyle,
            self.effectTime,
            self.topFlag,
            self.msgTime,
            [self.msgContentList count]];
}

@end

@implementation RichContentObj

@synthesize rcId;
@synthesize msgId;
@synthesize msgTitle;
@synthesize summary;
@synthesize imgUrl;
@synthesize jumpType;
@synthesize jumpBtnTitle;
@synthesize jumpUrl;
@synthesize imgIndex;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.msgTitle = @"";
        self.summary = @"";
        self.imgUrl = @"";
        self.jumpUrl = @"";
        self.jumpType = @"";
        self.jumpBtnTitle = @"";
    }
    return self;
}

- (NSString *)createValues
{
    NSMutableString *cValueStr = [NSMutableString stringWithString:@""];
    [cValueStr appendString:@"("];
    [cValueStr appendFormat:@"%d,",self.msgId];
    [cValueStr appendFormat:@"\"%@\",",self.msgTitle];
    [cValueStr appendFormat:@"\"%@\",",self.summary];
    [cValueStr appendFormat:@"\"%@\",",self.imgUrl];
    [cValueStr appendFormat:@"\"%@\",",self.jumpType];
    [cValueStr appendFormat:@"\"%@\",",self.jumpBtnTitle];
    [cValueStr appendFormat:@"\"%@\",",self.jumpUrl];
    [cValueStr appendFormat:@"%d)",self.imgIndex];
    return cValueStr;
}

- (void)createDataWithDict:(NSDictionary *)dict
{
    self.imgIndex = [[dict objectForKey:@"index"] integerValue];
    self.jumpType = [dict objectForKey:@"jump_type"];
    self.imgUrl = [dict objectForKey:@"img"];
    self.msgTitle = [dict objectForKey:@"title"];
    self.jumpUrl = [dict objectForKey:@"url"];
    self.summary = [dict objectForKey:@"summary"];
    self.jumpBtnTitle = [dict objectForKey:@"jump_btn_title"];
    
    if (!self.jumpBtnTitle)
    {
        self.jumpBtnTitle = @"";
    }
    if (!self.jumpType)
    {
        self.jumpType = @"";
    }
    if (!self.jumpUrl)
    {
        self.jumpUrl = @"";
    }
    if (!self.msgTitle)
    {
        self.msgTitle = @"";
    }
    if (!self.summary)
    {
        self.summary = @"";
    }
    if (!self.imgUrl)
    {
        self.imgUrl = @"";
    }
}

@end

@implementation RichMessageEngine

+ (NSInteger)updateRichMessage:(NSArray *)msgList groupIsChanged:(BOOL)isChanged
{
    NSInteger maxSortId = 0;
    BOOL hasTopMsg = NO;
    NSMutableArray *aList = [NSMutableArray arrayWithCapacity:[msgList count]];
    if ([msgList count] > 0)
    {
        for (NSInteger i = 0; i < [msgList count]; ++i)
        {
            NSDictionary *aDict = [msgList objectAtIndex:i];
            RichMessageObj *oneMsg = [[RichMessageObj alloc] init];
            [oneMsg createDataWithDict:aDict];
            
            //对服务端的数据要做一个逆序操作
            //服务端的把最新消息放在第一位，我们需要保证消息在数据库的最后面
            [aList insertObject:oneMsg atIndex:0];
            
            if (oneMsg.topFlag != 0)
            {
                hasTopMsg = YES;
            }
            
            NSInteger sId = [[aDict objectForKey:@"sort_id"] integerValue];
            if (sId > maxSortId)
            {
                maxSortId = sId;
            }
        }
        
    }
    
    BOOL ret = YES;
    if (isChanged)
    {
        ret = [RichMessageEngine deleteAllRichMessage];
        NSLog(@"删除旧的富媒体消息%@",ret ? @"成功" : @"失败");
    }
    
    if (ret)
    {
        if (hasTopMsg && !isChanged)
        {
            ret = [RichMessageEngine dropTopRichMessage];
            NSLog(@"修改旧的富媒体置顶消息%@",ret ? @"成功" : @"失败");
        }
    }
    
    if (ret && [aList count] > 0)
    {
        ret = [RichMessageEngine insertRichMessages:aList];
        NSLog(@"插入新的富媒体消息%@",ret ? @"成功" : @"失败");
    }
    
    if (ret)
    {
        return maxSortId;
    }
    
    return -1;
}

+ (BOOL)insertRichMessage:(RichMessageObj *)msgObj
{
    if (!msgObj)
    {
        return NO;
    }
    
    ZdywDBManager *fmManager = [ZdywDBManager shareInstance];
    @synchronized(fmManager.userDBQueue)
    {
        if (nil == fmManager.userDBQueue)
        {
            return NO;
        }
        
        __block RichMessageObj *blockMsgObj = msgObj;
        __block BOOL ret = NO;
        [fmManager.userDBQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            
            ret = YES;
            
            for (RichContentObj *oneContent in blockMsgObj.msgContentList)
            {
                NSString *cVStr = [NSString stringWithFormat:@"%@;",[oneContent createValues]];
                ret = [db executeUpdate:kSQLRichContentInsert(cVStr)];
                if (!ret)
                {
                    break;
                }
            }
            
            if (ret)
            {
                NSString *mValueStr = [NSString stringWithFormat:@"%@;",[blockMsgObj createValues]];
                ret = [db executeUpdate:kSQLRichMsgInsert(mValueStr)];
            }
            
            *rollback = !ret;
        }];
        
        return ret;
    }
}

+ (BOOL)insertRichMessages:(NSArray *)msgObjList
{
    if (0 == [msgObjList count])
    {
        return NO;
    }
    
    ZdywDBManager *fmManager = [ZdywDBManager shareInstance];
    @synchronized(fmManager.userDBQueue)
    {
        if (nil == fmManager.userDBQueue)
        {
            return NO;
        }
        
        __block BOOL ret = NO;
        __block NSMutableArray  *sqlList = [NSMutableArray arrayWithCapacity:2];
        [sqlList addObjectsFromArray:msgObjList];
        
        [fmManager.userDBQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            
            ret = YES;
            
            for (RichMessageObj *oneMsgObj in sqlList)
            {
                for (RichContentObj *oneContent in oneMsgObj.msgContentList)
                {
                    NSString *cVStr = [NSString stringWithFormat:@"%@;",[oneContent createValues]];
                    ret = [db executeUpdate:kSQLRichContentInsert(cVStr)];
                    if (!ret)
                    {
                        break;
                    }
                }
                
                if (ret)
                {
                    NSString *mVStr = [NSString stringWithFormat:@"%@;",[oneMsgObj createValues]];
                    ret = [db executeUpdate:kSQLRichMsgInsert(mVStr)];
                    if (!ret)
                    {
                        break;
                    }
                }
                else
                {
                    break;
                }
            }
            
            *rollback = !ret;
        }];
        
        return ret;
    }
}

+ (NSArray *)richMessagesWithPage:(NSInteger)pageIndex pageSize:(NSInteger)pSize
{
    ZdywDBManager *fmManager = [ZdywDBManager shareInstance];
    
    NSMutableArray *aList = [NSMutableArray arrayWithCapacity:pSize];
    
    NSArray *result = [fmManager queryUserDBWithSql:kSQLRichMsgQueryByPage,
                           [NSNumber numberWithInteger:pageIndex * pSize],
                           [NSNumber numberWithInteger:pSize]];
    
    for (NSDictionary *aDict in result)
    {
        RichMessageObj *oneMsgObj = [[RichMessageObj alloc] init];
        oneMsgObj.rmId = [[aDict objectForKey:@"rmgid"] integerValue];
        oneMsgObj.msgId = [[aDict objectForKey:@"msgid"] integerValue];
        oneMsgObj.msgType = [aDict objectForKey:@"msgtype"];
        oneMsgObj.msgTypeName = [aDict objectForKey:@"msgtypename"];
        oneMsgObj.msgStyle = [[aDict objectForKey:@"msgstyle"] integerValue];
        oneMsgObj.effectTime = [aDict objectForKey:@"effecttime"];
        oneMsgObj.topFlag = [[aDict objectForKey:@"topflag"] integerValue];
        oneMsgObj.msgTime = [aDict objectForKey:@"msgtime"];
        
        NSArray *contentResult = [fmManager queryUserDBWithSql:kSQLRichContentQueryForMsgId,
                                      [NSNumber numberWithInteger:oneMsgObj.msgId]];
        for (NSDictionary *contentDict in contentResult)
        {
            RichContentObj *oneContent = [[RichContentObj alloc] init];
            oneContent.rcId = [[contentDict objectForKey:@"rmcid"] integerValue];
            oneContent.msgId = [[contentDict objectForKey:@"msgid"] integerValue];
            oneContent.msgTitle = [contentDict objectForKey:@"msgtitle"];
            oneContent.summary = [contentDict objectForKey:@"summary"];
            oneContent.imgUrl = [contentDict objectForKey:@"imgurl"];
            oneContent.jumpType = [contentDict objectForKey:@"jumptype"];
            oneContent.jumpBtnTitle = [contentDict objectForKey:@"jumpbtntitle"];
            oneContent.jumpUrl = [contentDict objectForKey:@"jumpurl"];
            oneContent.imgIndex = [[contentDict objectForKey:@"imgindex"] integerValue];
            
            [oneMsgObj.msgContentList addObject:oneContent];
        }
        
        [aList addObject:oneMsgObj];
    }
    
    return aList;
}

+ (RichMessageObj *)richMessageWithMsgId:(NSInteger)msgId
{
    ZdywDBManager *fmManager = [ZdywDBManager shareInstance];
    
    RichMessageObj *oneMsgObj = nil;
    
    NSArray *result = [fmManager queryUserDBWithSql:kSQLRichMsgQueryOne,
                           [NSNumber numberWithInteger:msgId]];
    if ([result count] > 0)
    {
        NSDictionary *aDict = [result objectAtIndex:0];
        
        oneMsgObj = [[RichMessageObj alloc] init];
        oneMsgObj.rmId = [[aDict objectForKey:@"rmgid"] integerValue];
        oneMsgObj.msgId = [[aDict objectForKey:@"msgid"] integerValue];
        oneMsgObj.msgType = [aDict objectForKey:@"msgtype"];
        oneMsgObj.msgTypeName = [aDict objectForKey:@"msgtypename"];
        oneMsgObj.msgStyle = [[aDict objectForKey:@"msgstyle"] integerValue];
        oneMsgObj.effectTime = [aDict objectForKey:@"effecttime"];
        oneMsgObj.topFlag = [[aDict objectForKey:@"topflag"] integerValue];
        oneMsgObj.msgTime = [aDict objectForKey:@"msgtime"];
        
        NSArray *contentResult = [fmManager queryUserDBWithSql:kSQLRichContentQueryForMsgId,
                                  [NSNumber numberWithInteger:oneMsgObj.msgId]];
        for (NSDictionary *contentDict in contentResult)
        {
            RichContentObj *oneContent = [[RichContentObj alloc] init];
            oneContent.rcId = [[contentDict objectForKey:@"rmcid"] integerValue];
            oneContent.msgId = [[contentDict objectForKey:@"msgid"] integerValue];
            oneContent.msgTitle = [contentDict objectForKey:@"msgtitle"];
            oneContent.summary = [contentDict objectForKey:@"summary"];
            oneContent.imgUrl = [contentDict objectForKey:@"imgurl"];
            oneContent.jumpType = [contentDict objectForKey:@"jumptype"];
            oneContent.jumpBtnTitle = [contentDict objectForKey:@"jumpbtntitle"];
            oneContent.jumpUrl = [contentDict objectForKey:@"jumpurl"];
            oneContent.imgIndex = [[contentDict objectForKey:@"imgindex"] integerValue];
            
            [oneMsgObj.msgContentList addObject:oneContent];
        }
    }
    
    return oneMsgObj;
}

+ (NSArray *)richContentsWithMsgId:(NSInteger)msgId
{
    ZdywDBManager *fmManager = [ZdywDBManager shareInstance];
    
    NSMutableArray *aList = [NSMutableArray arrayWithCapacity:2];
    
    NSArray *contentResult = [fmManager queryUserDBWithSql:kSQLRichContentQueryForMsgId,
                                  [NSNumber numberWithInteger:msgId]];
    for (NSDictionary *contentDict in contentResult)
    {
        RichContentObj *oneContent = [[RichContentObj alloc] init];
        oneContent.rcId = [[contentDict objectForKey:@"rmcid"] integerValue];
        oneContent.msgId = [[contentDict objectForKey:@"msgid"] integerValue];
        oneContent.msgTitle = [contentDict objectForKey:@"msgtitle"];
        oneContent.summary = [contentDict objectForKey:@"summary"];
        oneContent.imgUrl = [contentDict objectForKey:@"imgurl"];
        oneContent.jumpType = [contentDict objectForKey:@"jumptype"];
        oneContent.jumpBtnTitle = [contentDict objectForKey:@"jumpbtntitle"];
        oneContent.jumpUrl = [contentDict objectForKey:@"jumpurl"];
        oneContent.imgIndex = [[contentDict objectForKey:@"imgindex"] integerValue];
        
        [aList addObject:oneContent];
    }
    
    return aList;
}

+ (RichContentObj *)richContentWithMsgId:(NSInteger)msgId msgIndex:(NSInteger)msgIndex
{
    ZdywDBManager *fmManager = [ZdywDBManager shareInstance];
    
    RichContentObj *oneContent = nil;
    
    NSArray *contentResult = [fmManager queryUserDBWithSql:kSQLRichContentQueryOne,
                                  [NSNumber numberWithInteger:msgId],
                                  [NSNumber numberWithInteger:msgIndex]];
    if ([contentResult count] > 0)
    {
        NSDictionary *contentDict = [contentResult objectAtIndex:0];
        
        oneContent = [[RichContentObj alloc] init];
        oneContent.rcId = [[contentDict objectForKey:@"rmcid"] integerValue];
        oneContent.msgId = [[contentDict objectForKey:@"msgid"] integerValue];
        oneContent.msgTitle = [contentDict objectForKey:@"msgtitle"];
        oneContent.summary = [contentDict objectForKey:@"summary"];
        oneContent.imgUrl = [contentDict objectForKey:@"imgurl"];
        oneContent.jumpType = [contentDict objectForKey:@"jumptype"];
        oneContent.jumpBtnTitle = [contentDict objectForKey:@"jumpbtntitle"];
        oneContent.jumpUrl = [contentDict objectForKey:@"jumpurl"];
        oneContent.imgIndex = [[contentDict objectForKey:@"imgindex"] integerValue];
    }
    
    return oneContent;
}

+ (BOOL)dropTopRichMessage
{
    ZdywDBManager *fmManager = [ZdywDBManager shareInstance];
    return [fmManager updataUserDBWithSql:kSQLRichMsgUpdateTop];
}

+ (BOOL)deleteAllRichMessage
{
    ZdywDBManager *fmManager = [ZdywDBManager shareInstance];
    @synchronized(fmManager.userDBQueue)
    {
        if (nil == fmManager.userDBQueue)
        {
            return NO;
        }
        
        __block BOOL ret = NO;
        [fmManager.userDBQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            
            ret = [db executeUpdate:kSQLRichContentDeleteAll];
            if (ret)
            {
                ret = [db executeUpdate:kSQLRichMsgDeleteAll];
            }
            
            *rollback = !ret;
        }];
        
        return ret;
    }
}

+ (BOOL)deleteRichMessageWithMsgId:(NSInteger)msgId
{
    ZdywDBManager *fmManager = [ZdywDBManager shareInstance];
    @synchronized(fmManager.userDBQueue)
    {
        if (nil == fmManager.userDBQueue)
        {
            return NO;
        }
        
        __block BOOL ret = NO;
        __block NSInteger blockMsgId = msgId;
        
        [fmManager.userDBQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            
            //删除所有的消息内容
            ret = [db executeUpdate:kSQLRichContentDeleteMsg,[NSNumber numberWithInteger:blockMsgId]];
            if (ret)
            {
                ret = [db executeUpdate:kSQLRichMsgDeleteOne,[NSNumber numberWithInteger:blockMsgId]];
            }
            
            *rollback = !ret;
        }];
        
        return ret;
    }
}

+ (BOOL)deleteAllRichContent
{
    ZdywDBManager *fmManager = [ZdywDBManager shareInstance];
    return [fmManager updataUserDBWithSql:kSQLRichContentDeleteAll];
}

+ (BOOL)deleteRichContentWithMsgId:(NSInteger)msgId
{
    ZdywDBManager *fmManager = [ZdywDBManager shareInstance];
    return [fmManager updataUserDBWithSql:kSQLRichContentDeleteMsg,
            [NSNumber numberWithInteger:msgId]];
}

+ (BOOL)deleteRichContentWithMsgId:(NSInteger)msgId msgIndex:(NSInteger)msgIndex
{
    ZdywDBManager *fmManager = [ZdywDBManager shareInstance];
    return [fmManager updataUserDBWithSql:kSQLRichContentDeleteOne,
            [NSNumber numberWithInteger:msgId],
            [NSNumber numberWithInteger:msgIndex]];
}

+ (NSInteger)msgCount
{
    ZdywDBManager *fmManager = [ZdywDBManager shareInstance];
    NSInteger count = 0;
    
    NSArray *result = [fmManager queryUserDBWithSql:kSQLRichMsgQueryCount];
    if ([result count] > 0)
    {
        NSDictionary *aDict = [result objectAtIndex:0];
        if ([aDict count] > 0)
        {
            count = [[[aDict allValues] objectAtIndex:0] integerValue];
        }
    }
    
    return count;
}

@end
