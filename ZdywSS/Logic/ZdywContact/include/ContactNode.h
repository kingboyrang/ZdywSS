//
//  ContactNode.h
//  ContactManager
//  联系人实体，存放联系人相关信息
//  Created by mini1 on 13-6-4.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactType.h"
#import <AddressBook/AddressBook.h>
#import "ContactAddressNode.h"

@interface ContactNode : NSObject

@property(nonatomic,assign) NSInteger             contactID;         //联系人ID，同通讯录中的personID
@property(nonatomic,retain) NSMutableDictionary   *groupDict;        //分组的信息，以分组ID为Key
@property(nonatomic,retain) NSString              *firstName;
@property(nonatomic,retain) NSString              *middleName;
@property(nonatomic,retain) NSString              *lastName;
@property(nonatomic,retain) NSString              *nickName;
@property(nonatomic,retain) NSString              *firstPinyin;    //firstName拼音
@property(nonatomic,retain) NSString              *middlepinyin;   //middleName拼音
@property(nonatomic,retain) NSString              *lastPinyin;     //lastName拼音

@property(nonatomic,retain) NSMutableDictionary   *phoneDict;      //电话号码，以电话类型为key
@property(nonatomic,retain) NSMutableArray        *phoneList;      //联系人电话
@property(nonatomic,retain) NSMutableDictionary   *emailDict;      //邮箱地址，以邮箱为key
@property(nonatomic,retain) NSMutableDictionary   *socialDict;     //社交账号，以账号类型为key

@property(nonatomic,retain) NSMutableDictionary   *addressDict;    //地址，ContactAddress集合

@property(nonatomic,retain) NSString              *companyName;    //公司名称
@property(nonatomic,retain) NSString              *departmentName; //部门名称
@property(nonatomic,retain) NSString              *positionName;   //职位

@property(nonatomic,assign) ContactSexType        sex;             //性别
@property(nonatomic,retain) NSDate                *birthday;       //生日
@property(nonatomic,retain) NSData                *photoData;


/*
 函数描述：获取联系人的全名称
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSString   联系人全名称
 作    者：刘斌
 */
- (NSString *)getContactFullName;

/*
 函数描述：获取联系人分区的键值
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSString   A-Z #中的一个键值
 作    者：刘斌
 */
- (NSString *)getContactSortKey;

/*
 函数描述：根据名字与其他联系人比较
 输入参数：otherContact : 其他联系人
 输出参数：N/A
 返 回 值：int   比较结果 1：排在前面 0 相等 -1 小于
 作    者：刘斌
 */
- (int)compareBynameWithOther:(ContactNode *)otherContact;

/*
 函数描述：根据联系人创建json字符串
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSString   json字符串
 作    者：刘斌
 */
- (NSString *)createJsonString;

/*
 函数描述：是否包含另一联系人的所有电话号码
 输入参数：otherContact : 其他联系人
 输出参数：N/A
 返 回 值：BOOL   是否包含
 作    者：刘斌
 */
- (BOOL)isContainsAllPhoneInOthers:(ContactNode *)otherContact;

/*
 函数描述：合并另一联系人的不同的电话号码
 输入参数：otherContact : 其他联系人
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)megerOtherContactPhones:(ContactNode *)otherContact;

/*
 函数描述：根据地址本联系人信息创建数据
 输入参数：onePerson : 地址本联系人
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)createContactDataWithPerson:(ABRecordRef)onePerson;

/*
 函数描述：将数据插入到地址本的联系人中
 输入参数：N/A
 输出参数：onePerson : 地址本联系人
 返 回 值：N/A
 作    者：刘斌
 */
- (void)insertDataIntoPerson:(ABRecordRef)onePerson;

/*
 函数描述：获取所有联系人的电话号码
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSArray   电话号码集合
 作    者：刘斌
 */
- (NSArray *)contactAllPhone;

/*
 函数描述：联系人是否包含某个号码
 输入参数：strPhone   待判断的号码
 输出参数：N/A
 返 回 值：BOOL   是否包含
 作    者：刘斌
 */
- (BOOL)containsPhoneNumber:(NSString *)strPhone;

/*
 函数描述：根据json数据构建联系人数据
 输入参数：jsonDict   联系人信息
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)createContactDataWithJsonDict:(NSDictionary *)jsonDict;

@end
