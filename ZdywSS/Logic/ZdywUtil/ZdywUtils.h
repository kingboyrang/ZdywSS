//
//  ZdywUtils.h
//  ZdywUtilCore
//
//  Created by mini1 on 14-5-9.
//  Copyright (c) 2014年 Guoling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//手机卡sim类型
typedef enum
{
    MCC_CHINA,
    MCC_AMERICA
}MCCType;

// 电话当前网络类型
typedef enum
{
    PNT_UNKNOWN = 0,    // 未知,无网络
    PNT_WIFI    = 1,    // WIFI
    PNT_2G3G           // 2G/3G
}PhoneNetType;

@interface ZdywUtils : NSObject

//获取网络电话网络请求签名
+ (NSString *)getWldhUrlUidSign:(NSDictionary *)dic
                          agwAn:(NSString *)agwAn
                          agnKn:(NSString *)agwKn
                          agwTK:(NSString *)agwTK
                            pwd:(NSString *)pwd;

+ (NSString *)getWldhUrlKeySign:(NSDictionary *)dic
                          agwAn:(NSString *)agwAn
                          agnKn:(NSString *)agwKn
                          agwTK:(NSString *)agwTK;

//获取时间字符串
+ (NSString *)getDateTextFromDate:(NSDate *)date withFormater:(NSString *)formater;

+ (NSDate *)dateFromString:(NSString *)dateStr withFormater:(NSString *)formater;

/*
 功能：     设置本地数据库对应key值下的数据(字符串)
 输入参数：  aValue: 要保存的数据   aKey: key值
 返回值：    无
 */
+ (void)setLocalDataString:(NSString *)aValue key:(NSString *)aKey;

+ (void)setLocalDataString:(NSString *)aValue key:(NSString *)aKey userID:(NSString *)userID;

/*
 功能：    从本地数据库获对应key值下的数据(字符串)
 输入参数： aKey : key值
 返回值：   返回key值下的数据
 */
+ (NSString *)getLocalStringDataValue:(NSString *)aKey;

+ (NSString *)getLocalUser:(NSString *)userID dataWithKey:(NSString *)aKey;

/*
 功能：    设置本地数据库对应key值下的数据(bool)
 输入参数：aValue: 要保存的数据   aKey: key值
 返回值：  无
 */
+ (void)setLocalDataBoolen:(bool)bValue  key:(NSString *)aKey;

+ (void)setLocalDataBoolen:(bool)bValue  key:(NSString *)aKey userID:(NSString *)userID;

/*
 功能：   从本地数据库获对应key值下的数据(bool)
 输入参数：aKey : key值
 返回值：  返回key值下的数据
 */
+ (BOOL)getLocalDataBoolen:(NSString *)aKey;

+ (BOOL)getLocalDataBoolen:(NSString *)aKey userID:(NSString *)userID;

/*
 功能：   设置本地数据库对应key值下的数据(id)
 输入参数：aValue: 要保存的数据   aKey: key值
 返回值：  无
 说明：   用于非NSString的其他NSObject对象
 */
+ (void)setLocalIdDataValue:(id)aValue key:(NSString *)aKey;

+ (void)setLocalIdDataValue:(id)aValue key:(NSString *)aKey userID:(NSString *)userID;

/*
 功能：   从本地数据库获对应key值下的数据(id)
 输入参数：aKey : key值
 返回值： 返回key值下的数据
 */
+ (id)getLocalIdDataValue:(NSString *)aKey;

+ (id)getLocalIdDataValue:(NSString *)aKey userID:(NSString *)userID;

//获取手机的设备标识
+ (NSString *)getDeviceID;

/*
 功能：	 获取纯粹的干净的电话号码
 输入参数：strPhoneNumber： 需要净化的电话号码字符串,bflag:是否是中国用户，如果是中国用户传入YES
 返回值：  净化后的电话号码字符串
 */
+ (NSString *)dealWithPhoneNumber:(NSString *)strPhoneNumber isChineAccount:(BOOL)bflag;

//去掉电话号码中的特殊字符
+ (NSString *)replaceSpecialCharacterInPhoneNumber:(NSString *)phoneNum;

/*
 功能：	 判断字符串是否为电话号码
 输入参数：strPhoneNum： 需要判断的电话号码字符串
 返回值：  YES表示是电话号码，其他值表示不是电话号码
 */
+ (BOOL)isPhoneNumber:(NSString *)strPhoneNum;

/*
 功能：	 判断是否是国际电话号码
 输入参数：strPhoneNum： 需要判断的电话号码字符串
 返回值：  YES表示是国际电话号码，其他值表示不是国际电话号码
 */
+ (BOOL)isInternationalNumber:(NSString *)strPhoneNum;

//字符串是否为纯数字
+ (BOOL)textIsPureDigital:(NSString *)text;

//是否为电话号码
+ (BOOL)isMobileNumber:(NSString *)aStr;

/*
 功能：	  获取SIM卡运营商
 输入参数： 无
 返回值：   运营商字符串
 说明：    返回字符含义说明：cmcc ：中国移动，cu ：中国联通 ct：中国电信
 */
+ (NSString *)getSIMOperators;

/*
 功能：	 把UIView转话为UIImage
 输入参数：aview：需要装化的view对象
 返回值： 转化后的图片对象
 */
+ (UIImage*)transformViewToImage:(UIView *)aview;

//调整图片大小
+ (UIImage *)transformImage:(UIImage *)img toSize:(CGSize)aSize;

/*
 功能：   播放资源声音文件(播放一些很小的提示或者警告音)
 输入参数：strFileName 文件名（为后缀） strExtension：文件格式，
 返回值：  无
 */
+ (void)playShortResourceSound:(NSString *)strFileName withExtension :(NSString *)strExtension;

/*
 功能：   播放系统声音
 输入参数：无，
 返回值：  无
 */

+ (void)playSystemSound;

/*
 功能：    启动和暂停扬声器
 输入参数：bOpen = TRUE启动扬声器,否则关闭扬声器
 返回值：  无
 */
+ (void)loudSpeaker:(BOOL)bOpen;

/*
 功能：    播放其他资源声音文件，例如mp3(对格式，大小没有限制)
 输入参数：strFileName 文件名（为后缀） strExtension：文件格式，nTimes：重复次数，bLoudSpeaker：是否开启扬声器。
 Ture为开启。 fVolume：播放的音量
 返回值：  无
 */
+ (void)playBigResourceSound:(NSString *)strFileName
              withExtension :(NSString *)strExtension
             withRepeatTimes:(int) nTimes
           playOnLoudSpeaker:(BOOL) bLoudSpeaker
                  withVolume:(float) fVolume;

/*
 功能：    获取手机卡类型
 输入参数：
 返回值：  手机卡类型
 */
+ (MCCType)getSimCardType;

//获取平台信息来确定手机型号
+ (NSString *)getPlatformInfo;

/*
 功能：    获取电话当前网络类型
 输入参数：无
 返回值：  当前网络状态
 */
+ (PhoneNetType)getCurrentPhoneNetType;

/*
 功能：   获取电话当前网络类型(返回字符串)
 输入参数：无
 返回值： 当前网络状态
 */
+ (NSString *)getCurrentPhoneNetMode;

@end
