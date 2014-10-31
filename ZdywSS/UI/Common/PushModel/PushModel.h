//
//  PushModel.h
//  ZdywClient
//
//  Created by ddm on 7/3/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushModel : NSObject

@property (nonatomic, strong) NSString * alert;
@property (nonatomic, strong) NSString * badge;
@property (nonatomic, strong) NSString * sound;
@property (nonatomic, strong) NSString * Id;
@property (nonatomic, strong) NSString * target;
@property (nonatomic, strong) NSString * type;

- (id)initWithDic:(NSDictionary *)dictionary;

@end
