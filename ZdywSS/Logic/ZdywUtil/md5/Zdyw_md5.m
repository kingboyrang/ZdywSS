//
//  Zdyw_md5.m
//  ZdywUtils
//
//  Created by dyn on 13-6-5.
//  Copyright (c) 2013年 dyn. All rights reserved.
//

#import "Zdyw_md5.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

static Zdyw_md5 *gMd5Instance = NULL;
@implementation Zdyw_md5
/*
 功能：   初始化方法
 输入参数：无
 返回值：  全局唯一的Zdyw_md5对象
 */
+ (Zdyw_md5*)shareUtility
{
    @synchronized(self)
    {
        if (gMd5Instance)
        {
            return gMd5Instance;
        }
            gMd5Instance=[[self alloc] init];
            return  gMd5Instance;

    }
}

/*
 功能：加密字符串
 输入参数：str：需要加密的字符串
 返回值：  加密后字符串
 */

- (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [[NSString stringWithFormat:
             @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];

}

@end
