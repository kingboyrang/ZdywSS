//
//  MoneyInfoNode.h
//  WldhClient
//
//  Created by dyn on 13-8-6.
//  Copyright (c) 2013年 guoling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoneyInfoNode : NSObject
{
}
@property(nonatomic,copy)NSString   *payCodeStr;
@property(nonatomic,copy)NSString   *moneyStr;
@property(nonatomic,copy)NSString   *paytypeStr;
@property(nonatomic,copy)NSString   *goodIDStr;
@property(nonatomic,copy)NSString   *payKindStr;
@property(nonatomic,copy)NSString   *moneyDescriptStr;
@property(nonatomic,copy)NSString   *moneyNameStr;
@end
