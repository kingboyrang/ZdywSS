//
//  T9SearchEngine.m
//  ContactManager
//
//  Created by mini1 on 13-6-6.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import "T9SearchEngine.h"
#include "ContactSearchType.h"
#include "ContactSearchUtils.h"

#import "ChineseToPinyin.h"
#import "T9ContactRecord.h"
#import "ContactNode.h"

@interface T9SearchEngine()

- (void)pushOneChar:(char)charPinyin;

//构建搜索数据
- (struct ContactListContainer)createListContainerWithDataSource:(NSArray *)dataList;

//获取某一种搜索方式的搜索结果 type索引的键值(0为acronymSorted、1为pinyinSort、2为nameSort 3为phoneSort)
- (unsigned int)getOneTypeSearchResultFromSource:(struct ContactDetailListContainer *)dataList
                                       dataCount:(unsigned int)nRealContactCount
                                       checkFlag:(char *)checkFlagBuffer
                                            type:(NSInteger)type;

//执行搜索
- (NSArray *)searchingWithNameList:(struct ContactDetailListContainer *)nameSorted
                         phoneList:(struct ContactDetailListContainer *)phoneSorted
                        pinyinList:(struct ContactDetailListContainer *)pinyinSorted
                       acronymList:(struct ContactDetailListContainer *)acronymSorted;

@end

@implementation T9SearchEngine
@synthesize mySearchResult = arrayResult;

-(id)init
{
    if( self = [super init] )
    {
        bIniting = NO;
        bInitSuccess = NO;
        bHasResult = NO;
        arrayResult = [[NSMutableArray alloc] initWithCapacity:2];
        return self;
    }
    else
    {
        return nil;
    }
}

-(void)dealloc
{
    self.mySearchResult = nil;
    bHasResult = NO;
    
    if( bIniting )
    {
        NSLog(@"T9SearchEngine is deallocing but is still bIniting...");
    }
    else
    {
        if( instance )
        {
            delete_contact_instance( instance );
            instance = nil;
        }
    }
}

//重置数据
- (void)resetData
{
    if (bInitSuccess && instance)
    {
        reset_key(instance);
    }
    
    bInitSuccess = NO;
    bIniting = YES;
    bTryToUseButNoInitSuccess = NO;
    
    [self.mySearchResult removeAllObjects];
    bHasResult = NO;
    
    if (instance)
    {
        delete_contact_instance(instance);
    }
    
    instance = create_contact_instance();
}

// 处理电话号码，去除多余的字符,'-' '(' ')' '+86'等，得到纯粹的，干净的号码
- (NSString *)dealWithPhoneNumber:(NSString *)strPhoneNumber
{
    NSString *strReault = [strPhoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    // 去掉'-'
    strReault = [strReault stringByReplacingOccurrencesOfString:@"-" withString:@""];
    // 去掉'('和')'
    strReault = [strReault stringByReplacingOccurrencesOfString:@"(" withString:@""];
    strReault = [strReault stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    return strReault;
}


/*
 函数描述：构建搜索数据
 输入参数：dataList   数据源
 输出参数：listContacts  搜索数据列表
 返 回 值：N/A
 作    者：刘斌
 */
- (struct ContactListContainer)createListContainerWithDataSource:(NSArray *)dataList
{
    NSInteger dataCount = [dataList count];
    
    struct ContactListContainer listContacts;
    memset( &listContacts, 0, sizeof(struct ContactListContainer));
    
    struct ContactSearchResult* pFakeHead = malloc(sizeof(struct ContactSearchResult));
    memset(pFakeHead, 0, sizeof(struct ContactSearchResult));
    pFakeHead->nIndex = 888888;
    pFakeHead->nPersonId = 888888;
    
    listContacts.pHead = pFakeHead;
    listContacts.pTail = pFakeHead;
    listContacts.nSize = dataCount;
    
    int index = 0;
    for (int i = 0; i < dataCount; ++i)
    {
        ContactNode *oneContact = (ContactNode *)[dataList objectAtIndex:i];
        
        NSString *strName = [[oneContact getContactFullName] stringByReplacingOccurrencesOfString:@" "
                                                                                       withString:@""];
        NSString* strPinyin = [ChineseToPinyin pinyinFromChiniseString:strName];
        NSString* strAcronym = [ChineseToPinyin acronymOfPinyingOfChineseString:strPinyin];
        
        //获取电话号码
        for (NSArray *aList in [oneContact.phoneDict allValues])
        {
            for (NSString *strPhone in aList)
            {
                NSString* strTelephone = [self dealWithPhoneNumber:strPhone];
                
                const char* pszName = [strName UTF8String];
                const char* pszPhoneNumber = [strTelephone UTF8String];
                
                const char* pszPinyin = [strPinyin UTF8String];
                const char* pszAcronym = [strAcronym UTF8String];
                
                NSInteger nPersonID = oneContact.contactID;
                
                struct ContactSearchResult* pNode = malloc(sizeof(struct ContactSearchResult));
                memset( pNode, 0, sizeof(struct ContactSearchResult) );
                {
                    pNode->nIndex = index;
                    pNode->nPersonId = nPersonID;
                    
                    if( pszName && strlen(pszName) > 0 )
                    {
                        pNode->pszName = malloc(strlen(pszName)+1);
                        memcpy( pNode->pszName, pszName, strlen(pszName)+1 );
                    }
                    else
                    {
                        pNode->pszName = NULL;
                    }
                    
                    if( pszPhoneNumber && strlen(pszPhoneNumber) > 0 )
                    {
                        pNode->pszPhoneNumber = malloc(strlen(pszPhoneNumber)+1);
                        memcpy( pNode->pszPhoneNumber, pszPhoneNumber, strlen(pszPhoneNumber)+1 );
                    }
                    else
                    {
                        pNode->pszPhoneNumber = NULL;
                    }
                    
                    if( pszPinyin && strlen(pszPinyin) > 0 )
                    {
                        pNode->pszPinyin = malloc(strlen(pszPinyin)+1);
                        memcpy( pNode->pszPinyin, pszPinyin, strlen(pszPinyin)+1 );
                    }
                    else
                    {
                        pNode->pszPinyin = NULL;
                    }
                    
                    if( pszAcronym && strlen(pszAcronym) > 0 )
                    {
                        pNode->pszAcronym = malloc(strlen(pszAcronym)+1);
                        memcpy( pNode->pszAcronym, pszAcronym, strlen(pszAcronym)+1 );
                    }
                    else
                    {
                        pNode->pszAcronym = NULL;
                    }
                    
                    pNode->nWeightName = calc_name_string_weight( pszName );
                    pNode->nWeightPhone = calc_phone_number_weight( pszPhoneNumber );
                    pNode->nWeightPinyin = calc_name_string_weight( pszPinyin );
                    pNode->nWeightAcroym = calc_name_string_weight( pszAcronym );
                    
                    pNode->pNext = NULL;
                }
                
                {
                    if( !pszName && !pszPhoneNumber && !pszPinyin && !pszAcronym )
                    {
                        //int nnnn = 0;
                    }
                }
                
                listContacts.pTail = pNode;
                
                pFakeHead->pNext = pNode;
                pFakeHead = pNode;
                
                ++index;
            }
        }
    }
    
    return listContacts;
}

/*
 函数描述：加载搜索数据源
 输入参数：dataList   数据源
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)reloadDataSource:(NSArray *)dataList
{
    if (bIniting)
    {
        NSLog(@"------load search 2-----");
        return;
    }
    
    [self resetData];
    
    NSInteger dataCount = [dataList count];
    if (dataCount <= 0)
    {
        bInitSuccess = YES;
        bIniting = NO;
        return;
    }
    
    if (instance)
    {
        struct ContactListContainer listContacts = [self createListContainerWithDataSource:dataList];
        
        int nInit = init_contacts( instance, &listContacts );
        
        release_contact_list_object( &listContacts );
        
        if( 0 == nInit )
        {
            // success
        }
    }
    
    bInitSuccess = YES;
    bIniting = NO;
}

/*
 函数描述：重新加载搜索数据源
 输入参数：dataList   数据源
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)reloadDataSourceForSearchOnly:(NSArray *)dataList
{
    if( bIniting )
    {
        NSLog(@"------load search 1-----");
        return;
    }
    [self resetData];
    
    NSInteger dataCount = [dataList count];
    if (dataCount <= 0)
    {
        bInitSuccess = YES;
        bIniting = NO;
        return;
    }
    
    if (instance)
    {
        struct ContactListContainer listContacts = [self createListContainerWithDataSource:dataList];
        
        int nInit = init_contacts_for_search_only( instance, &listContacts );
        
        release_contact_list_object( &listContacts );
        
        if( 0 == nInit )
        {
            // success
        }
    }
    
    bInitSuccess = YES;
    bIniting = NO;
}

/*
 函数描述：搜索键入栈
 输入参数：key   键值(0~9)
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)pushOneKey:(NSInteger)key
{
    if( instance )
    {
        if( bInitSuccess )
        {
            if( bTryToUseButNoInitSuccess )
            {
                // no to do anything.
            }
            else
            {
                push_key(instance,key);
                
                [self.mySearchResult removeAllObjects];
                bHasResult = NO;
            }
        }
        else
        {
            bTryToUseButNoInitSuccess = YES;
        }
    }
}

/*
 函数描述：搜索键出栈
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)popOneKey
{
    if( instance )
    {
        if( bInitSuccess )
        {
            if( bTryToUseButNoInitSuccess )
            {
                // no to do anything.
            }
            else
            {
                pop_key(instance);
                
                [self.mySearchResult removeAllObjects];
                bHasResult = NO;
            }
        }
        else
        {
            bTryToUseButNoInitSuccess = YES;
        }
    }
}

/*
 函数描述：重置搜索键值栈
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)resetKey
{
    if( instance )
    {
        bTryToUseButNoInitSuccess = NO;
        if( bInitSuccess )
        {
            reset_key(instance);
            
            [self.mySearchResult removeAllObjects];
            bHasResult = NO;
        }
    }
}

/*
 函数描述：获取某一种搜索方式的搜索结果
 输入参数：dataList            待搜索的数据源
         nRealContactCount   待搜索的数据量
         checkFlagBuff       搜索标志位
 输出参数：N/A
 返 回 值：unsigned int    搜索到的结果个数
 作    者：刘斌
 */
- (unsigned int)getOneTypeSearchResultFromSource:(struct ContactDetailListContainer *)dataList
                                       dataCount:(unsigned int)nRealContactCount
                                       checkFlag:(char *)checkFlagBuffer
                                            type:(NSInteger)type
{
    int nItemCount = 0;
    if(dataList)
    {
        const struct ContactDetailListContainer* pList = dataList;
        for( unsigned int i=0; i<pList->nSize; ++i )
        {
            const struct SortedContactDetailInfo* pNode = *( pList->ppItemContact + i );
            
            const struct ContactSearchResult* pInfo = pNode ? pNode->pRefContactInfo : NULL;
            if( pInfo )
            {
                unsigned int nIndex = pInfo->nIndex;
                if( nIndex > nRealContactCount )
                {
                    printf("acronymSorted WHY nIndex > nRealContactCount? %d %d", nIndex, nRealContactCount);
                }
                
                if( *(checkFlagBuffer+nIndex) )
                {
                    // already in.
                }
                else
                {
                    switch (type)
                    {
                        case 0:
                        {
                            if (pInfo->pszName && pInfo->pszAcronym)
                            {
                                NSString* strPersonName = [NSString stringWithUTF8String:pInfo->pszName];
                                NSString* strPersonAcroym = [NSString stringWithUTF8String:pInfo->pszAcronym];
                                NSString* strPersonPinyin = [NSString stringWithUTF8String:pInfo->pszPinyin];
                                
                                NSRange rangeMatch;
                                rangeMatch.location = pNode->nRange[0] - 1;
                                rangeMatch.length = pNode->nMatchKeyCount;
                                
                                T9ContactRecord* newItem = [[T9ContactRecord alloc] initWithIndex:nItemCount
                                                                                       abRecordID:pInfo->nPersonId
                                                                                      searchGroup:pNode->nGroup
                                                                                             name:strPersonName
                                                                                            value:strPersonAcroym
                                                                                  pinyinOfAcronym:strPersonPinyin
                                                                                            range:rangeMatch];
                                [self.mySearchResult addObject:newItem];
                                nItemCount++;
                                *(checkFlagBuffer+nIndex) = 1;
                            }
                        }
                            break;
                        case 1:
                        {
                            if( pInfo->pszName && pInfo->pszPinyin )
                            {
                                NSString* strPersonName = [NSString stringWithUTF8String:pInfo->pszName];
                                NSString* strPersonPinyin = [NSString stringWithUTF8String:pInfo->pszPinyin];
                                
                                NSRange rangeMatch;
                                rangeMatch.location = pNode->nRange[0] - 1;
                                rangeMatch.length = pNode->nMatchKeyCount;
                                
                                T9ContactRecord* newItem = [[T9ContactRecord alloc] initWithIndex:nItemCount
                                                                                       abRecordID:pInfo->nPersonId
                                                                                      searchGroup:pNode->nGroup
                                                                                             name:strPersonName
                                                                                            value:strPersonPinyin
                                                                                  pinyinOfAcronym:strPersonPinyin
                                                                                            range:rangeMatch];
                                [self.mySearchResult addObject:newItem];
                                nItemCount++;
                                *(checkFlagBuffer+nIndex) = 1;
                            }
                        }
                            break;
                        case 2:
                        {
                            if( pInfo->pszName && pInfo->pszPhoneNumber )
                            {
                                NSString* strPersonName = [NSString stringWithUTF8String:pInfo->pszName];
                                NSString* strPersonPhoneNumber = [NSString stringWithUTF8String:pInfo->pszPhoneNumber];
                                
                                NSRange rangeMatch;
                                rangeMatch.location = pNode->nRange[0] - 1;
                                rangeMatch.length = pNode->nMatchKeyCount;
                                
                                T9ContactRecord* newItem = [[T9ContactRecord alloc] initWithIndex:nItemCount
                                                                                       abRecordID:pInfo->nPersonId
                                                                                      searchGroup:pNode->nGroup
                                                                                             name:strPersonName
                                                                                            value:strPersonPhoneNumber
                                                                                  pinyinOfAcronym:strPersonPhoneNumber
                                                                                            range:rangeMatch];
                                [self.mySearchResult addObject:newItem];
                                nItemCount++;
                                *(checkFlagBuffer+nIndex) = 1;
                            }
                        }
                            break;
                        case 3:
                        {
                            if( pInfo->pszName && pInfo->pszPhoneNumber )
                            {
                                NSString* strPersonName = [NSString stringWithUTF8String:pInfo->pszName];
                                NSString* strPersonPhoneNumber = [NSString stringWithUTF8String:pInfo->pszPhoneNumber];
                                
                                NSRange rangeMatch;
                                rangeMatch.location = pNode->nRange[0] - 1;
                                rangeMatch.length = pNode->nMatchKeyCount;
                                
                                T9ContactRecord* newItem = [[T9ContactRecord alloc] initWithIndex:nItemCount
                                                                                       abRecordID:pInfo->nPersonId
                                                                                      searchGroup:pNode->nGroup
                                                                                             name:strPersonName
                                                                                            value:strPersonPhoneNumber
                                                                                  pinyinOfAcronym:strPersonPhoneNumber
                                                                                            range:rangeMatch];
                                [self.mySearchResult addObject:newItem];
                                
                                nItemCount++;
                                *(checkFlagBuffer+nIndex) = 1;
                            }
                        }
                            break;
                            
                        default:
                            break;
                    }
                }
            }
            //pNode = pNode->pNext;
        }
    }
    
    return nItemCount;
}

- (NSArray *)searchingWithNameList:(struct ContactDetailListContainer *)nameSorted
                         phoneList:(struct ContactDetailListContainer *)phoneSorted
                        pinyinList:(struct ContactDetailListContainer *)pinyinSorted
                       acronymList:(struct ContactDetailListContainer *)acronymSorted
{
    unsigned int nTotalSize = 0;
    
    if( acronymSorted )
    {
        nTotalSize += acronymSorted->nSize;
    }
    if( pinyinSorted )
    {
        nTotalSize += pinyinSorted->nSize;
    }
    if( nameSorted )
    {
        nTotalSize += nameSorted->nSize;
    }
    if( phoneSorted )
    {
        nTotalSize += phoneSorted->nSize;
    }
    
    if( nTotalSize > 0 )
    {
        unsigned int nRealContactCount = get_real_contact_count(instance);
        char* checkFlagBuffer = malloc(nRealContactCount+1);
        memset( checkFlagBuffer, 0, nRealContactCount+1 );
        
        [self.mySearchResult removeAllObjects];
        bHasResult = YES;
        unsigned int nItemCount = 0;
        
        // be care of the order!!! and the acronym is different from others.
        
        // acronym
        if( acronymSorted )
        {
            nItemCount += [self getOneTypeSearchResultFromSource:acronymSorted
                                                       dataCount:nRealContactCount
                                                       checkFlag:checkFlagBuffer
                                                            type:0];
        }
        
        // pinyin
        if( pinyinSorted )
        {
            nItemCount += [self getOneTypeSearchResultFromSource:pinyinSorted
                                                       dataCount:nRealContactCount
                                                       checkFlag:checkFlagBuffer
                                                            type:1];
        }
        
        // name
        if( nameSorted )
        {
            nItemCount += [self getOneTypeSearchResultFromSource:nameSorted
                                                       dataCount:nRealContactCount
                                                       checkFlag:checkFlagBuffer
                                                            type:2];
        }
        
        // phone
        if( phoneSorted )
        {
            nItemCount += [self getOneTypeSearchResultFromSource:phoneSorted
                                                       dataCount:nRealContactCount
                                                       checkFlag:checkFlagBuffer
                                                            type:3];
        }
        
        free(checkFlagBuffer);
        
        return arrayResult;
        //NSLog( @"search index:%d result:%d ", pResult->nIndex, [arrayResult count] );
    }
    
    return nil;
}

/*
 函数描述：获取搜索结果
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSArray   搜索结果
 作    者：刘斌
 */
- (NSArray *)getSearchResult
{
    if( instance && bInitSuccess )
    {
        if(bHasResult)
        {
            return arrayResult;
        }
        else
        {
            const struct ContactWithKey *pResult = get_keypress_result(instance);
            if (NULL == pResult)
            {
                return nil;
            }
            return [self searchingWithNameList:pResult->nameSorted
                                     phoneList:pResult->phoneSorted
                                    pinyinList:pResult->pinyinSorted
                                   acronymList:pResult->acronymSorted];
        }
    }
    else
    {
        return nil;
    }
    
}

/*
 函数描述：根据匹配字符串获取搜索结果
 输入参数：strSearchText    匹配字符串
 输出参数：N/A
 返 回 值：NSArray   搜索结果
 作    者：刘斌
 */
- (NSArray*)searchTextOnly:(NSString*)strSearchText
{
    if( instance && bInitSuccess && strSearchText && [strSearchText length] > 0 )
    {
        NSString* strPinyin = [ChineseToPinyin pinyinFromChiniseString:strSearchText];
        if ([strPinyin length] > 14) {
            strPinyin = [strPinyin substringToIndex:14];
        }
        NSString *strUtf8 = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)strPinyin, NULL, NULL,  kCFStringEncodingUTF8 ));
        if ([strUtf8 length]>14) {
            return nil;
        }
        if( strPinyin && [strPinyin length] > 0 )
        {
            const char* pszPinyin = [strPinyin UTF8String];
            
            if( pszPinyin )
            {
                [self resetKey];
                
                while (*pszPinyin)
                {
                    [self pushOneChar:*pszPinyin];
                    pszPinyin++;
                }
                
                const struct ContactWithChar *pResult = get_charpress_result(instance);
                if (pResult == nil) {
                    return nil;
                }
                return [self searchingWithNameList:NULL
                                         phoneList:pResult->phoneSorted
                                        pinyinList:pResult->pinyinSorted
                                       acronymList:pResult->acronymSorted];
            }
        }
    }
    
    return nil;
}

- (void)pushOneChar:(char)charPinyin
{
    if( instance && bInitSuccess )
    {
        push_one_char(instance, charPinyin);
    }
}

@end
