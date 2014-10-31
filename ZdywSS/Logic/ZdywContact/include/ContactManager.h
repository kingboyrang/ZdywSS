//
//  ContactManager.h
//  ContactManager
//
//  Created by mini1 on 13-6-5.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactNode.h"
#import <UIKit/UIKit.h>
#import "T9SearchEngine.h"
#import "RecordEngine.h"
#import "CommonContactEngine.h"
#import "RecordMegerNode.h"
#import "DeskContactEngine.h"
#import "PhoneOnwerShipEngine.h"
#import <AddressBook/AddressBook.h>

@interface ContactManager : NSObject
{
    NSMutableDictionary        *_allContactDict;    //用来存放所有的联系人
    NSMutableDictionary        *_sortContactDict;   //所有联系人已经分好区排序
    NSMutableArray             *_sortKeyList;       //所有联系人的分区列表
    NSMutableArray             *_commonContactIDList; //常用联系人ID列表(已排序)
    NSMutableDictionary        *_phoneRelationDict;   //联系人电话与ID对应的关系(以电话号码作为key，联系人集合作为value）
    NSMutableDictionary        *_contactHeadDict;   //联系人头像
    
    BOOL                       _loadContactFlag;   //联系人在刷新或加载的标识
    BOOL                       _loadSearchEngineFlag; //加载搜索引擎的标识
    NSCondition                *_contactLoadCondition;
    
    ABAddressBookRef           _myAddressBookHandle;
    T9SearchEngine             *_mySearchEngine;      //T9字符搜索引擎
    T9SearchEngine             *_myKeySearchEngine;   //T9键搜索引擎
    RecordEngine               *_myRecordEngine;      //通话记录引擎
    CommonContactEngine        *_myCommonContactEngine; //常用联系人引擎
    DeskContactEngine          *_myDeskContactEngine;  //联系人快捷方式引擎
    PhoneOnwerShipEngine       *_myPhoneOwnerShipEngine; //号码归属地引擎
    NSTimer                    *_refreshTimer;           //刷新计时器
    BOOL                       _isDataChanged;           //数据有变化
    
    //dispatch_queue_t            _loadHeadQueue;          //加载联系人的线程
    NSOperationQueue           *_loadHeadQueue;         //加载联系人的线程
}

@property(nonatomic,retain,readonly) NSMutableDictionary *allContactDict;
@property(nonatomic,retain,readonly) NSMutableDictionary *sortContactDict;
@property(nonatomic,retain,readonly) NSMutableArray      *sortKeyList;
@property(nonatomic,retain,readonly) NSMutableArray      *commonContactIDList;
@property(nonatomic,retain,readonly) RecordEngine        *myRecordEngine;
@property(nonatomic,retain,readonly) CommonContactEngine *myCommonContactEngine;
@property(nonatomic,retain)          DeskContactEngine   *myDeskContactEngine;
@property(nonatomic,retain,readonly) PhoneOnwerShipEngine *myPhoneOwnerShipEngine;
@property(nonatomic,readonly) ABAddressBookRef    myAddressBookHandle;
@property(nonatomic,assign) BOOL                  canLoadData;
@property(nonatomic,assign,readonly) BOOL loadContactFlag;

/*
 函数描述：单列
 输入参数：N/A
 输出参数：N/A
 返 回 值：ContactManager   单例对象
 作    者：刘斌
 */
+ (ContactManager *)shareInstance;

/*
 函数描述：创建用户数据库
 输入参数：userID
 输出参数：N/A
 返 回 值：BOOL   成功与否
 作    者：刘斌
 */
- (BOOL)createUserDataBaseWithUserID:(NSString *)userID;

/*
 函数描述：加载联系人
 输入参数：N/A
 输出参数：N/A
 返 回 值：BOOL   是否可以加载
 作    者：刘斌
 */
- (BOOL)loadAllContact;

/*
 函数描述：获取排序后的联系人列表
 输入参数：removeList : 删除的联系人ID列表
 输出参数：sList      : 排序索引的key
 返 回 值：NSDictionary   处理后的联系人排序列表
 作    者：刘斌
 */
- (NSDictionary *)getSortContactDictAfterRemoveList:(NSArray *)removeList
                                 outWithSortKeyList:(NSMutableArray **)sList;

/*
 函数描述：通讯录是否鉴权
 输入参数：isCompleteBlock  是否弹出设置框
 输出参数：N/A
 返 回 值：BOOL   是否可以鉴权了
 作    者：刘斌
 */
- (BOOL)addressBookIsAuthentication:(BOOL)isCompleteBlock;

/*
 函数描述：根据联系人ID获取联系人的信息
 输入参数：contactID   联系人ID
 输出参数：N/A
 返 回 值：ContactNodel   联系人信息
 作    者：刘斌
 */
- (ContactNode *)getOneContactByID:(NSInteger)contactID;

/*
 函数描述：根据联系人ID获取通讯录联系人的信息
 输入参数：contactID   联系人ID
 输出参数：N/A
 返 回 值：ABRecordRef   联系人信息
 作    者：刘斌
 */
- (ABRecordRef)getOneABRecordWithID:(NSInteger)contactID;

/*
 函数描述：删除联系人
 输入参数：contactID  联系人的ID
 输出参数：N/A
 返 回 值：BOOL       是否删除成功
 作    者：刘斌
 */
- (BOOL)deleteOneContactByID:(NSInteger)contactID;

/*
 函数描述：修改或修改联系人
 输入参数：aContact 新的联系人信息
 输出参数：N/A
 返 回 值：BOOL   是否成功
 作    者：刘斌
 */
- (BOOL)updateOneContact:(ContactNode *)aContact;

/*
 函数描述：获取联系人备份的json字符串
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSString   json字符串
 作    者：刘斌
 */
- (NSString *)getRecoveryJsonString;

/*
 函数描述：根据电话号码匹配联系人
 输入参数：phoneNum    电话号码
 输出参数：N/A
 返 回 值：ContactNode   联系人信息
 作    者：刘斌
 */
- (ContactNode *)contactInfoWithPhone:(NSString *)phoneNum;

/*
 函数描述：清空联系人缓存
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)clearContactHeadCache;

/*
 函数描述：根据联系人ID获取联系人头像
 输入参数：contactID  联系人的ID
 输出参数：N/A
 返 回 值：UIImage   联系人头像
 作    者：刘斌
 */
- (UIImage *)contactHeadWithContactID:(NSInteger)contactID;

#pragma mark - Search
/*
 函数描述：初始化搜索引擎
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)startSearchEngine;

/*
 函数描述：增加一个搜索键
 输入参数：NSInteger   搜索键（0~9）
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)pushOneKey:(NSInteger)aKey;

/*
 函数描述：弹出最后一个搜索键
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)popOneKey;

/*
 函数描述：重置搜索键
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)resetKey;

/*
 函数描述：根据匹配字符串搜索(T9ContactRecord对象集合）
 输入参数：strSearchText    匹配的字符串
 输出参数：N/A
 返 回 值：NSArray         搜索结果
 作    者：刘斌
 */
- (NSArray *)searchResultWithText:(NSString *)strSearchText;

/*
 函数描述：根据匹配字符串获取搜索结果
 输入参数：strSearchText    匹配字符串
 rList             不在搜索范围内的联系人ID集合（NSNumber对象)
 输出参数：N/A
 返 回 值：NSArray   搜索结果
 作    者：刘斌
 */
- (NSArray*)searchResultWithText:(NSString*)strSearchText removeList:(NSArray *)rList;

/*
 函数描述：获取搜索结果(T9ContactRecord对象集合）
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSArray         搜索结果
 作    者：刘斌
 */
- (NSArray *)searchResult;

/*
 函数描述：获取搜索结果
 输入参数： rList       不在搜索范围内的联系人ID集合（NSNumber对象)
 输出参数：N/A
 返 回 值：NSArray   搜索结果
 作    者：刘斌
 */
- (NSArray*)searchResultWithRemoveList:(NSArray *)rList;

#pragma mark - 常用联系人
/*
 函数描述：提取常用联系人
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)pickUpCommonContact;

/*
 函数描述：刷新常用联系人
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)refreshCommonContact;

/*
 函数描述：是否为常用联系人
 输入参数：contactID   联系人ID
 输出参数：N/A
 返 回 值：BOOL   是否为常用联系人
 作    者：刘斌
 */
- (BOOL)isCommonContactWithID:(NSInteger)contactID;

#pragma mark - 通话记录
/*
 函数描述：合并通话记录
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSArray   RecordMegerNode集合
 作    者：刘斌
 */
- (NSArray *)megerContactRecord;

#pragma mark - 备份恢复
/*
 函数描述：恢复联系人
 输入参数：jsonDataList 联系人json数据列表 
 recoverType  恢复类型 0 完全覆盖本地数据 1与本地数据合并
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)recoveryContactWithDataList:(NSArray *)jsonDataList recoveryType:(NSUInteger)recoveryType;

#pragma mark - 通用
/*
 函数描述：去掉电话号码中的特殊字符
 输入参数：phoneNumber 电话号码
 countryCode 00开头的国家吗(如:0086)
 输出参数：N/A
 返 回 值：NSString   处理后的电话号码
 作    者：刘斌
 */
- (NSString *)deleteCountryCodeFromPhoneNumber:(NSString *)phoneNumber countryCode:(NSString *)countryCode;

/*
 函数描述：为电话号码加上国家吗
 输入参数：phoneNumber 电话号码
 countryCode 00开头的国家吗(如:0086)
 输出参数：N/A
 返 回 值：NSString   处理后的电话号码
 作    者：刘斌
 */
- (NSString *)addCountryCodeForPhoneNumber:(NSString *)phoneNumber countryCode:(NSString *)countryCode;

/*
 函数描述：获取电话号码的归属地
 输入参数：phoneNumber 电话号码
 countryCode 00开头的国家吗(如:0086)
 输出参数：N/A
 返 回 值：NSString   号码归属地
 作    者：刘斌
 */
- (NSString *)phoneAttributionWithPhoneNumber:(NSString *)phoneNumber countryCode:(NSString *)countryCode;

/*
 函数描述：获取中国电话号码的区号
 输入参数：phoneNumber 电话号码
 输出参数：N/A
 返 回 值：NSString   区号
 作    者：刘斌
 */
- (NSString *)phoneZoneWithPhoneNumber:(NSString *)phoneNumber;

/*
 函数描述：获取号码运营商
 输入参数：phoneNumber      电话号码
 isChina          是否为中国号码
 输出参数：N/A
 返 回 值:NSString     运营商名称
 作    者：丁大敏
 */

- (NSString *)PhoneOperatorsWithPhoneNumber:(NSString *)phoneNumber;

@end
