//
//  ContactRecordNode.m
//  ContactManager
//
//  Created by mini1 on 13-6-5.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import "ContactRecordNode.h"
#import "ContactType.h"

@implementation ContactRecordNode

@synthesize recordID;
@synthesize contactID;
@synthesize phoneNum;
@synthesize recordTotalTime;     //通话时长
@synthesize recordDateString;    //通话时间
@synthesize recordType;           //通话类型

- (id)init
{
    self = [super init];
    if (self)
    {
        self.recordID = kInValidContactID;
        self.contactID = kInValidContactID;
        self.phoneNum = @"";
        self.recordTotalTime = 0;
        self.recordDateString = @"";
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        id recordId = [dic objectForKey:@"recordid"];
        if (recordId && ![recordId isKindOfClass:[NSNull class]]) {
            self.recordID = [recordId integerValue];
        }
        id contactId = [dic objectForKey:@"contactid"];
        if (contactId && ![contactId isKindOfClass:[NSNull class]]) {
            self.contactID = [contactId integerValue];
        }
        id phonenum = [dic objectForKey:@"phonenumber"];
        if (phonenum && ![phonenum isKindOfClass:[NSNull class]]) {
            self.phoneNum = phonenum;
        }
        id calltype = [dic objectForKey:@"calltype"];
        if (calltype && ![calltype isKindOfClass:[NSNull class]]) {
            self.recordType = [calltype integerValue];
        }
        id calldate = [dic objectForKey:@"calldate"];
        if (calldate && ![calldate isKindOfClass:[NSNull class]]) {
            self.recordDateString = calldate;
        }
        id duration = [dic objectForKey:@"duration"];
        if (duration && ![duration isKindOfClass:[NSNull class]]) {
            self.recordTotalTime = [duration integerValue];
        }
    }
    return self;
}

- (void)dateStringFromDate:(NSDate *)aDate
{
    if (nil == aDate)
    {
        return;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kContactRecordTimeFormatter];
    self.recordDateString = [formatter stringFromDate:aDate];
}

@end
