//
//  ContactType.h
//  ContactManager
//  联系人相关枚举类型
//  Created by mini1 on 13-6-4.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#ifndef ContactManager_ContactType_h
#define ContactManager_ContactType_h

#define kNotifyContactDataChanged @"allContactDataChanged"     //联系人的数据发生变化
#define kNotifyCommonContactDataChanged @"commonContactDataChanged" //常用联系人数据发生变化
#define kNotifyLoadContactDataBegin @"loadContactDataBegin"   //加载联系人开始
#define kNotifySearchLoadFinished  @"searchLoadFinished"     //搜索加载结束

#define kNotifyContactHeadChanged @"KNotifyContactHeadChanged" //联系人头像变化

#define kLastContactRecordStoreCount 3     //缓存最近通话记录的数量

//通话记录中时间转换格式
#define kContactRecordTimeFormatter @"yyyy-MM-dd:HH:mm:ss"

//联系人类型
typedef enum
{
    ContactTypeNormal = 0,   //通讯录联系人
    ContactTypeFriend,       //好友
}ContactType;

//电话号码类型
typedef enum
{
    ContactPhoneTypeMobile = 0,  //移动电话
    ContactPhoneTypeIphone,      //iphone
    ContactPhoneTypeHome,        //住宅电话
    ContactPhoneTypeWork,        //工作电话
    ContactPhoneTypeMain,        //主要电话
    ContactPhoneTypeHomeFax,     //住宅传真
    ContactPhoneTypeWorkFax,     //工作传真
    ContactPhoneTypeOtherFax,    //其他传真
    ContactPhoneTypeOtherNum,    //其他电话
}ContactPhoneType;

//邮箱类型
typedef enum
{
    ContactEmailTypeHome = 0,   //家庭邮箱
    ContactEmailTypeWork,       //工作邮箱
    ContactEmailTypeOther,      //其他邮箱
}ContactEmailType;

//地址类型
typedef enum
{
    ContactAddressTypeHome = 0,   //家庭地址
    ContactAddressTypeWork,       //工作地址
    ContactAddressTypeOther,      //其他地址
}ContactAddressType;

//社交账号类型
typedef enum
{
    SocialAccountTypeTwitter = 0,
    SocialAccountTypeFacebook,
    SocialAccountTypeFlickr,
    SocialAccountTypeLinkedIn,
    SocialAccountTypeMyspace,
    SocialAccountTypeOther,
}SocialAccountType;

//联系人性别
typedef enum
{
    ContactSexTypeMale = 0,
    ContactSexTypeFemale,
}ContactSexType;

//搜索方式
typedef enum
{
    ContactSearchTypeSmart = 0,    //精简搜索，只匹配姓名和电话
    ContactSearchTypeFull,
}ContactSearchType;

#define kInValidContactID   -999

#endif
