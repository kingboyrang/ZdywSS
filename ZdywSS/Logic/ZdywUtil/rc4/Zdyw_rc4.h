//
//  Zdyw_rc4.h
//  ZdywUtils
//
//  Created by dyn on 13-6-5.
//  Copyright (c) 2013年 dyn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Zdyw_rc4 : NSObject
/*
 功能：     对字符串进行rc4加密
 输入参数：  strInput：需要加密的字符串，strKey：加密所使用的key值
 返回值：   加密后字符串
 */
+ (NSString *)RC4Encrypt:(NSString *)strInput withKey:(NSString *)strKey;

/*
 功能：    对字符串进行rc4加密 加密后的字符不转为16进制
 输入参数： strInput：需要加密的字符串，strKey：加密所使用的key值
 返回值：   加密后字符串
 */
+ (NSString *)RC4EncryptEx:(NSString *)strInput withKey:(NSString *)strKey;

/*
 功能：    对字符串进行rc4解密
 输入参数： strInput：需要解密的字符串，strKey：解密所使用的key值
 返回值：   解密后字符串
 */
+ (NSString *)RC4Decrypt:(NSString *)strInput withKey:(NSString *)strKey;

/*
 功能：    对字符串进行rc4解密 接收的解密字符没有转为16进制
 输入参数： strInput：需要解密的字符串，strKey：解密所使用的key值
 返回值：   解密后字符串
 */
+ (NSString *)RC4DecryptEx:(NSString *)strInput withKey:(NSString *)strKey;

@end
