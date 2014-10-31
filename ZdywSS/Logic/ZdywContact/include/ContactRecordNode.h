//
//  ContactRecordNode.h
//  ContactManager
//  单条通话记录，用来存放单条通话记录的信息
//  Created by mini1 on 13-6-5.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactRecordNode : NSObject

@property(nonatomic,assign) NSInteger      recordID;
@property(nonatomic,assign) NSInteger      contactID;
@property(nonatomic,retain) NSString       *phoneNum;
@property(nonatomic,assign) NSInteger      recordTotalTime;     //通话时长
@property(nonatomic,retain) NSString       *recordDateString;    //通话时间
@property(nonatomic,assign) NSInteger      recordType;           //通话类型

- (void)dateStringFromDate:(NSDate *)aDate;

- (id)initWithDictionary:(NSDictionary*)dic;

@end
