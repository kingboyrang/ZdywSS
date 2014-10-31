//
//  ChineseToPinyin.h
//  UXin
//
//  Created by Liam on 12-12-17.
//  Copyright 2012年 UXin CO. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ChineseToPinyin : NSObject {
    
}

// 输入中文，返回拼音
+ (NSString *)pinyinFromChiniseString:(NSString *) string;

// 输入中文，返回拼音首字母
+ (NSString *)acronymOfPinyingOfChineseString:(NSString *) string;

// 字符串是否包含汉字
+ (BOOL)hasChineseCharacter:(NSString *) string;

@end
