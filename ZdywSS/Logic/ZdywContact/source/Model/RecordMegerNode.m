//
//  RecordMegerNode.m
//  ContactManager
//
//  Created by mini1 on 13-6-5.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import "RecordMegerNode.h"
#import "ContactType.h"

@implementation RecordMegerDetailNode

@synthesize phoneNumber;           //通话号码
@synthesize recordList;            //通话记录列表

- (id)init
{
    self = [super init];
    if (self)
    {
        self.phoneNumber = @"";
        self.recordList = [NSMutableArray arrayWithCapacity:2];
    }
    return self;
}

@end

@implementation RecordMegerNode

@synthesize contactID;
@synthesize phoneNumber;
@synthesize contactName;           //通话者姓名
@synthesize lastDateString;        //最后通话时间
@synthesize totalTime;              //累计通话时间
@synthesize maxTime;                //最长通话时间
@synthesize minTime;                //最短通话时间
@synthesize lastTime;               //最后一次通话时间

@synthesize recordInfoDict;  //通话详情
@synthesize lastRecordList;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.contactID = kInValidContactID;
        self.phoneNumber = @"";
        self.contactName = @"";
        self.lastDateString = @"";
        self.totalTime = 0;
        self.maxTime = 0;
        self.minTime = 0;
        self.lastTime = 0;
        
        self.recordInfoDict = [NSMutableDictionary dictionaryWithCapacity:2];
        self.lastRecordList = [NSMutableArray arrayWithCapacity:2];
    }
    
    return self;
}

/*
 函数描述：排序比较
 输入参数：otherMegerRecord  其他记录
 输出参数：N/A
 返 回 值：int       比较结果
 作    者：刘斌
 */
- (int)compareWithOther:(RecordMegerNode *)otherMegerRecord
{
    if ([otherMegerRecord.lastDateString length] == 0)
    {
        return 1;
    }
    else if([self.lastDateString length] == 0)
    {
        return -1;
    }
    else
    {
        return [self.lastDateString compare:otherMegerRecord.lastDateString];
    }
}

@end
