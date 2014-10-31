//
//  CallInfoNode.h
//  WldhClient
//
//  Created by zhouww on 13-8-3.
//  Copyright (c) 2013年 guoling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CallInfoNode : NSObject
{
    NSString                    *_calleePhone;      //被叫号码
    NSString                    *_calleeName;       //被叫姓名
    int                         _calleeRecordID;    //被叫在通讯录中的id
    
    ZdywCallType                _callType;          //呼叫方式
}

@property(nonatomic, copy)NSString *calleePhone;
@property(nonatomic, copy)NSString *calleeName;
@property(nonatomic, assign)int calleeRecordID;

@property(nonatomic, assign)ZdywCallType calltype;

@end
