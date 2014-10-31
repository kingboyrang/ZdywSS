//
//  ZdywUtils.m
//  ZdywUtilCore
//
//  Created by mini1 on 14-5-9.
//  Copyright (c) 2014年 Guoling. All rights reserved.
//

#import "ZdywUtils.h"
#import "Zdyw_md5.h"
#import "codes.h"
#import <AdSupport/AdSupport.h>
#include <sys/sysctl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "Reachability.h"

static NSDateFormatter *stat_wldhDateFormatter = nil;
static AVAudioPlayer *gAudioPlayer = nil;

@implementation ZdywUtils

+ (NSString *)getWldhUrlUidSign:(NSDictionary *)dic
                          agwAn:(NSString *)agwAn
                          agnKn:(NSString *)agwKn
                          agwTK:(NSString *)agwTK
                            pwd:(NSString *)pwd
{
    NSArray *keys = [dic allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSString *strURLSign = @"";
    
    for (NSString *categoryId in sortedArray)
    {
        strURLSign = [NSString stringWithFormat:@"%@%@=%@", strURLSign, categoryId, [dic objectForKey:categoryId]];
    }
    
    //参加sign计算的末尾拼接md5密码
    NSString *strPwd = @"";
    if([pwd length] > 0)
    {
        strPwd = [[Zdyw_md5 shareUtility] md5:pwd];
    }
    
    strURLSign = [NSString stringWithFormat:@"%@%@", strURLSign, strPwd];
    
    //获取认证签名所需的参数
    char *src = (char *)[strURLSign UTF8String];
    int srclen = 0;
    if(src)
    {
        srclen = (int)strlen(src);
    }
    
    char *keystr = NULL;
    int keylen = 0;
    if([agwTK length] > 0)
    {
        keystr = (char *)[agwTK UTF8String];
        keylen = (int)strlen(keystr);
    }
    
    int deType = [agwAn intValue];
    int keyType = [agwKn intValue];
    
    char *buff = KcDecode(src, keystr, srclen, deType, keyType, keylen);
    
    strURLSign = [NSString stringWithUTF8String:buff];
    
    return strURLSign;
}

+ (NSString *)getWldhUrlKeySign:(NSDictionary *)dic
                          agwAn:(NSString *)agwAn
                          agnKn:(NSString *)agwKn
                          agwTK:(NSString *)agwTK
{
    NSArray *keys = [dic allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSString *strURLSign = @"";
    
    for (NSString *categoryId in sortedArray)
    {
        strURLSign = [NSString stringWithFormat:@"%@%@=%@", strURLSign, categoryId, [dic objectForKey:categoryId]];
    }
    
    //获取认证签名所需的参数
    char *src = (char *)[strURLSign UTF8String];
    int srclen = 0;
    if(src)
    {
        srclen = (int)strlen(src);
    }
    
    char *keystr = NULL;
    int keylen = 0;
    if([agwTK length] > 0)
    {
        keystr = (char *)[agwTK UTF8String];
        keylen = (int)strlen(keystr);
    }
    
    int deType = [agwAn intValue];
    int keyType = [agwKn intValue];
    
    char *buff = KcDecode(src, keystr, srclen, deType, keyType, keylen);
    
    strURLSign = [NSString stringWithUTF8String:buff];
    
    return strURLSign;
}

+ (NSString *)getDateTextFromDate:(NSDate *)date withFormater:(NSString *)formater
{
    if (date == nil || 0 == [formater length])
    {
        return @"";
    }
    
    @synchronized(self)
    {
        if (stat_wldhDateFormatter == nil)
        {
            stat_wldhDateFormatter = [[NSDateFormatter alloc] init];
        }
        
        [stat_wldhDateFormatter setDateFormat:formater];
        return [stat_wldhDateFormatter stringFromDate:date];
    }
}

+ (NSDate *)dateFromString:(NSString *)dateStr withFormater:(NSString *)formater
{
    if ([dateStr length] == 0 || 0 == [formater length])
    {
        return nil;
    }
    
    @synchronized(self)
    {
        if (stat_wldhDateFormatter == nil)
        {
            stat_wldhDateFormatter = [[NSDateFormatter alloc] init];
        }
        
        [stat_wldhDateFormatter setDateFormat:formater];
        return [stat_wldhDateFormatter dateFromString:dateStr];
    }
}

+ (void)setLocalDataString:(NSString *)aValue key:(NSString *)aKey
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (nil == defaults || nil == aKey)
    {
        return;
    }
    
    [defaults setValue:aValue forKey: aKey];
    
    //sync
    [defaults synchronize];
}

+ (void)setLocalDataString:(NSString *)aValue key:(NSString *)aKey userID:(NSString *)userID
{
    if (0 == [userID length])
    {
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (nil == defaults || nil == aKey)
    {
        return;
    }
    
    [defaults setValue:aValue forKey:[NSString stringWithFormat:@"%@_%@",userID,aKey]];
    
    //sync
    [defaults synchronize];
}

+ (NSString *)getLocalStringDataValue:(NSString *)aKey
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (nil == aKey|| nil ==defaults)
    {
        return nil;
    }
    
    NSString *strTemp = [defaults objectForKey: aKey];
    
    if([strTemp length] <= 0)
    {
        strTemp = @"";
    }
    
    return strTemp;
}

+ (NSString *)getLocalUser:(NSString *)userID dataWithKey:(NSString *)aKey
{
    if (0 == [userID length] || 0 == [aKey length])
    {
        return @"";
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (nil == aKey|| nil ==defaults)
    {
        return nil;
    }
    
    NSString *strTemp = [defaults objectForKey:[NSString stringWithFormat:@"%@_%@",userID,aKey]];
    
    if([strTemp length] <= 0)
    {
        strTemp = @"";
    }
    
    return strTemp;
}

+ (void)setLocalDataBoolen:(bool)bValue  key:(NSString *)aKey
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (nil == defaults || nil == aKey)
    {
        return;
    }
    
    [defaults setBool:bValue forKey:aKey];
    
    [defaults synchronize];
}

+ (void)setLocalDataBoolen:(bool)bValue  key:(NSString *)aKey userID:(NSString *)userID
{
    if (0 == [userID length])
    {
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (nil == defaults || nil == aKey)
    {
        return;
    }
    
    [defaults setBool:bValue forKey:[NSString stringWithFormat:@"%@_%@",userID,aKey]];
    
    [defaults synchronize];
}

+ (BOOL)getLocalDataBoolen:(NSString *)aKey
{
    BOOL bRet = false;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (nil == defaults || nil == aKey)
    {
        bRet = NO;
    }
    else
    {
        bRet = [defaults boolForKey:aKey];
    }
    
    return bRet;
}

+ (BOOL)getLocalDataBoolen:(NSString *)aKey userID:(NSString *)userID
{
    BOOL bRet = false;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (nil == defaults || nil == aKey || 0 == [userID length])
    {
        bRet = NO;
    }
    else
    {
        bRet = [defaults boolForKey:[NSString stringWithFormat:@"%@_%@",userID,aKey]];
    }
    
    return bRet;
}

+ (void)setLocalIdDataValue:(id)aValue key:(NSString *)aKey
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (nil == defaults || nil == aKey)
    {
        return;
    }
    
    [defaults setValue:aValue forKey:aKey];
    
    //sync
    [defaults synchronize];
}

+ (void)setLocalIdDataValue:(id)aValue key:(NSString *)aKey userID:(NSString *)userID
{
    if (0 == [userID length])
    {
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (nil == defaults || nil == aKey)
    {
        return;
    }
    
    [defaults setValue:aValue forKey:[NSString stringWithFormat:@"%@_%@",userID,aKey]];
    
    //sync
    [defaults synchronize];
}

+ (id)getLocalIdDataValue:(NSString *)aKey
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (nil == aKey)
    {
        return nil;
    }
    
    return [defaults objectForKey: aKey];
}

+ (id)getLocalIdDataValue:(NSString *)aKey userID:(NSString *)userID
{
    if (0 == [userID length])
    {
        return nil;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (nil == aKey)
    {
        return nil;
    }
    
    return [defaults objectForKey:[NSString stringWithFormat:@"%@_%@",userID,aKey]];
}

+ (NSString *)getDeviceID
{
    if([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        NSString *strIDFA = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        NSLog(@"strIDFA = %@", strIDFA);
        
        return strIDFA;
    }
    else
    {
        int                 mib[6];
        size_t              len;
        char                *buf;
        unsigned char       *ptr;
        struct if_msghdr    *ifm;
        struct sockaddr_dl  *sdl;
        
        mib[0] = CTL_NET;
        mib[1] = AF_ROUTE;
        mib[2] = 0;
        mib[3] = AF_LINK;
        mib[4] = NET_RT_IFLIST;
        
        if ((mib[5] = if_nametoindex("en0")) == 0) {
            printf("Error: if_nametoindex error\n");
            return NULL;
        }
        
        if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
            printf("Error: sysctl, take 1\n");
            return NULL;
        }
        
        if ((buf = malloc(len)) == NULL) {
            printf("Could not allocate memory. error!\n");
            return NULL;
        }
        
        if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
            printf("Error: sysctl, take 2");
            free(buf);
            return NULL;
        }
        
        ifm = (struct if_msghdr *)buf;
        sdl = (struct sockaddr_dl *)(ifm + 1);
        ptr = (unsigned char *)LLADDR(sdl);
        NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                               *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
        free(buf);
        
        return outstring;
    }
    
    return @"";
}

+ (NSString *)dealWithPhoneNumber:(NSString *)strPhoneNumber isChineAccount:(BOOL)bflag
{
    NSString *strReault = [strPhoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    // 去掉'-'
    strReault = [strReault stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    // 判断账号是中国的，则要去掉+86，0086，17951等前缀
    if (bflag)
    {
        // 去掉'+86'
        if ([strReault hasPrefix:@"+86"])
        {
            strReault = [strReault stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
        }
        else if ([strReault hasPrefix:@"0086"])// 去掉号码前面加的"0086"
        {
            strReault = [strReault stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:@""];
        }
        else if ([strReault hasPrefix:@"12593"])// 去掉号码前面加的"12593"
        {
            strReault = [strReault stringByReplacingCharactersInRange:NSMakeRange(0, 5) withString:@""];
        }
        else if ([strReault hasPrefix:@"17951"])// 去掉号码前面加的"17951"
        {
            strReault = [strReault stringByReplacingCharactersInRange:NSMakeRange(0, 5) withString:@""];
        }
        else if ([strReault hasPrefix:@"17911"])// 去掉号码前面加的"17911"
        {
            strReault = [strReault stringByReplacingCharactersInRange:NSMakeRange(0, 5) withString:@""];
        }
    }
    
    strReault = [ZdywUtils replaceSpecialCharacterInPhoneNumber:strReault];
    
    return strReault;
}

+ (NSString *)replaceSpecialCharacterInPhoneNumber:(NSString *)phoneNum
{
    if (0 == [phoneNum length])
    {
        return @"";
    }
    
    NSString *str = [NSString stringWithFormat:@"%@",phoneNum];
    
    str  = [str stringByReplacingOccurrencesOfString:@"!" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"*" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"'" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"(" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@")" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@";" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@":" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"&" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"=" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"+" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"$" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"," withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"/" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"?" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"%" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"#" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"." withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    // 去掉'-'
    str = [str stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return str;
}

+ (BOOL)isMobileNumber:(NSString *)strPhoneNum
{
    /*
     判断规则
     1.为11位数字
     2.以1开头
     3.连续数字不会超过6位,例如：不包含123456、23456这样的连续数字
     4.同样数字连续不能出现6次 例如：不包含111111、222222、333333、444444
     */
    
    //判断位数
    if (11 != [strPhoneNum length])
    {
        return NO;
    }
    
    //首位是否为1
    if (![strPhoneNum hasPrefix:@"1"])
    {
        return NO;
    }
    
    char theSameNum = [strPhoneNum characterAtIndex:0];
    int  sameCount = 1;
    int countinueCount = 1;
    int lastResult = 0;
    
    for (int i = 1; i < [strPhoneNum length]; ++i)
    {
        char c = [strPhoneNum characterAtIndex:i];
        
        //判断是否为数字
        if (c < '0' || c > '9')
        {
            return NO;
        }
        
        //判断相同数字
        if (c == theSameNum)
        {
            ++sameCount;
            if (sameCount >= 6)
            {
                return NO;
            }
        }
        else
        {
            sameCount = 1;
            theSameNum = c;
        }
        
        //判断连续数字
        int result = c - [strPhoneNum characterAtIndex:i - 1];
        
        //前后两个数字相差1，才为连续数字
        if (result == 1 || result == -1)
        {
            if (lastResult != result) //若上次两个相连数字的差不等于本次两个相连数字的差，表示重新开始计算，加入本次判断的数字，连续数字个数为2
            {
                lastResult = result;
                countinueCount = 2;
            }
            else if(lastResult == result) //若上次两个相连数字的差等于本次两个相连数字的差，是连续数字，连续数字个数加1
            {
                ++countinueCount;
            }
        }
        else //前后两个数字相差不为1，不连续，重新开始计算，重置上次两个相连的数字的差为0，连续数字的个数为1
        {
            lastResult = 0;
            countinueCount = 1;
        }
        
        if (countinueCount >= 6)
        {
            return NO;
        }
    }
    
    return YES;
}

+ (BOOL)isInternationalNumber:(NSString *)strPhoneNum
{
    BOOL bRet = NO;
    
    if (nil != strPhoneNum)
    {
        if ([strPhoneNum length] > 4)
        {
            if ([ZdywUtils textIsPureDigital:strPhoneNum])
            {
                NSString *strBeginTwo = [strPhoneNum substringToIndex:2];
                NSString *strBeginFour = [strPhoneNum substringToIndex:4];
                
                if ([strBeginTwo isEqualToString:@"00"] && ![strBeginFour isEqualToString:@"0086"])
                {
                    bRet = YES;
                }
            }
            else
            {
                NSString *strBeginOne   = [strPhoneNum substringToIndex:1];
                NSString *strBeginThree = [strPhoneNum substringToIndex:3];
                if ([strBeginOne isEqualToString:@"+"] && ![strBeginThree isEqualToString:@"+86"])
                {
                    bRet = YES;
                }
            }
        }
    }
    
    return bRet;
}

+ (BOOL)textIsPureDigital:(NSString *)text
{
    NSScanner *scan = [NSScanner scannerWithString:text];
    
    int val;
    
    return [scan scanInt:&val] && [scan isAtEnd];
}

+ (BOOL)isPhoneNumber:(NSString *)aStr
{
    if (0 != [aStr length])
    {
        NSString *strPhoneNum = [ZdywUtils dealWithPhoneNumber:aStr isChineAccount:YES];
        return [self isMobileNumber:strPhoneNum];
    }
    
    return NO;
}

+ (NSString *)getSIMOperators
{
    NSString *strMobileType = nil;
    
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    NSString *mcc = [carrier mobileCountryCode];
    NSString *mnc = [carrier mobileNetworkCode];
    NSString *mcc_mnc = [NSString stringWithFormat: @"%@%@", mcc, mnc];
    
    if([mcc_mnc isEqualToString: @"46000"] || [mcc_mnc isEqualToString: @"46002"])  //移动
    {
        strMobileType = @"cmcc";
    }
    else if([mcc_mnc isEqualToString: @"46001"])    //联通
    {
        strMobileType = @"cu";
    }
    else if([mcc_mnc isEqualToString: @"46003"])    //电信
    {
        strMobileType = @"ct";
    }
    
    return strMobileType;
}

+ (UIImage *)transformViewToImage:(UIView *)aview
{
    UIGraphicsBeginImageContext(aview.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [aview.layer renderInContext:ctx];
    UIImage* tImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tImage;
}

+ (UIImage *)transformImage:(UIImage *)img toSize:(CGSize)aSize
{
    UIGraphicsBeginImageContext(aSize);
    [img drawInRect:CGRectMake(0, 0, aSize.width, aSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (void)playShortResourceSound:(NSString *)strFileName withExtension :(NSString *)strExtension
{
    //创建
    SystemSoundID soundID;
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:strFileName withExtension:strExtension];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileUrl, &soundID);
    //播放
    AudioServicesPlaySystemSound(soundID);
}

+ (void)playSystemSound
{
    SystemSoundID sID;
    if ([[[UIDevice currentDevice] model] isEqualToString:@"iPad"])
    {
        sID = 1109;
    }
    else
    {
        sID = 1201;
    }
    AudioServicesPlaySystemSound(sID);
}

+ (void)loudSpeaker:(BOOL)bOpen
{
    AudioSessionSetActive(true);
    UInt32 route;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    
    route = bOpen?kAudioSessionOverrideAudioRoute_Speaker:kAudioSessionOverrideAudioRoute_None;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(route), &route);
}

+ (void)playBigResourceSound:(NSString *)strFileName
              withExtension :(NSString *)strExtension
             withRepeatTimes:(int)nTimes
           playOnLoudSpeaker:(BOOL)bLoudSpeaker
                  withVolume:(float)fVolume
{
    if (nil != gAudioPlayer)
    {
        [gAudioPlayer stop];
    }
    
    if (0 == [strFileName length])
    {
        return;
    }
    
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:strFileName withExtension:strExtension];
    
    if (nil != gAudioPlayer)
    {
        gAudioPlayer = nil;
    }
    
    gAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    gAudioPlayer.volume = fVolume;
    [gAudioPlayer prepareToPlay];
    gAudioPlayer.numberOfLoops = nTimes;
    [gAudioPlayer play];
}

+ (MCCType)getSimCardType
{
    MCCType currentMccType = MCC_AMERICA;
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    NSString *mcc = [carrier mobileCountryCode];
    if([mcc isEqualToString: @"460"])
    {
        currentMccType = MCC_CHINA;
        
    }
    else
    {
        currentMccType = MCC_AMERICA;
    }
    return currentMccType;
}

/*
 Platforms
 
 iFPGA ->		??
 
 iPhone1,1 ->	iPhone 1G
 iPhone1,2 ->	iPhone 3G
 iPhone2,1 ->	iPhone 3GS
 iPhone3,1 ->	iPhone 4/AT&T
 iPhone3,2 ->	iPhone 4/Other Carrier?
 iPhone3,3 ->	iPhone 4/Other Carrier?
 iPhone4,1 ->	??iPhone 5
 
 iPod1,1   -> iPod touch 1G
 iPod2,1   -> iPod touch 2G
 iPod2,2   -> ??iPod touch 2.5G
 iPod3,1   -> iPod touch 3G
 iPod4,1   -> iPod touch 4G
 iPod5,1   -> ??iPod touch 5G
 
 iPad1,1   -> iPad 1G, WiFi
 iPad1,?   -> iPad 1G, 3G <- needs 3G owner to test
 iPad2,1   -> iPad 2G (iProd 2,1)
 
 i386, x86_64 -> iPhone Simulator
 */
+ (NSString *)getPlatformInfo
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *answer = malloc(size);
	sysctlbyname("hw.machine", answer, &size, NULL, 0);
	NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
	free(answer);
	return results;
}

+ (PhoneNetType)getCurrentPhoneNetType
{
    PhoneNetType nPhoneNetType = PNT_UNKNOWN;
    
    if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable)
    {
        nPhoneNetType = PNT_WIFI;
    }
    else if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable)
    {
        nPhoneNetType = PNT_2G3G;
    }
    
    return nPhoneNetType;
}

+ (NSString *)getCurrentPhoneNetMode
{
    NSString *strNetMode = @"";
    
    if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable)
    {
        strNetMode = @"wifi";
    }
    else if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable)
    {
        strNetMode = @"2g";
    }
    
    return strNetMode;
}

@end
