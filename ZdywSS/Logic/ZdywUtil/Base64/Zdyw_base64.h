//
//  Zdyw_base64.h
//  ZdywUtils
//
//  Created by dyn on 13-6-5.
//  Copyright (c) 2013年 dyn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Zdyw_base64 : NSObject

/*
 功能：   Base64加密字符串接口
 输入参数：input：需要加密的字符串，
 返回值：  加密后字符串
 */
+ (NSString * )encrypt_base64:(NSString * )input;

/*
 功能：   Base64解密字符串接口
 输入参数：input：需要解密的字符串，
 返回值：  解密后字符串
 */
+ (NSString * )decrypt_Base64:(NSString * )input;

/*
 功能：   Base64加密NSData数据接口
 输入参数：input：需要加密的NSData数据，
 返回值：  加密后的NSData数据
 */
+ (NSData*)encrypt_Base64Data:(NSData*)inputData;

/*
 功能：   Base64解密NSData数据接口
 输入参数：input：需要解密的NSData数据，
 返回值：  解密后NSData数据
 */
+ (NSData*)decrypt_Base64Data:(NSData*)inputData;

@end
