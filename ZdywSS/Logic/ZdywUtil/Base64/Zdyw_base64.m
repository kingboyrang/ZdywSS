//
//  Zdyw_base64.m
//  ZdywUtils
//
//  Created by dyn on 13-6-5.
//  Copyright (c) 2013年 dyn. All rights reserved.
//

#import "Zdyw_base64.h"
#import "GTMBase64.h"
@implementation Zdyw_base64
/*
 功能：   Base64加密字符串接口
 输入参数：input：需要加密的字符串，
 返回值：  加密后字符串
 */
+ (NSString * )encrypt_base64:(NSString * )input
{
    
    NSData * data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    // 转换到base64
    data = [GTMBase64 encodeData:data];
    NSString * base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return base64String;
}

/*
 功能：   Base64解密字符串接口
 输入参数：input：需要解密的字符串，
 返回值：  解密后字符串
 */
+ (NSString * )decrypt_Base64:(NSString * )input
{
    NSData * data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    // 转换到base64
    data = [GTMBase64 decodeData:data];
    NSString * base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return base64String;

}

/*
 功能：   Base64加密NSData数据接口
 输入参数：input：需要加密的NSData数据，
 返回值：  加密后的NSData数据
 */
+ (NSData*)encrypt_Base64Data:(NSData*)inputData
{
    return [GTMBase64 encodeData:inputData];
}

/*
 功能：   Base64解密NSData数据接口
 输入参数：input：需要解密的NSData数据，
 返回值：  解密后NSData数据
 */
+ (NSData*)decrypt_Base64Data:(NSData*)inputData
{
    return [GTMBase64 decodeData:inputData];
}

@end
