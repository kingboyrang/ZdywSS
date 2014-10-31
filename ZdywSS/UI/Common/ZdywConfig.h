//
//  ZdywConfig.h
//  ZdywMini
//
//  Created by mini1 on 14-5-28.
//  Copyright (c) 2014年 Guoling. All rights reserved.
//

#define kZdywClientIsIphone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define IOS7 [[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0

#define IOS6 [[[UIDevice currentDevice]systemVersion] floatValue] < 7.0

// AppStore版本用 iphone-app 企业版用iphone
//#define kZdywPhoneType                  @"iphone"                                       //pv
//#define kZdywPublicKey                  @"9876543210!@#$%^"                             //public_key
//#define kZdywAppleID                    @"845078110"                                    //apple id
//#define kZdywHttpServer                 @"http://access.guoling.com/zd"
//#define kPaySource                      @"59"
//#define kCustomerServicePhone           @"400-6617-288"                               //客服电话
//#define kCustomerServiceQQ              @"2263398703"                                 //客服QQ
//#define kInvite                         @"14"                                          // 渠道号
//#define kCustomerServiceTime            @"8:00-23:00"
//#define kZdywServiceHosts               [NSArray arrayWithObjects:@"http://agw.shuodh.com:2001",@"http://agw1.shuodh.com:2002",@"http://agw2.shuodh.com:2003",@"http://agw3.shuodh.com:2004",@"http://agw4.shuodh.com:2005",nil]  //多服务器地址配置


//#define kMaxFeelCPhoneCount             3