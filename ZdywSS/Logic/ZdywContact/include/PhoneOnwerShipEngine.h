//
//  PhoneOnwerShipEngine.h
//  ContactManager
//  号码归属地引擎
//  Created by mini1 on 13-6-8.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhoneOnwerShipEngine : NSObject
{
    NSMutableArray          *_phoneAreaList;         //  号码段列表
    NSMutableArray          *_chineseArealList;    //  地名段列表(国内)
    NSMutableArray          *_interArealList;  //  地名段列表(国际)
    NSMutableArray          *_recordSectionList;     //  号码段分区列表
    
    NSOperationQueue        *queue;                  //  操作队列，就相当于一个线程管理器
    BOOL                    _bLoadDataFinished;       //  是否已经加载数据完成
    BOOL                    _bLoadDataing;            //  是否正在加载数据中
}

@property(nonatomic,assign) BOOL bLoadDataFinished;
@property(nonatomic,assign) BOOL bLoadDataing;

/*
 函数描述：从文件中读取数据
 输入参数：filePath      文件路径
 输出参数：N/A
 返 回 值:N/A
 作    者：刘斌
 */
- (void)loadDataWithFilePath:(NSString *)filePath;

/*
 函数描述：获取号码运营商
 输入参数：phoneNumber      电话号码
 isChina          是否为中国号码
 输出参数：N/A
 返 回 值:NSString     运营商名称
 作    者：丁大敏
 */
- (NSString *)getPhoneOperatorsWithNumber:(NSString *)phoneNumber;

/*
 函数描述：获取号码归属地
 输入参数：phoneNumber      电话号码
         isChina          是否为中国号码
 输出参数：N/A
 返 回 值:NSString     归属地名称
 作    者：刘斌
 */
- (NSString *)getPhoneOnwerShipWithNumber:(NSString *)phoneNumber isChineseNumber:(BOOL)isChina;

/*
 函数描述：获取电话号码区号
 输入参数：phoneNumber      电话号码
         isChina          是否为中国号码
 输出参数：N/A
 返 回 值:NSString     区号
 作    者：刘斌
 */
- (NSString *)getCityCode:(NSString *)phoneNumber isChineseNumber:(BOOL)isChina;

@end
