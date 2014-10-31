//
//  RecordMegerNode.h
//  ContactManager
//  相同联系人通话记录集合，用来存放同一联系人或号码的通话记录
//  Created by mini1 on 13-6-5.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordMegerDetailNode : NSObject

@property(nonatomic,retain) NSString       *phoneNumber;           //通话号码
@property(nonatomic,retain) NSMutableArray *recordList;            //通话记录列表

@end

@interface RecordMegerNode : NSObject

@property(nonatomic,assign) NSInteger       contactID;
@property(nonatomic,retain) NSString        *phoneNumber;
@property(nonatomic,retain) NSString        *contactName;           //通话者姓名
@property(nonatomic,retain) NSString        *lastDateString;        //最后通话时间
@property(nonatomic,assign) float           totalTime;              //累计通话时间
@property(nonatomic,assign) NSInteger       maxTime;                //最长通话时间
@property(nonatomic,assign) NSInteger       minTime;                //最短通话时间
@property(nonatomic,assign) NSInteger       lastTime;               //最后一次通话时间

@property(nonatomic,retain) NSMutableDictionary   *recordInfoDict;  //通话详情
@property(nonatomic,retain) NSMutableArray  *lastRecordList;        //最近的通话记录列表

/*
 函数描述：排序比较
 输入参数：otherMegerRecord  其他记录
 输出参数：N/A
 返 回 值：int       比较结果
 作    者：刘斌
 */
- (int)compareWithOther:(RecordMegerNode *)otherMegerRecord;

@end
