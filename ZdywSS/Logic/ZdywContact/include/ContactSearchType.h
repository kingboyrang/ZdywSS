//
//  ContactSearchType.h
//  ContactManager
//
//  Created by mini1 on 13-6-6.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#ifndef ContactManager_ContactSearchType_h
#define ContactManager_ContactSearchType_h

#define kMaxSearchKeyHistory 16    //搜索键值栈的最大容量

typedef enum
{
    ContactDetailGroupNone = 0,
    ContactDetailGroupName,
    ContactDetailGroupPhoneNumber,
    ContactDetailGroupPinyin,
    ContactDetailGroupAcronym,
}enumContactDetailGroup;


//联系人搜索结果 结果体
struct ContactSearchResult
{
    unsigned int    nIndex;
    unsigned int    nPersonId;  // as ABRecordID
    char*           pszName;
    char*           pszPhoneNumber;
    char*           pszPinyin;
    char*           pszAcronym;
    
    double  nWeightName;
    double  nWeightPhone;
    double  nWeightPinyin;
    double  nWeightAcroym;
    
    struct ContactSearchResult* pNext;
};

struct SortedContactDetailInfo
{
    unsigned int                nIndex;
    unsigned int                nGroup;     // as enumContactDetailGroup
    const struct ContactSearchResult*   pRefContactInfo;
    unsigned int                nMatchKeyCount;
    unsigned int                nRange[kMaxSearchKeyHistory];    // the range index from ONE, not from ZERO!!!
};

//====================================================================
// list

struct ContactListContainer
{
    unsigned int nSize;
    unsigned int nTag;
    
    struct ContactSearchResult* pHead;
    struct ContactSearchResult* pTail;
    
};

struct ContactDetailListContainer
{
    unsigned int    nSize;
    unsigned int    nTag;
    unsigned int    nGroup;
    
    //struct SortedContactDetailInfo* pHead;
    //struct SortedContactDetailInfo* pTail;
    struct SortedContactDetailInfo** ppItemContact;
};

//====================================================================
// cache

struct ContactWithKey
{
    unsigned int    nIndex;
    unsigned int    nKey;
    unsigned int    nTag;
    
    struct ContactDetailListContainer*      nameSorted;
    struct ContactDetailListContainer*      phoneSorted;
    struct ContactDetailListContainer*      pinyinSorted;
    struct ContactDetailListContainer*      acronymSorted;
};

struct ContactWithChar
{
    unsigned int    nIndex;
    char            nChar;
    unsigned int    nTag;
    
    struct ContactDetailListContainer*      phoneSorted;
    struct ContactDetailListContainer*      pinyinSorted;
    struct ContactDetailListContainer*      acronymSorted;
};

//====================================================================
// total

struct InstancePackage
{
    unsigned int    nIndex;
    unsigned int    nTag;
    
    struct ContactListContainer allContacts;
    
    struct ContactWithKey       cache[10];
    
    unsigned int            nHistoryKeyPressCount;
    unsigned int            nHistoryKeyPress[kMaxSearchKeyHistory];
    struct ContactWithKey   historyObjectWithKey[kMaxSearchKeyHistory];
    
    struct ContactWithChar  historyObjectWithChar[kMaxSearchKeyHistory];
    struct ContactWithChar  allContactsForChar;
    
    struct InstancePackage* pNext;
    
};

#endif
