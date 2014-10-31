//
//  MonthBagModel.h
//  ZdywClient
//
//  Created by ddm on 6/24/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MonthBagModel : NSObject

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * bagName;
@property (nonatomic, strong) NSString * beginTime;
@property (nonatomic, strong) NSString * endTime;
@property (nonatomic, assign) NSInteger  traceMinute;   //剩余分钟数
@property (nonatomic, strong) NSString * userState;     //使用状态
@property (nonatomic, strong) NSString * buyTime;

- (id)initWithDict:(NSDictionary *)dic;

@end
