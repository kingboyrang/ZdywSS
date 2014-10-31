//
//  SysMessageObj.h
//  ZdywClient
//
//  Created by ddm on 7/10/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SysMessageObj : NSObject

@property (nonatomic, assign) NSInteger     msg_id;
@property (nonatomic, strong) NSString      *msg_text;
@property (nonatomic, strong) NSString      *msg_time;
@property (nonatomic, assign) BOOL          msg_IsRead;  //1为已读 0为未读
@property (nonatomic, assign) NSInteger     msg_msgId;
@property (nonatomic, assign) NSInteger     msg_Type;
@property (nonatomic, strong) NSString      *msg_title;
@property (nonatomic, strong) NSString      *msg_redirectType;
@property (nonatomic, strong) NSString      *msg_redirectPage;
@property (nonatomic, strong) NSString      *msg_buttonTitle;
@property (nonatomic, strong) NSString      *msg_url;

- (id)initWithDictory:(NSDictionary*)dic;

@end
