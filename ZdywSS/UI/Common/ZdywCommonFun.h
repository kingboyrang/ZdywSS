//
//  ZdywCommonFun.h
//  ZdywMini
//
//  Created by zhaojun on 14-6-4.
//  Copyright (c) 2014年 Guoling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZdywCommonFun : NSObject

+ (NSString *)getCustomerPhone;

+ (NSString *)getServiceTime;

+ (NSString *)getAppConfigureInfoWithKey:(NSString*)key;
//获取系统配置颜色
+ (UIColor *)getAppConfigureColorWithKey:(NSString*)key;
+ (UIColor *)getAppConfigureColorWithKey:(NSString*)key alpha:(CGFloat)alpha;

//根据图片和文字创建一个button
+ (UIButton *)createCustomButtonText:(NSString *)str
                         normalImage:(UIImage*)normalImg
                    highlightedImage:(UIImage *)highlightedImg;

+ (void) ShowMessageBox:(int)msgboxID
              titleName:(NSString *)strTitle
            contentText:(NSString *)strContent
          cancelBtnName:(NSString *)strBtnName
                 confim:(NSString *)confimBtnName
               delegate:(id)delegate;

+ (void) ShowMessageBox:(int)msgboxID
              titleName:(NSString *)strTitle
            contentText:(NSString *)strContent
          cancelBtnName:(NSString *)strBtnName
               delegate:(id)delegate;

// 获取查询话单url
+ (NSString *)getCallLogUrl;

+ (NSString *)getRechargeLogUrl;

+ (NSString *)getRc4Pwd;

+ (BOOL)validateEmail:(NSString *)email;

+ (BOOL)validateQQ:(NSString *)QQ;

@end
