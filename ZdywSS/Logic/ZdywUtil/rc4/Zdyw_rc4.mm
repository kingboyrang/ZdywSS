//
//  Zdyw_rc4.m
//  ZdywUtils
//
//  Created by dyn on 13-6-5.
//  Copyright (c) 2013年 dyn. All rights reserved.
//

#import "Zdyw_rc4.h"
#import "rc4.h"
@implementation Zdyw_rc4

/*
 功能：     对字符串进行rc4加密
 输入参数：  strInput：需要加密的字符串，strKey：加密所使用的key值
 返回值：   加密后字符串
 */
+ (NSString *)RC4Encrypt:(NSString *)strInput withKey:(NSString *)strKey
{
    char *buffer = Encrypt([strInput UTF8String], [strKey UTF8String]);
    
    NSString *strEncry = [NSString stringWithCString:buffer encoding:NSISOLatin1StringEncoding];
    
    delete [] buffer;
    
    return strEncry;
}

/*
 功能：    对字符串进行rc4加密 加密后的字符不转为16进制
 输入参数： strInput：需要加密的字符串，strKey：加密所使用的key值
 返回值：   加密后字符串
 */
+ (NSString *)RC4EncryptEx:(NSString *)strInput withKey:(NSString *)strKey
{
    char *buffer = Encrypt([strInput UTF8String], [strKey UTF8String]);
    
    unsigned char* src = HexToByte(buffer);
    
    NSString *strEncry = [[NSString alloc] initWithBytes:src
                                                  length:strlen(buffer)/2
                                                encoding:NSISOLatin1StringEncoding];
    delete [] src;
    
    delete [] buffer;
    
    return strEncry;
}

/*
 功能：    对字符串进行rc4解密
 输入参数： strInput：需要解密的字符串，strKey：解密所使用的key值
 返回值：   解密后字符串
 */
+ (NSString *)RC4Decrypt:(NSString *)strInput withKey:(NSString *)strKey
{
    char *buffer = Decrypt([strInput UTF8String], [strKey UTF8String]);
    
    NSString *strDecry = [NSString stringWithCString:buffer encoding:NSISOLatin1StringEncoding];
    
    delete [] buffer;
    
    return strDecry;

}

/*
 功能：    对字符串进行rc4解密 接收的解密字符没有转为16进制
 输入参数： strInput：需要解密的字符串，strKey：解密所使用的key值
 返回值：   解密后字符串
 */
+ (NSString *)RC4DecryptEx:(NSString *)strInput withKey:(NSString *)strKey
{
    char *buffer = Decrypt([strInput UTF8String], [strKey UTF8String]);
    
    NSString *strDecry = [NSString stringWithCString:buffer encoding:NSISOLatin1StringEncoding];
    
    delete [] buffer;
    
    return strDecry;
}

@end
