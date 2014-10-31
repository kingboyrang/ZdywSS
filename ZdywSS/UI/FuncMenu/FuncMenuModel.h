//
//  FuncMenuModel.h
//  ZdywClient
//
//  Created by ddm on 6/9/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FuncMenuModel : NSObject

@property (nonatomic, strong) NSString *funcName;
@property (nonatomic, strong) UIImage  *funcIcon;
@property (nonatomic, assign) FuncMenuType funcMenuType;

@end
