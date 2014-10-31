//
//  PhoneOnwerShipEngine.m
//  ContactManager
//  号码归属地引擎
//  Created by mini1 on 13-6-8.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import "PhoneOnwerShipEngine.h"

@implementation PhoneOnwerShipEngine
@synthesize bLoadDataFinished = _bLoadDataFinished;
@synthesize bLoadDataing = _bLoadDataing;

- (void)dealloc
{
    [_phoneAreaList release];
    _phoneAreaList = nil;
    
    [_chineseArealList release];
    _chineseArealList = nil;
    
    [_interArealList release];
    _interArealList = nil;
    
    [_recordSectionList release];
    _recordSectionList = nil;
    
    [queue release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _phoneAreaList = [[NSMutableArray alloc] initWithCapacity:2];
        _chineseArealList = [[NSMutableArray alloc] initWithCapacity:2];
        _interArealList = [[NSMutableArray alloc] initWithCapacity:2];
        _recordSectionList = [[NSMutableArray alloc] initWithCapacity:2];
        
        queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:1];
        
        _bLoadDataFinished = NO;
        _bLoadDataing = NO;
    }
    return self;
}

/*
 函数描述：从文件中读取数据
 输入参数：filePath      文件路径
 输出参数：N/A
 返 回 值:N/A
 作    者：刘斌
 */
- (void)loadDataWithFilePath:(NSString *)filePath
{
    [_phoneAreaList removeAllObjects];
    [_chineseArealList removeAllObjects];
    [_interArealList removeAllObjects];
    [_recordSectionList removeAllObjects];
    //[NSThread detachNewThreadSelector:@selector(loadDataThread:) toTarget:self withObject:filePath];
    
    // 需要创建一个线程，执行查询归属地动作
    NSInvocationOperation *operation = [[NSInvocationOperation alloc]
                                        initWithTarget:self
                                        selector:@selector(loadDataThread:)
                                        object:filePath];
    // 将操作加入队列
    [queue addOperation:operation];
    [operation release];
}

- (void)loadDataThread:(NSString *)filePath
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    self.bLoadDataFinished = NO;
    self.bLoadDataing = YES;
    
    NSData *pData = [[NSData alloc] initWithContentsOfFile:filePath];
    
    if (pData == nil || [pData length] == 0)
    {
        self.bLoadDataing = NO;
        [pData release];
        return;
    }
    
    if ([pData length] >= 2)
    {
        NSData * theData = [NSData dataWithData:[pData subdataWithRange:NSMakeRange(0, 2)]];
        
        u_int16_t num;
        [theData getBytes:&num length:2];
        
        u_int16_t phoneAreaInt;
        u_int32_t startInt;
        u_int32_t lengthInt;
        NSData    *phoneArea;
        
        // 读取号码段数据索引
        int mylen=2;
        for (int i=0; i<num; i++)
        {
            phoneArea = [NSData dataWithData: [pData subdataWithRange: NSMakeRange(mylen, 2)]];
            [phoneArea getBytes: &phoneAreaInt length: 2];
            mylen+=2;
            
            phoneArea = [NSData dataWithData: [pData subdataWithRange: NSMakeRange(mylen, 4)]];
            [phoneArea getBytes:&startInt length: 4];
            mylen+=4;
            
            phoneArea = [NSData dataWithData:[pData subdataWithRange:NSMakeRange(mylen, 4)]];
            [phoneArea getBytes:&lengthInt length: 4];
            mylen+=4;
            
            NSMutableDictionary * bkDic = [[NSMutableDictionary alloc] init];
            [bkDic setObject: [NSNumber numberWithInteger: phoneAreaInt] forKey: @"phoneAreaInt"];
            [bkDic setObject: [NSNumber numberWithInteger: startInt] forKey: @"startInt"];
            [bkDic setObject: [NSNumber numberWithInteger: lengthInt] forKey: @"lengthInt"];
            [_phoneAreaList addObject: bkDic];
            [bkDic release];
        }
        
        // 读取国内地名数据
        u_int16_t aAtt;
        u_int16_t aAttribution;
        u_int8_t  len;
        
        theData = [NSData dataWithData: [pData subdataWithRange: NSMakeRange(mylen, 2)]];
        [theData getBytes: &aAtt length:2];
        mylen+=2;
        
        for (int h = 0; h < aAtt; h++)
        {
            phoneArea = [NSData dataWithData: [pData subdataWithRange: NSMakeRange(mylen, 2)]];
            [phoneArea getBytes: &aAttribution length:2];
            mylen+=2;
            
            phoneArea = [NSData dataWithData:[pData subdataWithRange: NSMakeRange(mylen, 1)]];
            [phoneArea getBytes: &len length: 1];
            mylen+=1;
            
            char buf [len+1];
            phoneArea = [NSData dataWithData: [pData subdataWithRange: NSMakeRange(mylen, len)]];
            [phoneArea getBytes:buf length:len];
            buf[len+1] = '\0';
            
            NSString *strCity = [[NSString alloc] initWithBytes:buf
                                                         length:len
                                                       encoding:NSUnicodeStringEncoding];
            mylen+=len;
            
            NSMutableDictionary * bkDic = [[NSMutableDictionary alloc] init];
            [bkDic setObject:[NSNumber numberWithInteger:aAttribution] forKey:@"aAttribution"];
            [bkDic setObject:strCity  forKey:@"strCity"];
            [_chineseArealList addObject: bkDic];
            [bkDic release];
            
            [strCity release];
        }
        
        // 读取国际地名数据
        theData = [NSData dataWithData: [pData subdataWithRange: NSMakeRange(mylen, 2)]];
        [theData getBytes: &aAtt length:2];
        mylen+=2;
        
        for (int h = 0; h < aAtt; h++)
        {
            phoneArea = [NSData dataWithData: [pData subdataWithRange: NSMakeRange(mylen, 2)]];
            [phoneArea getBytes: &aAttribution length:2];
            mylen+=2;
            
            phoneArea = [NSData dataWithData:[pData subdataWithRange: NSMakeRange(mylen, 1)]];
            [phoneArea getBytes: &len length: 1];
            mylen+=1;
            
            char buf [len+1];
            phoneArea = [NSData dataWithData: [pData subdataWithRange: NSMakeRange(mylen, len)]];
            [phoneArea getBytes:buf length:len];
            buf[len+1] = '\0';
            
            NSString *strCity = [[NSString alloc] initWithBytes:buf
                                                         length:len
                                                       encoding:NSUnicodeStringEncoding];
            mylen+=len;
            
            NSMutableDictionary * bkDic = [[NSMutableDictionary alloc] init];
            [bkDic setObject:[NSNumber numberWithInteger:aAttribution] forKey:@"aAttribution"];
            [bkDic setObject:strCity  forKey:@"strCity"];
            [_interArealList addObject: bkDic];
            [bkDic release];
            
            [strCity release];
        }
        
        // 读取号码段数据
        for (int i = 0; i < [_phoneAreaList count]; ++i)
        {
            u_int aStart     = 0;
            u_int aLength    = 0;
            NSMutableDictionary *bkDic = [_phoneAreaList objectAtIndex:i];
            NSMutableArray *iRecordItemList     = [[NSMutableArray alloc] init];
            
            aStart  = [[bkDic objectForKey:@"startInt"] intValue];
            aLength = [[bkDic objectForKey:@"lengthInt"] intValue];
            
            
            u_int8_t a ;
            u_int8_t b ;
            u_int8_t c ;
            
            for (int j = 0; j < aLength; j += 3)
            {
                phoneArea = [NSData dataWithData:[pData subdataWithRange:NSMakeRange(aStart,1)]];
                [phoneArea getBytes:&a length:1];
                
                aStart+=1;
                
                phoneArea = [NSData dataWithData:[pData subdataWithRange:NSMakeRange(aStart,1)]];
                [phoneArea getBytes:&b length:1];
                
                aStart+=1;
                
                phoneArea = [NSData dataWithData:[pData subdataWithRange:NSMakeRange(aStart,1)]];
                [phoneArea getBytes:&c length:1];
                
                aStart+=1;
                
                u_int32_t aaa = (c << 16) | (b << 8) | a;
                u_int16_t aPhone = aaa >> 10;
                u_int16_t aArea = aaa & 0x3FF;
                
                NSMutableDictionary *bkDic = [[NSMutableDictionary alloc] init];
                [bkDic setObject:[NSNumber numberWithInteger:aPhone] forKey:@"aPhone"];
                [bkDic setObject:[NSNumber numberWithInteger:aArea] forKey:@"aArea"];
                
                [iRecordItemList addObject:bkDic];
                [bkDic release];
            }
            
            [_recordSectionList addObject:iRecordItemList];
            
            [iRecordItemList release];
        }
    }
    
    self.bLoadDataing = NO;
    self.bLoadDataFinished = YES;
    [pData release];
    [pool release];
}


/************************************************************************************
 *
 *	函数名称		binarySearch
 *	函数介绍		根据手机号前七位搜索手机号所属地名段的下标。
 *	函数参数		phoneNumber : 手机号码前7位。
 *	返回  值		int         : 号码段所属城市下标。
 *
 ***********************************************************************************/
- (int) binarySearch:(int)phoneNumber;
{
    u_int aPhoneArea = phoneNumber / 10000;
    u_int aPhoneLoc  = phoneNumber % 10000;
    
    NSMutableArray *iRecordItemList = nil;
    
    for (int  i = 0; i < [_phoneAreaList count]; i++)
    {
        NSMutableDictionary *bkDic = [_phoneAreaList objectAtIndex:i];
        int number = [[bkDic objectForKey:@"phoneAreaInt"] intValue];
        if (aPhoneArea == number)
        {
            iRecordItemList = (NSMutableArray *)[_recordSectionList objectAtIndex:i];
            break;
        }
    }
    
    if (nil == iRecordItemList)
    {
        return -1;
    }
    
    int left    = 0;
    int right   = [iRecordItemList count] - 1;
    int middle  = 0;
    
    while (left <= right)
    {
        middle = (left + right) / 2;
        
        NSMutableDictionary *bkDic=[iRecordItemList objectAtIndex:middle];
        int number = [[bkDic objectForKey:@"aPhone"] intValue];
        
        if (aPhoneLoc < number)
        {
            right = middle - 1;
        }
        else if (aPhoneLoc > number)
        {
            left = middle + 1;
        }
        else if (aPhoneLoc == number)
        {
            NSMutableDictionary *bkDic = [iRecordItemList objectAtIndex:middle];
            int area = [[bkDic objectForKey:@"aArea"] intValue];
            return area;
        }
    }
    
    NSMutableDictionary *bkDic = [iRecordItemList objectAtIndex:middle];
    int number = [[bkDic objectForKey:@"aPhone"] intValue];
    
    if (number > aPhoneLoc)
    {
        NSMutableDictionary *bkDic = [iRecordItemList objectAtIndex:middle-1];
        int area = [[bkDic objectForKey:@"aArea"] intValue];
        return area;
    }
    else
    {
        NSMutableDictionary *bkDic = [iRecordItemList objectAtIndex:middle];
        int area = [[bkDic objectForKey:@"aArea"] intValue];
        return area;
    }
    
    return -1;
}

// 获取国际号码的前几位数字（+后面非0开始）
// 如: +01123123123，前1位=1，前2位=11，前3位=112
// strNumber : 国际号码，一定是以+开头的
// nCount    : 前多少位
- (NSString *)getInterSubNumber:(NSString *)strNumber withNumbers:(int)nCount
{
    NSString *strRet;
    NSString *strTemp = [NSString stringWithFormat:@"%@", strNumber];
    strTemp = [strNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    strRet = strTemp;
    
    for (int i = 0; i < [strTemp length]; ++i)
    {
        if ('0' == [strTemp characterAtIndex:i])
        {
            strRet = [strRet substringFromIndex:1];
        }
        else
        {
            break;
        }
    }
    
    if (nCount <= [strRet length])
    {
        strRet = [strRet substringToIndex:nCount];
    }
    
    return strRet;
}

/*
 函数描述：获取号码运营商
 输入参数：phoneNumber      电话号码
 isChina          是否为中国号码
 输出参数：N/A
 返 回 值:NSString     运营商名称
 作    者：刘斌
 */

- (NSString *)getPhoneOperatorsWithNumber:(NSString *)phoneNumber{
    NSString *strUlt = nil;
    if ([ZdywUtils isPhoneNumber:phoneNumber]) {
        NSString *strRet = [phoneNumber substringWithRange:NSMakeRange(0,3)];
        switch ([strRet integerValue]) {
            case 130:
            case 131:
            case 132:
            case 155:
            case 156:
            case 185:
            case 186:
            case 176:
                strUlt = @"联通";
                break;
            case 134:
            case 135:
            case 136:
            case 137:
            case 138:
            case 139:
            case 150:
            case 151:
            case 152:
            case 158:
            case 159:
            case 182:
            case 183:
            case 184:
            case 157:
            case 187:
            case 188:
            case 178:
                strUlt = @"移动";
                break;
            case 133:
            case 153:
            case 180:
            case 181:
            case 189:
            case 177:
                strUlt = @"电信";
                break;
            default:
                strUlt = @"";
                break;
        }
    } else {
        return @"";
    }
    return strUlt;
}

/*
 函数描述：获取号码归属地
 输入参数：phoneNumber      电话号码
 isChina          是否为中国号码
 输出参数：N/A
 返 回 值:NSString     归属地名称
 作    者：刘斌
 */
- (NSString *)getPhoneOnwerShipWithNumber:(NSString *)phoneNumber isChineseNumber:(BOOL)isChina
{
    if (!_bLoadDataFinished || nil == phoneNumber || [phoneNumber length] < 6)
    {
        return @"";
    }
    
    NSString *strTempPhoneNumber = [NSString stringWithFormat:@"%@", phoneNumber];
    
    // 国内号码
    if ([strTempPhoneNumber hasPrefix:@"0086"])
    {
        NSString *strRet = @"";
        strTempPhoneNumber = [strTempPhoneNumber substringFromIndex:4];
        
        if ([strTempPhoneNumber length] < 6)
        {
            return strRet;
        }
        
        NSString *phoneOne   = [strTempPhoneNumber substringWithRange:NSMakeRange (0, 1)];
        NSString *phoneTwo   = [strTempPhoneNumber substringWithRange:NSMakeRange (1, 2)];
        NSString *phoneThree = [strTempPhoneNumber substringWithRange:NSMakeRange (1, 3)];
        
        //假如是手机号码的情况
        if (([strTempPhoneNumber length] == 11) && ([phoneOne intValue] == 1))
        {
            NSString *phoneSeven = [strTempPhoneNumber substringWithRange:NSMakeRange (0, 7)];
            int phoneNum = [self binarySearch:[phoneSeven intValue]];
            if (phoneNum >= [_chineseArealList count])
            {
                return strRet;
            }
            
            NSMutableDictionary *bkDic = [_chineseArealList objectAtIndex: phoneNum];
            strRet = [bkDic objectForKey:@"strCity"];
            if (!isChina)
            {
                strRet = [NSString stringWithFormat:@"中国(%@)", strRet];
            }
            return strRet;
        }
        else if ([phoneOne isEqualToString:@"0"] && ![[strTempPhoneNumber substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"0"]) // 座机一定以0开头,但第二位不为0
        {
            for (int i = 0; i < [_chineseArealList count]; i++)
            {
                NSMutableDictionary * bkDic = [_chineseArealList objectAtIndex: i];
                int aAttribution = [[bkDic objectForKey:@"aAttribution"] intValue];
                
                if (aAttribution == [phoneTwo intValue])
                {
                    //先用两位数的区号去比对。
                    if ([_chineseArealList count] > i+1)
                    {
                        bkDic=[_chineseArealList objectAtIndex: i+1];
                        if (aAttribution == [[bkDic objectForKey: @"aAttribution"] intValue])
                        {
                            //假如区号有重合，只显示省会。
                            NSString *att = [bkDic objectForKey: @"strCity"];
                            int l = [att rangeOfString:@" "].location;
                            if (NSNotFound != l)
                            {
                                att = [att substringToIndex:l];
                            }
                            strRet = att;
                            if (!isChina)
                            {
                                strRet = [NSString stringWithFormat:@"中国(%@)", strRet];
                            }
                            return strRet;
                        }
                        else
                        {
                            bkDic = [_chineseArealList objectAtIndex: i];
                            
                            strRet = [bkDic objectForKey: @"strCity"];
                            if (!isChina)
                            {
                                strRet = [NSString stringWithFormat:@"中国(%@)", strRet];
                            }
                            return strRet;
                        }
                    }
                    else
                    {
                        strRet = [bkDic objectForKey: @"strCity"];
                        if (!isChina)
                        {
                            strRet = [NSString stringWithFormat:@"中国(%@)", strRet];
                        }
                        return strRet;
                    }
                }
            }
            
            for (int i = 0; i < [_chineseArealList count]; i++)
            {
                NSMutableDictionary *bkDic=[_chineseArealList objectAtIndex: i];
                int aAttribution = [[bkDic objectForKey:@"aAttribution"] intValue];
                
                //假如不是两位数的区号，再用三位数的比较。
                if (aAttribution==[phoneThree intValue])
                {
                    if ([_chineseArealList count]>i+1)
                    {
                        bkDic=[_chineseArealList objectAtIndex: i+1];
                        if (aAttribution==[[bkDic objectForKey: @"aAttribution"] intValue])
                        {
                            
                            NSString *att=[bkDic objectForKey: @"strCity"];
                            int l = [att rangeOfString:@" "].location;
                            if (NSNotFound != l)
                            {
                                att = [att substringToIndex: l];
                            }
                            
                            strRet = att;
                            if (!isChina)
                            {
                                strRet = [NSString stringWithFormat:@"中国(%@)", strRet];
                            }
                            return strRet;
                        }
                        else
                        {
                            bkDic=[_chineseArealList objectAtIndex: i];
                            strRet = [bkDic objectForKey: @"strCity"];
                            if (!isChina)
                            {
                                strRet = [NSString stringWithFormat:@"中国(%@)", strRet];
                            }
                            return strRet;
                        }
                    }
                    else
                    {
                        strRet = [bkDic objectForKey: @"strCity"];
                        if (!isChina)
                        {
                            strRet = [NSString stringWithFormat:@"中国(%@)", strRet];
                        }
                        return strRet;
                    }
                }
            }
        }
    }
    else
    {
        NSString *strBeginOne   = [self getInterSubNumber:strTempPhoneNumber withNumbers:1];
        NSString *strBeginTwo   = [self getInterSubNumber:strTempPhoneNumber withNumbers:2];
        NSString *strBeginThree = [self getInterSubNumber:strTempPhoneNumber withNumbers:3];
        NSString *strBeginFour  = [self getInterSubNumber:strTempPhoneNumber withNumbers:4];
        
        // 开始查找，先1位，如果找不到则2位，如果...
        for (int i = 0; i < [_interArealList count]; ++i)
        {
            NSMutableDictionary *bkDic=[_interArealList objectAtIndex:i];
            int aAttribution = [[bkDic objectForKey:@"aAttribution"] intValue];
            
            if (aAttribution == [strBeginOne intValue])
            {
                NSString *strRet = [bkDic objectForKey:@"strCity"];
                strRet = [strRet stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSRange range = [strRet rangeOfString:@"("];
                if (NSNotFound != range.location)
                {
                    strRet = [strRet substringToIndex:range.location];
                }
                range = [strRet rangeOfString:@"（"];
                if (NSNotFound != range.location)
                {
                    strRet = [strRet substringToIndex:range.location];
                }
                return strRet;
            }
        }
        for (int i = 0; i < [_interArealList count]; ++i)
        {
            NSMutableDictionary *bkDic=[_interArealList objectAtIndex:i];
            int aAttribution = [[bkDic objectForKey:@"aAttribution"] intValue];
            
            if (aAttribution == [strBeginTwo intValue])
            {
                NSString *strRet = [bkDic objectForKey:@"strCity"];
                strRet = [strRet stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSRange range = [strRet rangeOfString:@"("];
                if (NSNotFound != range.location)
                {
                    strRet = [strRet substringToIndex:range.location];
                }
                range = [strRet rangeOfString:@"（"];
                if (NSNotFound != range.location)
                {
                    strRet = [strRet substringToIndex:range.location];
                }
                return strRet;
            }
        }
        for (int i = 0; i < [_interArealList count]; ++i)
        {
            NSMutableDictionary *bkDic=[_interArealList objectAtIndex:i];
            int aAttribution = [[bkDic objectForKey:@"aAttribution"] intValue];
            
            if (aAttribution == [strBeginThree intValue])
            {
                NSString *strRet = [bkDic objectForKey:@"strCity"];
                strRet = [strRet stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSRange range = [strRet rangeOfString:@"("];
                if (NSNotFound != range.location)
                {
                    strRet = [strRet substringToIndex:range.location];
                }
                range = [strRet rangeOfString:@"（"];
                if (NSNotFound != range.location)
                {
                    strRet = [strRet substringToIndex:range.location];
                }
                return strRet;
            }
        }
        for (int i = 0; i < [_interArealList count]; ++i)
        {
            NSMutableDictionary *bkDic=[_interArealList objectAtIndex:i];
            int aAttribution = [[bkDic objectForKey:@"aAttribution"] intValue];
            
            if (aAttribution == [strBeginFour intValue])
            {
                NSString *strRet = [bkDic objectForKey:@"strCity"];
                strRet = [strRet stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSRange range = [strRet rangeOfString:@"("];
                if (NSNotFound != range.location)
                {
                    strRet = [strRet substringToIndex:range.location];
                }
                range = [strRet rangeOfString:@"（"];
                if (NSNotFound != range.location)
                {
                    strRet = [strRet substringToIndex:range.location];
                }
                return strRet;
            }
        }
        
        // 前面都没找到，数据库不全，继续查找
        if ([strBeginThree isEqualToString:@"852"])
        {
            if (!isChina)
            {
                return @"中国 香港";
            }
            else
            {
                return @"香港";
            }
        }
        if ([strBeginThree isEqualToString:@"853"])
        {
            if (!isChina)
            {
                return @"中国 澳门";
            }
            else
            {
                return @"澳门";
            }
        }
        if ([strBeginThree isEqualToString:@"886"])
        {
            if (!isChina)
            {
                return @"中国 台湾";
            }
            else
            {
                return @"台湾";
            }
        }
    }
    
    return @"";
}

/*
 函数描述：获取电话号码区号
 输入参数：phoneNumber      电话号码
 isChina          是否为中国号码
 输出参数：N/A
 返 回 值:NSString     区号
 作    者：刘斌
 */
- (NSString *)getCityCode:(NSString *)phoneNumber isChineseNumber:(BOOL)isChina;
{
    NSString *strRet = @"";
    
    if (isChina)
    {
        NSString *strArribution = [self getPhoneOnwerShipWithNumber:phoneNumber isChineseNumber:isChina];
        if (strArribution)
        {
            for (int i =0; i<[_chineseArealList count]; i++)
            {
                NSDictionary *dic = [_chineseArealList objectAtIndex:i];
                NSString * strCity = [dic objectForKey:@"strCity"];
                
                if ([strCity isEqualToString:strArribution])
                {
                    strRet = [NSString stringWithFormat:@"%@", [dic objectForKey:@"aAttribution"]];
                    break;
                }
            }
        }
    }
    
    return strRet;
}

@end
