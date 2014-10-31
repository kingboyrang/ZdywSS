//
//  ContactSearchUtils.c
//  ContactManager
//
//  Created by mini1 on 13-6-6.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ContactSearchType.h"
#include "ContactSearchUtils.h"

#define COMPARE_STRING_GREATER  (1)
#define COMPARE_STRING_SAME     (0)
#define COMPARE_STRING_LESS     (-1)

//================================================================================

struct PackageList
{
    unsigned int    nSize;
    unsigned int    nTag;
    
    struct InstancePackage* pHead;
    struct InstancePackage* pTail;
};

struct PackageList* allContactInstances = NULL;

//================================================================================
// release struct objects forward declare

int release_package_list( struct PackageList* pPacket );

int release_instance_package( struct InstancePackage* pInstance );

int release_contact_list_object( struct ContactListContainer* pContacts);
int release_contact_with_key_object( struct ContactWithKey* pObject );
int release_contact_with_char_object( struct ContactWithChar* pContactObject );

int release_contact_detail_list_object( struct ContactDetailListContainer* nameSorted );
int release_contact_detail_info_object( struct SortedContactDetailInfo* pHead );

int release_contact_info_object( struct ContactSearchResult* pHead );

int dupe_contact_info_object( const struct ContactSearchResult* pSrc, struct ContactSearchResult* pDst );
int dupe_contact_with_key_list( struct ContactWithKey* pListSrc, struct ContactWithKey* pListDst );
int dupe_contact_detail_list( struct ContactDetailListContainer* pListSrc, struct ContactDetailListContainer* pListDst );

//================================================================================

int rebuild_contacts_detail(unsigned int nGroup,
                            const struct ContactListContainer* pContactsList,
                            struct ContactDetailListContainer* pDetailList );

int sort_contacts_detail(unsigned int nGroup, struct ContactDetailListContainer* pDetailList );
int quick_sort_contacts_detail(unsigned int nGroup, struct ContactDetailListContainer* pDetailList );
int quick_sort_detail(unsigned int nGroup, struct SortedContactDetailInfo** ppHead, unsigned int nLeft, unsigned int nRight );

int buildup_cache_for_key( unsigned int nKey, const struct ContactWithKey* pSrc, struct ContactWithKey* pDst );
int buildup_all_contacts_for_char( const struct ContactWithKey* pSrc, struct ContactWithChar* pDst );

int buildup_detail_cache_for_key(unsigned int nGroup,
                                 unsigned int nKey,
                                 const struct ContactDetailListContainer* pSrcDetail,
                                 struct ContactDetailListContainer* pDstDetail );

int buildup_detail_cache_for_char(unsigned int nGroup,
                                  char nChar,
                                  const struct ContactDetailListContainer* pSrcDetail,
                                  struct ContactDetailListContainer* pDstDetail );

int is_key_match_char( unsigned int nKey , char chTest );
int is_first_key_match_char( unsigned int nKey , char chTest );

int is_char_match_char( char nChar, char chTest );

//================================================================================
// release struct objects

int release_package_list( struct PackageList* pPacketList )
{
    int nRet = 0;
    
    if( pPacketList )
    {
        struct InstancePackage* pNode = pPacketList->pHead;
        while( pNode )
        {
            struct InstancePackage* pNext = pNode->pNext;
            release_instance_package(pNode);
            free(pNode);
            pNode = pNext;
        }
    }
    
    return nRet;
}

int release_instance_package( struct InstancePackage* pInstance )
{
    int nRet = -1;
    
    if( pInstance )
    {
        release_contact_list_object( &(pInstance->allContacts) );
        memset( &(pInstance->allContacts), 0, sizeof(struct ContactListContainer) );
        
        release_contact_with_char_object( &(pInstance->allContactsForChar) );
        memset( &(pInstance->allContactsForChar), 0, sizeof(struct ContactWithChar) );
        
        for( unsigned int i=0; i<10; ++i )
        {
            release_contact_with_key_object( &(pInstance->cache[i]) );
            memset( &(pInstance->cache[i]), 0, sizeof( struct ContactWithKey) );
        }
        
        for( unsigned int i=0; i< kMaxSearchKeyHistory; ++i )
        {
            release_contact_with_key_object( &(pInstance->historyObjectWithKey[i]) );
            memset( &(pInstance->historyObjectWithKey[i]), 0, sizeof( struct ContactWithKey) );
            release_contact_with_char_object( &(pInstance->historyObjectWithChar[i]) );
            memset( &(pInstance->historyObjectWithChar[i]), 0, sizeof( struct ContactWithChar) );
        }
        
        pInstance->nHistoryKeyPressCount = 0;
        for( unsigned int i=0; i < kMaxSearchKeyHistory; ++i )
        {
            pInstance->nHistoryKeyPress[i] = 0;
        }
        
        nRet = 0;
    }
    
    return nRet;
}

int release_contact_list_object( struct ContactListContainer* pContacts)
{
    int nRet = 0;
    if( pContacts )
    {
        struct ContactSearchResult* pNode = pContacts->pHead;
        while ( pNode )
        {
            struct ContactSearchResult* pNext = pNode->pNext;
            release_contact_info_object(pNext);
            free(pNext);
            
            pNode = pNext;
        }
        
        pContacts->pHead = NULL;
        pContacts->pTail = NULL;
        pContacts->nSize = 0;
    }
    return nRet;
}

int release_contact_with_char_object( struct ContactWithChar* pContactObject )
{
    int nRet = 0;
    if( pContactObject )
    {
        if( pContactObject->phoneSorted )
        {
            release_contact_detail_list_object( pContactObject->phoneSorted );
            free( pContactObject->phoneSorted );
        }
        
        if( pContactObject->pinyinSorted )
        {
            release_contact_detail_list_object( pContactObject->pinyinSorted );
            free( pContactObject->pinyinSorted );
        }
        
        if( pContactObject->acronymSorted )
        {
            release_contact_detail_list_object( pContactObject->acronymSorted );
            free( pContactObject->acronymSorted );
        }
        
        pContactObject->phoneSorted = NULL;
        pContactObject->pinyinSorted = NULL;
        pContactObject->acronymSorted = NULL;
    }
    return nRet;
}

int release_contact_with_key_object( struct ContactWithKey* pContactObject )
{
    int nRet = 0;
    if( pContactObject )
    {
        if( pContactObject->nameSorted )
        {
            release_contact_detail_list_object( pContactObject->nameSorted );
            free( pContactObject->nameSorted );
        }
        
        if( pContactObject->phoneSorted )
        {
            release_contact_detail_list_object( pContactObject->phoneSorted );
            free( pContactObject->phoneSorted );
        }
        
        if( pContactObject->pinyinSorted )
        {
            release_contact_detail_list_object( pContactObject->pinyinSorted );
            free( pContactObject->pinyinSorted );
        }
        
        if( pContactObject->acronymSorted )
        {
            release_contact_detail_list_object( pContactObject->acronymSorted );
            free( pContactObject->acronymSorted );
        }
        
        pContactObject->nameSorted = NULL;
        pContactObject->phoneSorted = NULL;
        pContactObject->pinyinSorted = NULL;
        pContactObject->acronymSorted = NULL;
    }
    return nRet;
}

int release_contact_detail_list_object( struct ContactDetailListContainer* pContactDetailList )
{
    int nRet = 0;
    if( pContactDetailList )
    {
        if(  pContactDetailList->ppItemContact )
        {
            for( unsigned int i=0; i<pContactDetailList->nSize; ++i )
            {
                struct SortedContactDetailInfo* pItem = *( pContactDetailList->ppItemContact + i );
                if( pItem )
                {
                    release_contact_detail_info_object( pItem );
                    free( pItem );
                    *( pContactDetailList->ppItemContact + i ) = NULL;
                }
            }
            free( pContactDetailList->ppItemContact );
            pContactDetailList->ppItemContact = NULL;
        }
        
        pContactDetailList->nSize = 0;
    }
    return nRet;
}

int release_contact_detail_info_object( struct SortedContactDetailInfo* pContactDetail )
{
    int nRet = 0;
    if( pContactDetail )
    {
        // no data need to free.
    }
    return nRet;
}

int release_contact_info_object( struct ContactSearchResult* pContactInfo )
{
    int nRet = 0;
    if( pContactInfo )
    {
        if( pContactInfo->pszName ) free( pContactInfo->pszName );
        if( pContactInfo->pszPhoneNumber ) free( pContactInfo->pszPhoneNumber );
        if( pContactInfo->pszPinyin ) free( pContactInfo->pszPinyin );
        if( pContactInfo->pszAcronym ) free( pContactInfo->pszAcronym );
        
        pContactInfo->pszName = NULL;
        pContactInfo->pszPhoneNumber = NULL;
        pContactInfo->pszPinyin = NULL;
        pContactInfo->pszAcronym = NULL;
        
        pContactInfo->nPersonId = 0;
    }
    return nRet;
}


//================================================================================
// create, delete, init.

void* create_contact_instance()
{
    struct InstancePackage* pRet = 0;
    if( NULL == allContactInstances )
    {
        allContactInstances = malloc(sizeof(struct PackageList));
        memset( allContactInstances, 0, sizeof(struct PackageList));
    }
    
    if( allContactInstances )
    {
        pRet = malloc(sizeof(struct InstancePackage));
        memset( pRet, 0, sizeof(struct InstancePackage));
        
        struct InstancePackage* pNode = allContactInstances->pHead;
        if( pNode )
        {
            while ( pNode->pNext )
            {
                pNode = pNode->pNext;
            }
            pNode->pNext = pRet;
        }
        else
        {
            allContactInstances->pHead = pRet;
        }
        allContactInstances->pTail = pRet;
    }
    
    return pRet;
}

int delete_contact_instance(void* pInstance)
{
    int nRet = -1;
    if( pInstance && allContactInstances )
    {
        struct InstancePackage* instance = pInstance;
        
        struct InstancePackage* pHead = allContactInstances->pHead;
        
        if( pHead )
        {
            if( pHead == instance )
            {
                // if is the first node.
                struct InstancePackage* pNext = pHead->pNext;
                if( pNext )
                {
                    allContactInstances->pHead = pNext;
                }
                else
                {
                    allContactInstances->pHead = NULL;
                    allContactInstances->pTail = NULL;
                }
                
                release_instance_package(pHead);
                free( pHead );
                
                nRet = 0;
            }
            else
            {
                struct InstancePackage* pNode = pHead;
                while( pNode->pNext && pNode->pNext != instance )
                {
                    pNode = pNode->pNext;
                }
                
                if( pNode->pNext == instance )
                {
                    struct InstancePackage* pDelete = pNode->pNext;
                    pNode->pNext = pDelete->pNext;
                    if( NULL == pNode->pNext )
                    {
                        allContactInstances->pTail = pNode;
                    }
                    
                    release_instance_package(pDelete);
                    free( pDelete );
                    
                    nRet = 0;
                }
                else
                {
                    nRet = -3;
                    // why not found?
                }
            }
        }
        else
        {
            nRet = -2;
        }
    }
    return nRet;
}

int init_contacts(void* pInstance, const struct ContactListContainer* pContacts)
{
    int nRet = -1;
    if( pInstance && pContacts && allContactInstances )
    {
        //printf( "init_contacts - start\n" );
        struct InstancePackage* instance = pInstance;
        release_instance_package( instance );
        
        struct ContactListContainer* pInnerContactList = &(instance->allContacts);
        struct ContactSearchResult* pInnerLastEndNode = NULL;
        
        struct ContactSearchResult* pFakeHead = pContacts->pHead;
        if( pFakeHead )
        {
            // dupe the main contacts info.
            struct ContactSearchResult* pNode = pFakeHead->pNext;
            while (pNode)
            {
                struct ContactSearchResult* pNewNode = malloc(sizeof(struct ContactSearchResult));
                memset(pNewNode, 0, sizeof(struct ContactSearchResult));
                dupe_contact_info_object( pNode, pNewNode );
                //pNewNode->nIndex = pInnerContactList->nSize;
                
                if( pInnerLastEndNode )
                {
                    pInnerLastEndNode->pNext = pNewNode;
                }
                else
                {
                    pInnerContactList->pHead = pNewNode;
                }
                
                pInnerContactList->pTail = pNewNode;
                pInnerContactList->nSize++;
                
                pInnerLastEndNode = pNewNode;
                pNode = pNode->pNext;
            }
        }
        
        if( pInnerContactList->nSize > 0 )
        {
            // rebuild the name, phone, pinyin, acronym list.
            struct ContactWithKey tempPackage;
            memset( &tempPackage, 0, sizeof(struct ContactWithKey));
            
            // alloc memory
            tempPackage.nameSorted = malloc( sizeof( struct ContactDetailListContainer ) );
            tempPackage.phoneSorted = malloc( sizeof( struct ContactDetailListContainer ) );
            tempPackage.pinyinSorted = malloc( sizeof( struct ContactDetailListContainer ) );
            tempPackage.acronymSorted = malloc( sizeof( struct ContactDetailListContainer ) );
            
            memset( tempPackage.nameSorted, 0, sizeof( struct ContactDetailListContainer ) );
            memset( tempPackage.phoneSorted, 0, sizeof( struct ContactDetailListContainer ) );
            memset( tempPackage.pinyinSorted, 0, sizeof( struct ContactDetailListContainer ) );
            memset( tempPackage.acronymSorted, 0, sizeof( struct ContactDetailListContainer ) );
            
            tempPackage.nameSorted->nGroup = ContactDetailGroupName;
            tempPackage.phoneSorted->nGroup = ContactDetailGroupPhoneNumber;
            tempPackage.pinyinSorted->nGroup = ContactDetailGroupPinyin;
            tempPackage.acronymSorted->nGroup = ContactDetailGroupAcronym;
            
            //printf( "init_contacts - rebuild\n" );
            // rebuild detail
            rebuild_contacts_detail( ContactDetailGroupName, &(instance->allContacts), tempPackage.nameSorted );
            rebuild_contacts_detail( ContactDetailGroupPhoneNumber, &(instance->allContacts), tempPackage.phoneSorted );
            rebuild_contacts_detail( ContactDetailGroupPinyin, &(instance->allContacts), tempPackage.pinyinSorted );
            rebuild_contacts_detail( ContactDetailGroupAcronym, &(instance->allContacts), tempPackage.acronymSorted );
            
            //printf( "init_contacts - sort start\n" );
            // sort detail
            sort_contacts_detail( ContactDetailGroupName, tempPackage.nameSorted );
            sort_contacts_detail( ContactDetailGroupPhoneNumber, tempPackage.phoneSorted );
            sort_contacts_detail( ContactDetailGroupPinyin, tempPackage.pinyinSorted );
            sort_contacts_detail( ContactDetailGroupAcronym, tempPackage.acronymSorted );
            //printf( "init_contacts - sort end\n" );
            
            // build up cache for key 0 - 9
            for( unsigned int i=0; i<10; ++i )
            {
                buildup_cache_for_key( i, &tempPackage, &(instance->cache[i]) );
                instance->cache[i].nIndex = i;
            }
            //printf( "init_contacts - cache key 0-9 end\n" );
            
            //            buildup_all_contacts_for_char( &tempPackage, &(instance->allContactsForChar) );
            
            // release memory
            release_contact_with_key_object( &tempPackage );
        }
        
        nRet = 0;
    }
    return nRet;
}

int init_contacts_for_search_only(void* pInstance, const struct ContactListContainer* pContacts)
{
    int nRet = -1;
    if( pInstance && pContacts && allContactInstances )
    {
        //printf( "init_contacts - start\n" );
        struct InstancePackage* instance = pInstance;
        release_instance_package( instance );
        
        struct ContactListContainer* pInnerContactList = &(instance->allContacts);
        struct ContactSearchResult* pInnerLastEndNode = NULL;
        
        struct ContactSearchResult* pFakeHead = pContacts->pHead;
        if( pFakeHead )
        {
            // dupe the main contacts info.
            struct ContactSearchResult* pNode = pFakeHead->pNext;
            while (pNode)
            {
                struct ContactSearchResult* pNewNode = malloc(sizeof(struct ContactSearchResult));
                memset(pNewNode, 0, sizeof(struct ContactSearchResult));
                dupe_contact_info_object( pNode, pNewNode );
                //pNewNode->nIndex = pInnerContactList->nSize;
                
                if( pInnerLastEndNode )
                {
                    pInnerLastEndNode->pNext = pNewNode;
                }
                else
                {
                    pInnerContactList->pHead = pNewNode;
                }
                
                pInnerContactList->pTail = pNewNode;
                pInnerContactList->nSize++;
                
                pInnerLastEndNode = pNewNode;
                pNode = pNode->pNext;
            }
        }
        
        if( pInnerContactList->nSize > 0 )
        {
            // rebuild the name, phone, pinyin, acronym list.
            struct ContactWithKey tempPackage;
            memset( &tempPackage, 0, sizeof(struct ContactWithKey));
            
            // alloc memory
            tempPackage.nameSorted = malloc( sizeof( struct ContactDetailListContainer ) );
            tempPackage.phoneSorted = malloc( sizeof( struct ContactDetailListContainer ) );
            tempPackage.pinyinSorted = malloc( sizeof( struct ContactDetailListContainer ) );
            tempPackage.acronymSorted = malloc( sizeof( struct ContactDetailListContainer ) );
            
            memset( tempPackage.nameSorted, 0, sizeof( struct ContactDetailListContainer ) );
            memset( tempPackage.phoneSorted, 0, sizeof( struct ContactDetailListContainer ) );
            memset( tempPackage.pinyinSorted, 0, sizeof( struct ContactDetailListContainer ) );
            memset( tempPackage.acronymSorted, 0, sizeof( struct ContactDetailListContainer ) );
            
            tempPackage.nameSorted->nGroup = ContactDetailGroupName;
            tempPackage.phoneSorted->nGroup = ContactDetailGroupPhoneNumber;
            tempPackage.pinyinSorted->nGroup = ContactDetailGroupPinyin;
            tempPackage.acronymSorted->nGroup = ContactDetailGroupAcronym;
            
            //printf( "init_contacts - rebuild\n" );
            // rebuild detail
            rebuild_contacts_detail( ContactDetailGroupName, &(instance->allContacts), tempPackage.nameSorted );
            rebuild_contacts_detail( ContactDetailGroupPhoneNumber, &(instance->allContacts), tempPackage.phoneSorted );
            rebuild_contacts_detail( ContactDetailGroupPinyin, &(instance->allContacts), tempPackage.pinyinSorted );
            rebuild_contacts_detail( ContactDetailGroupAcronym, &(instance->allContacts), tempPackage.acronymSorted );
            
            //printf( "init_contacts - sort start\n" );
            // sort detail
            sort_contacts_detail( ContactDetailGroupName, tempPackage.nameSorted );
            sort_contacts_detail( ContactDetailGroupPhoneNumber, tempPackage.phoneSorted );
            sort_contacts_detail( ContactDetailGroupPinyin, tempPackage.pinyinSorted );
            sort_contacts_detail( ContactDetailGroupAcronym, tempPackage.acronymSorted );
            //printf( "init_contacts - sort end\n" );
            
            //            // build up cache for key 0 - 9
            //            for( unsigned int i=0; i<10; ++i )
            //            {
            //                buildup_cache_for_key( i, &tempPackage, &(instance->cache[i]) );
            //                instance->cache[i].nIndex = i;
            //            }
            //            //printf( "init_contacts - cache key 0-9 end\n" );
            
            buildup_all_contacts_for_char( &tempPackage, &(instance->allContactsForChar) );
            
            // release memory
            release_contact_with_key_object( &tempPackage );
        }
        
        nRet = 0;
    }
    return nRet;
}

int dupe_contact_info_object( const struct ContactSearchResult* pSrc, struct ContactSearchResult* pDst )
{
    int nRet = -1;
    
    if( pSrc && pDst )
    {
        pDst->nIndex = pSrc->nIndex;
        pDst->nPersonId = pSrc->nPersonId;  // as ABRecordID
        
        if( pSrc->pszName && strlen(pSrc->pszName) > 0 )
        {
            pDst->pszName = malloc(strlen(pSrc->pszName)+1);
            memcpy(pDst->pszName, pSrc->pszName, strlen(pSrc->pszName)+1);
        }
        else
        {
            pDst->pszName = NULL;
        }
        
        if( pSrc->pszPhoneNumber && strlen(pSrc->pszPhoneNumber) > 0 )
        {
            pDst->pszPhoneNumber = malloc(strlen(pSrc->pszPhoneNumber)+1);
            memcpy(pDst->pszPhoneNumber, pSrc->pszPhoneNumber, strlen(pSrc->pszPhoneNumber)+1);
        }
        else
        {
            pDst->pszPhoneNumber = NULL;
        }
        
        if( pSrc->pszPinyin && strlen(pSrc->pszPinyin) > 0 )
        {
            pDst->pszPinyin = malloc(strlen(pSrc->pszPinyin)+1);
            memcpy(pDst->pszPinyin, pSrc->pszPinyin, strlen(pSrc->pszPinyin)+1);
        }
        else
        {
            pDst->pszPinyin = NULL;
        }
        
        if( pSrc->pszAcronym && strlen(pSrc->pszAcronym) > 0 )
        {
            pDst->pszAcronym = malloc(strlen(pSrc->pszAcronym)+1);
            memcpy(pDst->pszAcronym, pSrc->pszAcronym, strlen(pSrc->pszAcronym)+1);
        }
        else
        {
            pDst->pszAcronym = NULL;
        }
        
        pDst->nWeightName = pSrc->nWeightName;
        pDst->nWeightPhone = pSrc->nWeightPhone;
        pDst->nWeightPinyin = pSrc->nWeightPinyin;
        pDst->nWeightAcroym = pSrc->nWeightAcroym;
        
        nRet = 0;
    }
    
    return nRet;
}

int dupe_contact_detail_list( struct ContactDetailListContainer* pListSrc, struct ContactDetailListContainer* pListDst )
{
    int nRet = -1;
    
    if( pListSrc && pListDst )
    {
        pListDst->nSize = pListSrc->nSize;
        pListDst->nTag = pListSrc->nTag;
        pListDst->nGroup = pListSrc->nGroup;
        
        if( pListSrc->nSize > 0 && pListSrc->ppItemContact )
        {
            pListDst->ppItemContact = malloc( pListSrc->nSize * sizeof(struct SortedContactDetailInfo*) );
            memset( pListDst->ppItemContact, 0, pListSrc->nSize * sizeof(struct SortedContactDetailInfo*) );
            
            for( unsigned int i=0; i<pListSrc->nSize; ++i )
            {
                const struct SortedContactDetailInfo* pSrcItem = *(pListSrc->ppItemContact + i);
                if( pSrcItem )
                {
                    struct SortedContactDetailInfo* pNewItem = malloc( sizeof(struct SortedContactDetailInfo) );
                    memcpy( pNewItem, pSrcItem, sizeof(struct SortedContactDetailInfo) );
                    *(pListDst->ppItemContact + i) = pNewItem;
                }
                else
                {
                    printf( "WHY NO SRC SortedContactDetailInfo* ? i:%4d\n", i );
                }
            }
        }
        else
        {
            pListDst->nSize = 0;
            pListDst->ppItemContact = NULL;
        }
        
        nRet = 0;
    }
    
    return nRet;
}

int dupe_contact_with_key_list( struct ContactWithKey* pListSrc, struct ContactWithKey* pListDst )
{
    int nRet = -1;
    
    if( pListSrc && pListDst )
    {
        pListDst->nIndex = pListSrc->nIndex;
        pListDst->nKey = pListSrc->nKey;
        pListDst->nTag = pListSrc->nTag;
        
        if( pListSrc->nameSorted )
        {
            pListDst->nameSorted = malloc(sizeof(struct ContactDetailListContainer));
            memset( pListDst->nameSorted, 0, sizeof(struct ContactDetailListContainer));
            dupe_contact_detail_list( pListSrc->nameSorted, pListDst->nameSorted );
        }
        
        if( pListSrc->phoneSorted )
        {
            pListDst->phoneSorted = malloc(sizeof(struct ContactDetailListContainer));
            memset( pListDst->phoneSorted, 0, sizeof(struct ContactDetailListContainer));
            dupe_contact_detail_list( pListSrc->phoneSorted, pListDst->phoneSorted );
        }
        
        if( pListSrc->pinyinSorted )
        {
            pListDst->pinyinSorted = malloc(sizeof(struct ContactDetailListContainer));
            memset( pListDst->pinyinSorted, 0, sizeof(struct ContactDetailListContainer));
            dupe_contact_detail_list( pListSrc->pinyinSorted, pListDst->pinyinSorted );
        }
        
        if( pListSrc->acronymSorted )
        {
            pListDst->acronymSorted = malloc(sizeof(struct ContactDetailListContainer));
            memset( pListDst->acronymSorted, 0, sizeof(struct ContactDetailListContainer));
            dupe_contact_detail_list( pListSrc->acronymSorted, pListDst->acronymSorted );
        }
        
        nRet = 0;
    }
    
    return nRet;
}

//================================================================================
// key press

int push_key(void* pInstance, unsigned int nKey)
{
    int nRet = 0;
    if( pInstance && allContactInstances )
    {
        struct InstancePackage* instance = pInstance;
        
        if( nKey > 9 )
        {
            if( instance->nHistoryKeyPressCount < kMaxSearchKeyHistory )
            {
                instance->nHistoryKeyPress[instance->nHistoryKeyPressCount] = nKey;
                memset( &(instance->historyObjectWithKey[instance->nHistoryKeyPressCount]), 0, sizeof(struct ContactWithKey) );
                instance->nHistoryKeyPressCount++;
            }
        }
        else
        {
            if( instance->nHistoryKeyPressCount < kMaxSearchKeyHistory )
            {
                if( 0 == instance->nHistoryKeyPressCount )
                {
                    dupe_contact_with_key_list( &(instance->cache[nKey]), &(instance->historyObjectWithKey[0]) );
                    
                    instance->nHistoryKeyPress[0] = nKey;
                    instance->nHistoryKeyPressCount = 1;
                }
                else
                {
                    struct ContactWithKey* pSrc = &(instance->historyObjectWithKey[instance->nHistoryKeyPressCount-1]);
                    struct ContactWithKey* pDst = &(instance->historyObjectWithKey[instance->nHistoryKeyPressCount]);
                    memset( pDst, 0, sizeof(struct ContactWithKey) );
                    pDst->nIndex = instance->nHistoryKeyPressCount;
                    pDst->nKey = nKey;
                    
                    if( pSrc->nameSorted )
                    {
                        pDst->nameSorted = malloc(sizeof(struct ContactDetailListContainer));
                        memset(pDst->nameSorted, 0, sizeof(struct ContactDetailListContainer));
                        buildup_detail_cache_for_key(ContactDetailGroupName, nKey, pSrc->nameSorted, pDst->nameSorted );
                        if( 0 == pDst->nameSorted->nSize )
                        {
                            free( pDst->nameSorted );
                            pDst->nameSorted = NULL;
                        }
                        else
                        {
                            quick_sort_contacts_detail( ContactDetailGroupName, pDst->nameSorted );
                        }
                    }
                    
                    if( pSrc->phoneSorted )
                    {
                        pDst->phoneSorted = malloc(sizeof(struct ContactDetailListContainer));
                        memset(pDst->phoneSorted, 0, sizeof(struct ContactDetailListContainer));
                        buildup_detail_cache_for_key(ContactDetailGroupPhoneNumber, nKey, pSrc->phoneSorted, pDst->phoneSorted );
                        if( 0 == pDst->phoneSorted->nSize )
                        {
                            free( pDst->phoneSorted );
                            pDst->phoneSorted = NULL;
                        }
                        else
                        {
                            quick_sort_contacts_detail( ContactDetailGroupPhoneNumber, pDst->phoneSorted );
                        }
                    }
                    
                    if( pSrc->pinyinSorted )
                    {
                        pDst->pinyinSorted = malloc(sizeof(struct ContactDetailListContainer));
                        memset(pDst->pinyinSorted, 0, sizeof(struct ContactDetailListContainer));
                        buildup_detail_cache_for_key(ContactDetailGroupPinyin, nKey, pSrc->pinyinSorted, pDst->pinyinSorted );
                        if( 0 == pDst->pinyinSorted->nSize )
                        {
                            free( pDst->pinyinSorted );
                            pDst->pinyinSorted = NULL;
                        }
                        else
                        {
                            quick_sort_contacts_detail( ContactDetailGroupPinyin, pDst->pinyinSorted );
                        }
                    }
                    
                    if( pSrc->acronymSorted )
                    {
                        pDst->acronymSorted = malloc(sizeof(struct ContactDetailListContainer));
                        memset(pDst->acronymSorted, 0, sizeof(struct ContactDetailListContainer));
                        buildup_detail_cache_for_key(ContactDetailGroupAcronym, nKey, pSrc->acronymSorted, pDst->acronymSorted );
                        if( 0 == pDst->acronymSorted->nSize )
                        {
                            free( pDst->acronymSorted );
                            pDst->acronymSorted = NULL;
                        }
                        else
                        {
                            quick_sort_contacts_detail( ContactDetailGroupAcronym, pDst->acronymSorted );
                        }
                    }
                    
                    instance->nHistoryKeyPress[instance->nHistoryKeyPressCount] = nKey;
                    instance->nHistoryKeyPressCount++;
                }
            }
        }
    }
    return nRet;
}

int pop_key(void* pInstance)
{
    int nRet = 0;
    if( pInstance && allContactInstances )
    {
        struct InstancePackage* instance = pInstance;
        
        if( instance->nHistoryKeyPressCount > 0 )
        {
            struct ContactWithKey* pDst = &(instance->historyObjectWithKey[instance->nHistoryKeyPressCount]);
            release_contact_with_key_object( pDst );
            
            memset( &(instance->historyObjectWithKey[instance->nHistoryKeyPressCount]), 0, sizeof(struct ContactWithKey) );
            
            instance->nHistoryKeyPressCount--;
        }
    }
    return nRet;
}

int reset_key(void* pInstance)
{
    int nRet = 0;
    if( pInstance && allContactInstances )
    {
        struct InstancePackage* instance = pInstance;
        
        while( instance->nHistoryKeyPressCount > 0 )
        {
            struct ContactWithKey* pDst = &(instance->historyObjectWithKey[instance->nHistoryKeyPressCount]);
            release_contact_with_key_object( pDst );
            memset( pDst, 0, sizeof(struct ContactWithKey) );
            
            struct ContactWithChar* pCharDst = &(instance->historyObjectWithChar[instance->nHistoryKeyPressCount]);
            release_contact_with_char_object( pCharDst );
            memset( pCharDst, 0, sizeof(struct ContactWithChar) );
            
            instance->nHistoryKeyPressCount--;
        }
        
        instance->nHistoryKeyPressCount = 0;
    }
    return nRet;
}

//================================================================================
//
unsigned int get_real_contact_count(void* pInstance)
{
    unsigned int nRet = 0;
    if( pInstance )
    {
        struct InstancePackage* instance = pInstance;
        if( instance->nHistoryKeyPressCount > 0 )
        {
            nRet = instance->allContacts.nSize;
        }
    }
    return nRet;
}

//================================================================================
//

const struct ContactWithKey* get_keypress_result(void* pInstance)
{
    const struct ContactWithKey* pRet = NULL;
    
    if( pInstance )
    {
        struct InstancePackage* instance = pInstance;
        if( instance->nHistoryKeyPressCount > 0 )
        {
            unsigned int nKeyPressIndex = instance->nHistoryKeyPressCount;
            if( nKeyPressIndex > 0 && nKeyPressIndex < kMaxSearchKeyHistory )
            {
                pRet = &(instance->historyObjectWithKey[nKeyPressIndex-1]);
            }
        }
    }
    
    return pRet;
}

const struct ContactWithChar* get_charpress_result(void* pInstance)
{
    const struct ContactWithChar* pRet = NULL;
    
    if( pInstance )
    {
        struct InstancePackage* instance = pInstance;
        if( instance->nHistoryKeyPressCount > 0 )
        {
            unsigned int nKeyPressIndex = instance->nHistoryKeyPressCount;
            if( nKeyPressIndex > 0 && nKeyPressIndex < kMaxSearchKeyHistory )
            {
                pRet = &(instance->historyObjectWithChar[nKeyPressIndex-1]);
            }
        }
    }
    
    return pRet;
}

//================================================================================
//
// 1 = in, 0 = not in. (nPersonID as ABRecordID)
int test_if_contact_in_inner_list( const struct ContactDetailListContainer* pInnerList, unsigned int nPersonID )
{
    int nRet = 0;
    //if( pInnerList && ( ContactDetailGroupPhoneNumber!= pInnerList->nGroup) )
    {
        for ( unsigned int i=0; i<pInnerList->nSize; ++i )
        {
            struct SortedContactDetailInfo* pItem = *( pInnerList->ppItemContact + i );
            if( pItem && pItem->pRefContactInfo )
            {
                if( pItem->pRefContactInfo->nPersonId == nPersonID )
                {
                    nRet = 1;
                    break;
                }
            }
        }
    }
    return nRet;
}

int rebuild_contacts_detail(unsigned int nGroup,
                            const struct ContactListContainer* pContactsList,
                            struct ContactDetailListContainer* pDetailList )
{
    int nRet = 0;
    if( pContactsList && pDetailList )
    {
        if( pContactsList->nSize > 0 )
        {
            pDetailList->nSize = 0;//pContactsList->nSize;
            pDetailList->ppItemContact = malloc( pContactsList->nSize * sizeof(struct SortedContactDetailInfo*) );
            memset(pDetailList->ppItemContact, 0, pContactsList->nSize * sizeof(struct SortedContactDetailInfo*) );
            
            struct ContactSearchResult* pNode = pContactsList->pHead;
            
            unsigned int nCount = 0;
            while (pNode)
            {
                unsigned int nAlreadyInList = 1;
                switch ( nGroup )
                {
                    case ContactDetailGroupName:
                        if( pNode->pszName && pNode->pszPhoneNumber )
                        {
                            nAlreadyInList = test_if_contact_in_inner_list( pDetailList, pNode->nPersonId );
                        }
                        break;
                    case ContactDetailGroupPhoneNumber:
                        if( pNode->pszName && pNode->pszPhoneNumber )
                        {
                            nAlreadyInList = 0;
                        }
                        break;
                    case ContactDetailGroupPinyin:
                        if( pNode->pszName && pNode->pszPinyin )
                        {
                            nAlreadyInList = test_if_contact_in_inner_list( pDetailList, pNode->nPersonId );
                        }
                        break;
                    case ContactDetailGroupAcronym:
                        if( pNode->pszName && pNode->pszAcronym )
                        {
                            nAlreadyInList = test_if_contact_in_inner_list( pDetailList, pNode->nPersonId );
                        }
                        break;
                    default:
                        break;
                }
                
                if( 0 == nAlreadyInList )
                {
                    struct SortedContactDetailInfo* pNewNode = malloc(sizeof(struct SortedContactDetailInfo));
                    memset(pNewNode, 0, sizeof(struct SortedContactDetailInfo));
                    pNewNode->nGroup = nGroup;
                    pNewNode->nIndex = nCount;
                    pNewNode->pRefContactInfo = pNode;
                    
                    *( pDetailList->ppItemContact + nCount ) = pNewNode;
                    nCount++;
                    pDetailList->nSize = nCount;
                    
                    if( pDetailList->nSize > pContactsList->nSize )
                    {
                        printf("WHY TOO MUCH?\n" );
                        break;
                    }
                }
                else
                {
                    //printf( "why check not pass?? nGroup:%d\n", nGroup );
                }
                
                pNode = pNode->pNext;
            }
        }
        else
        {
            pDetailList->nSize = 0;
            pDetailList->ppItemContact = NULL;
        }
    }
    return nRet;
}

// -1 is less, 0 is equal, 1 is greater
int compare_two_string_x(const char* pszA, const char* pszB, unsigned int nStartPos )
{
    int nRet = COMPARE_STRING_SAME;
    int nCompare = strcmp( pszA+nStartPos, pszB+nStartPos);
    if( nCompare > 0 )
    {
        nRet = COMPARE_STRING_GREATER;
    }
    else if(nCompare < 0)
    {
        nRet = COMPARE_STRING_LESS;
    }
    return nRet;
}

int compare_two_string(const char* pszA, const char* pszB, unsigned int nStartPos )
{
    int nRet = COMPARE_STRING_SAME;
    if( pszA && pszB )
    {
        const char* psz1 = pszA + nStartPos;
        const char* psz2 = pszB + nStartPos;
        
        while( *psz1 && *psz2 )
        {
            char ch1 = *psz1;
            char ch2 = *psz2;
            
            if( ch1 >= 'A' && ch1 <= 'Z' )
            {
                ch1 = ch1 - 'A' + 'a';
            }
            if( ch2 >= 'A' && ch2 <= 'Z' )
            {
                ch2 = ch2 - 'A' + 'a';
            }
            
            if( ch1 > ch2 )
            {
                nRet = COMPARE_STRING_GREATER;
                break;
            }
            else if( ch1 < ch2 )
            {
                nRet = COMPARE_STRING_LESS;
                break;
            }
            else
            {
                psz1++;
                psz2++;
            }
        }
        
        if( *psz1 && (!(*psz2)) )
        {
            nRet = COMPARE_STRING_GREATER;
        }
        else if( (!(*psz1)) && *psz2 )
        {
            nRet = COMPARE_STRING_LESS;
        }
        else
        {
            // ok
        }
    }
    else
    {
        if( pszA )
        {
            nRet = COMPARE_STRING_GREATER;
        }
        else if( pszB )
        {
            nRet = COMPARE_STRING_LESS;
        }
    }
    
    return nRet;
}

// -1 is less, 0 is equal, 1 is greater
int compare_two_contact_detail(unsigned int nGroup, const struct SortedContactDetailInfo* p1, const struct SortedContactDetailInfo* p2 )
{
    int nRet = COMPARE_STRING_SAME;
    if( p1 && p2 )
    {
        const struct ContactSearchResult* pRef1 = p1->pRefContactInfo;
        const struct ContactSearchResult* pRef2 = p2->pRefContactInfo;
        //if( pRef1 && pRef2 )
        {
            unsigned int nStartPos = 0;
            if( p1->nMatchKeyCount > 0 )
            {
                //nStartPos = p1->nRange[0];
                if( p1->nRange[0] > p2->nRange[0] )
                {
                    nRet = COMPARE_STRING_GREATER;
                }
                else if( p1->nRange[0] < p2->nRange[0] )
                {
                    nRet = COMPARE_STRING_LESS;
                }
            }
            
            if( COMPARE_STRING_SAME == nRet )
            {
                switch (nGroup)
                {
                    case ContactDetailGroupName:
                    {
                        if( pRef1->nWeightName > pRef2->nWeightName )
                        {
                            nRet = COMPARE_STRING_GREATER;
                        }
                        else if( pRef1->nWeightName < pRef2->nWeightName )
                        {
                            nRet = COMPARE_STRING_LESS;
                        }
                        else //( COMPARE_STRING_SAME == nRet )
                        {
                            nRet = compare_two_string( pRef1->pszName, pRef2->pszName, nStartPos );
                            if( COMPARE_STRING_SAME == nRet )
                            {
                                nRet = compare_two_string( pRef1->pszPinyin, pRef2->pszPinyin, 0 );
                            }
                        }
                    }
                        break;
                    case ContactDetailGroupPhoneNumber:
                    {
                        if( pRef1->nWeightPhone > pRef2->nWeightPhone )
                        {
                            nRet = COMPARE_STRING_GREATER;
                        }
                        else if( pRef1->nWeightPhone < pRef2->nWeightPhone )
                        {
                            nRet = COMPARE_STRING_LESS;
                        }
                        else // ( COMPARE_STRING_SAME == nRet )
                        {
                            nRet = compare_two_string( pRef1->pszPhoneNumber, pRef2->pszPhoneNumber, nStartPos );
                            if( COMPARE_STRING_SAME == nRet )
                            {
                                nRet = compare_two_string( pRef1->pszPinyin, pRef2->pszPinyin, 0 );
                                if( COMPARE_STRING_SAME == nRet )
                                {
                                    nRet = compare_two_string( pRef1->pszName, pRef2->pszName, 0 );
                                }
                            }
                        }
                    }
                        break;
                    case ContactDetailGroupAcronym:
                    {
                        if( pRef1->nWeightAcroym > pRef2->nWeightAcroym )
                        {
                            nRet = COMPARE_STRING_GREATER;
                        }
                        else if( pRef1->nWeightAcroym < pRef2->nWeightAcroym )
                        {
                            nRet = COMPARE_STRING_LESS;
                        }
                        else //( COMPARE_STRING_SAME == nRet )
                        {
                            nRet = compare_two_string( pRef1->pszAcronym, pRef2->pszAcronym, nStartPos );
                            //if( COMPARE_STRING_SAME != nRet )
                            //{
                            //    int nnn = 0;
                            //}
                            if( COMPARE_STRING_SAME == nRet )
                            {
                                nRet = compare_two_string( pRef1->pszPinyin, pRef2->pszPinyin, nStartPos );
                                if( COMPARE_STRING_SAME == nRet )
                                {
                                    //nRet = compare_two_string( pRef1->pszPhoneNumber, pRef2->pszPhoneNumber, 0 );
                                    //if( COMPARE_STRING_SAME == nRet )
                                    {
                                        nRet = compare_two_string( pRef1->pszName, pRef2->pszName, 0 );
                                    }
                                }
                            }
                        }
                    }
                        break;
                    case ContactDetailGroupPinyin:
                    {
                        if( pRef1->nWeightPinyin > pRef2->nWeightPinyin )
                        {
                            nRet = COMPARE_STRING_GREATER;
                        }
                        else if( pRef1->nWeightPinyin < pRef2->nWeightPinyin )
                        {
                            nRet = COMPARE_STRING_LESS;
                        }
                        else //( COMPARE_STRING_SAME == nRet )
                        {
                            nRet = compare_two_string( pRef1->pszPinyin, pRef2->pszPinyin, nStartPos );
                            if( COMPARE_STRING_SAME == nRet )
                            {
                                nRet = compare_two_string( pRef1->pszPhoneNumber, pRef2->pszPhoneNumber, 0 );
                                if( COMPARE_STRING_SAME == nRet )
                                {
                                    nRet = compare_two_string( pRef1->pszName, pRef2->pszName, 0 );
                                }
                            }
                        }
                    }
                        break;
                    default:
                        break;
                }
                
                //                if( COMPARE_STRING_SAME == nRet && ContactDetailGroupPhoneNumber != nGroup )
                //                {
                //                    printf("same compare_two_string nGroup:%d %s %s\n", nGroup, pRef1->pszPinyin, pRef2->pszPinyin);
                //                }
            }
        }
    }
    return nRet;
}

//============================================================================
//
// left is the index of the leftmost element of the array
// right is the index of the rightmost element of the array (inclusive)
// number of elements in subarray = right-left+1
//
//    function partition(array, 'left', 'right', 'pivotIndex')
//        'pivotValue' := array['pivotIndex']
//        swap array['pivotIndex'] and array['right']  // Move pivot to end
//        'storeIndex' := 'left'
//        for 'i' from 'left' to 'right' - 1  // left ≤ i < right
//            if array['i'] < 'pivotValue'
//                swap array['i'] and array['storeIndex']
//                'storeIndex' := 'storeIndex' + 1
//            swap array['storeIndex'] and array['right']  // Move pivot to its final place
//        return 'storeIndex'
//
//    function quicksort(array, 'left', 'right')
//        // If the list has 2 or more items
//        if 'left' < 'right'
//            choose any 'pivotIndex' such that 'left' ≤ 'pivotIndex' ≤ 'right'
//            // Get lists of bigger and smaller items and final position of pivot
//            'pivotNewIndex' := partition(array, 'left', 'right', 'pivotIndex')
//            // Recursively sort elements smaller than the pivot
//            quicksort(array, 'left', 'pivotNewIndex' - 1)
//            // Recursively sort elements at least as big as the pivot
//            quicksort(array, 'pivotNewIndex' + 1, 'right')
//
//============================================================================

int partition_detail(unsigned int nGroup,
                     struct SortedContactDetailInfo** ppHead,
                     unsigned int nLeft, unsigned int nRight, unsigned int nPivotIndex )
{
    int nRet = nRight;
    
    unsigned int nStoreIndex = nPivotIndex;
    
    struct SortedContactDetailInfo* pPivotValue = *( ppHead + nPivotIndex );
    
    // speedup, just search once.
    for( unsigned int nSearchBlankToIndex = nRight; nSearchBlankToIndex > nPivotIndex; --nSearchBlankToIndex )
    {
        struct SortedContactDetailInfo* pItem = *( ppHead + nSearchBlankToIndex );
        int nCompare = compare_two_contact_detail( nGroup, pPivotValue, pItem );
        if( nCompare > COMPARE_STRING_SAME )
        {
            *( ppHead + nPivotIndex ) = *( ppHead + nSearchBlankToIndex );
            nStoreIndex = nSearchBlankToIndex;
            break;
        }
    }
    //*( ppHead + nPivotIndex ) = *( ppHead + nRight );
    
    for( unsigned int nIndex = nLeft; nIndex < nStoreIndex; ++nIndex )
    {
        struct SortedContactDetailInfo* pItem = *( ppHead + nIndex );
        int nCompare = compare_two_contact_detail( nGroup, pPivotValue, pItem );
        if( nCompare < COMPARE_STRING_SAME )
        {
            *( ppHead + nStoreIndex ) = *( ppHead + nIndex );
            --nStoreIndex;
            *( ppHead + nIndex ) = *(ppHead + nStoreIndex);
            --nIndex;
        }
    }
    
    //    for( unsigned int nIndex = nLeft; nIndex < nStoreIndex; ++nIndex )
    //    {
    //        struct SortedContactDetailInfo* pItem = *( ppHead + nIndex );
    //        int nCompare = compare_two_contact_detail( nGroup, pPivotValue, pItem );
    //        if( nCompare < COMPARE_STRING_SAME )
    //        {
    //            *( ppHead + nStoreIndex ) = *( ppHead + nIndex );
    //            unsigned int nFoundRight = 0;
    //            for( unsigned int nSearchRightIndex = nStoreIndex - 1; nSearchRightIndex > nIndex ; --nSearchRightIndex )
    //            {
    //                struct SortedContactDetailInfo* pSearchItem = *( ppHead + nSearchRightIndex );
    //                int nCompare = compare_two_contact_detail( nGroup, pPivotValue, pSearchItem );
    //                if( nCompare > COMPARE_STRING_SAME )
    //                {
    //                    *( ppHead + nIndex ) = *( ppHead + nSearchRightIndex );
    //                    nStoreIndex = nSearchRightIndex;
    //                    nFoundRight = 1;
    //                    break;
    //                }
    //            }
    //
    //            if( 0 == nFoundRight )
    //            {
    //                nStoreIndex = nIndex;
    //                break;
    //            }
    //            else
    //            {
    //                // found
    //                int n = 0;
    //            }
    //        }
    //    }
    
    *( ppHead + nStoreIndex ) = pPivotValue;
    nRet = nStoreIndex;
    
    return nRet;
}

int quick_sort_detail(unsigned int nGroup, struct SortedContactDetailInfo** ppHead, unsigned int nLeft, unsigned int nRight )
{
    int nRet = 0;
    
    if( ppHead )
    {
        if( (nRight - nLeft) == 1 )
        {
            //printf( "quick_sort_detail nGroup:%2d nLeft:%4d nRight:%4d\n", nGroup, nLeft, nRight );
            
            const struct SortedContactDetailInfo* pLeft = *(ppHead + nLeft);
            const struct SortedContactDetailInfo* pRight = *(ppHead + nRight);
            
            int nCompare = compare_two_contact_detail( nGroup, pLeft, pRight );
            
            //{
            //    const struct ContactSearchResult* pRefLeft = pLeft->pRefContactInfo;
            //    const struct ContactSearchResult* pRefRight = pRight->pRefContactInfo;
            //    printf( "==== nGroup:%2d %2d %s %s\n", nGroup, nCompare, pRefLeft->pszPinyin, pRefRight->pszPinyin );
            //}
            
            if( nCompare > COMPARE_STRING_SAME )
            {
                struct SortedContactDetailInfo* pTemp = *(ppHead+nLeft);
                *(ppHead+nLeft) = *(ppHead+nRight);
                *(ppHead+nRight) = pTemp;
            }
        }
        else if( (nRight - nLeft) == 2 )
        {
            //unsigned int nPivotIndex = nLeft + 1;
            //printf( "quick_sort_detail nGroup:%2d nLeft:%4d nRight:%4d   mid:%4d\n", nGroup, nLeft, nRight, nPivotIndex );
            
            //const struct SortedContactDetailInfo* pLeft = *(ppHead + nLeft);
            //const struct SortedContactDetailInfo* pMiddle = *(ppHead + nLeft + 1);
            //const struct SortedContactDetailInfo* pRight = *(ppHead + nRight);
            
            int nCompare1 = compare_two_contact_detail( nGroup, *(ppHead+nLeft), *(ppHead+nLeft+1) );
            if( nCompare1 > COMPARE_STRING_SAME )
            {
                struct SortedContactDetailInfo* pTemp = *(ppHead+nLeft);
                *(ppHead+nLeft) = *(ppHead+nLeft+1);
                *(ppHead+nLeft+1) = pTemp;
            }
            
            int nCompare2 = compare_two_contact_detail( nGroup, *(ppHead+nLeft), *(ppHead+nRight) );
            if( nCompare2 > COMPARE_STRING_SAME )
            {
                struct SortedContactDetailInfo* pTemp = *(ppHead+nLeft);
                *(ppHead+nLeft) = *(ppHead+nRight);
                *(ppHead+nRight) = pTemp;
            }
            
            int nCompare3 = compare_two_contact_detail( nGroup, *(ppHead+nLeft+1), *(ppHead+nRight) );
            if( nCompare3 > COMPARE_STRING_SAME )
            {
                struct SortedContactDetailInfo* pTemp = *(ppHead+nLeft+1);
                *(ppHead+nLeft+1) = *(ppHead+nRight);
                *(ppHead+nRight) = pTemp;
            }
            
        }
        else if( (nRight - nLeft) > 2 )
        {
            unsigned int nPivotIndex = nLeft + ( (nRight - nLeft) / 2 );
            //printf( "quick_sort_detail nGroup:%2d nLeft:%4d nRight:%4d pivot:%4d\n", nGroup, nLeft, nRight, nPivotIndex );
            
            int nNewPivotIndex = partition_detail( nGroup, ppHead, nLeft, nRight, nPivotIndex );
            
            if( (nNewPivotIndex > nLeft) && ( ( (nNewPivotIndex-1) - nLeft ) >= 1 ) )
            {
                quick_sort_detail( nGroup, ppHead, nLeft, nNewPivotIndex-1 );
            }
            
            if( ( ( nRight > nNewPivotIndex ) && ( nRight - (nNewPivotIndex+1) ) >= 1 ) )
            {
                quick_sort_detail( nGroup, ppHead, nNewPivotIndex+1, nRight );
            }
        }
        else
        {
            // sort ok!
            //printf( "quick_sort_detail nGroup:%2d nLeft:%4d nRight:%4d -------- ok \n", nGroup, nLeft, nRight );
        }
    }
    
    return nRet;
}

int quick_sort_contacts_detail(unsigned int nGroup, struct ContactDetailListContainer* pDetailList )
{
    int nRet = 0;
    
    if( pDetailList )
    {
        unsigned int nTotalSize = pDetailList->nSize;
        if( nTotalSize > 0 )
        {
            struct SortedContactDetailInfo** ppHead = pDetailList->ppItemContact;
            //printf("quick_sort_contacts_detail start nTotalSize:%d\n", nTotalSize);
            quick_sort_detail( nGroup, ppHead, 0, nTotalSize-1 );
            //printf("quick_sort_contacts_detail end\n");
        }
    }
    
    return nRet;
}

int sort_contacts_detail(unsigned int nGroup, struct ContactDetailListContainer* pDetailList )
{
    return quick_sort_contacts_detail( nGroup, pDetailList );
}

int quick_sort_contacts_detail_x(unsigned int nGroup, struct ContactDetailListContainer* pDetailList )
{
    int nRet = 0;
    
    if( pDetailList )
    {
        unsigned int nSwap = 0;
        unsigned int nCompare = 0;
        unsigned int nTotalSize = pDetailList->nSize;
        if( nTotalSize > 0 )
        {
            struct SortedContactDetailInfo** ppHead = pDetailList->ppItemContact;
            for( unsigned int i=0; i<nTotalSize; ++i )
            {
                for( unsigned int j=i+1; j<nTotalSize; ++j )
                {
                    nCompare++;
                    int nCompare = compare_two_contact_detail( nGroup, *(ppHead + i), *(ppHead + j) );
                    if( nCompare > COMPARE_STRING_SAME )
                    {
                        nSwap++;
                        struct SortedContactDetailInfo* pTemp = *(ppHead+i);
                        *(ppHead+i) = *(ppHead+j);
                        *(ppHead+j) = pTemp;
                    }
                }
            }
        }
        
        //printf( "sort nGroup:%d total:%4d compare:%8d swap:%d\n", nGroup,  nTotalSize, nCompare, nSwap );
    }
    
    return nRet;
}

int dupe_all_detail_for_char(unsigned int nGroup,
                             const struct ContactDetailListContainer* pSrcDetail,
                             struct ContactDetailListContainer* pDstDetail )
{
    int nRet = 0;
    
    if( pSrcDetail && pDstDetail )
    {
        struct structTempMatchitem
        {
            struct SortedContactDetailInfo* item;
            struct structTempMatchitem* pNext;
        };
        
        struct structTempMatchitem* pHead = NULL;
        struct structTempMatchitem* pRefTail = NULL;
        
        unsigned int nMatchCount = 0;
        
        for( unsigned int itemIndex=0; itemIndex<pSrcDetail->nSize; ++itemIndex )
        {
            const struct SortedContactDetailInfo* pNode = *( pSrcDetail->ppItemContact + itemIndex);
            if( pNode->pRefContactInfo )
            {
                const char* pszValue = NULL;
                switch (nGroup)
                {
                    case ContactDetailGroupAcronym:
                        pszValue = pNode->pRefContactInfo->pszAcronym;
                        break;
                    case ContactDetailGroupPinyin:
                        pszValue = pNode->pRefContactInfo->pszPinyin;
                        break;
                    case ContactDetailGroupName:
                        pszValue = pNode->pRefContactInfo->pszName;
                        break;
                    case ContactDetailGroupPhoneNumber:
                        pszValue = pNode->pRefContactInfo->pszPhoneNumber;
                        break;
                    default:
                        printf( "WHY NO VALID VALUE? nGroup:%d\n", nGroup );
                        continue;
                        break;
                }
                
                if( NULL == pszValue )
                {
                    //printf( "WHY NO VALID VALUE 2? nGroup:%d\n", nGroup );
                    continue;
                }
                
                {
                    struct SortedContactDetailInfo* pNewNode = malloc(sizeof(struct SortedContactDetailInfo));
                    memset(pNewNode, 0, sizeof(struct SortedContactDetailInfo));
                    pNewNode->nGroup = nGroup;
                    pNewNode->nIndex = nMatchCount;
                    pNewNode->nMatchKeyCount = 0;
                    pNewNode->nRange[0] = 0;
                    
                    pNewNode->pRefContactInfo = pNode->pRefContactInfo;
                    
                    if( pRefTail )
                    {
                        struct structTempMatchitem* pNewItem = malloc( sizeof(struct structTempMatchitem));
                        pNewItem->item = pNewNode;
                        pNewItem->pNext = NULL;
                        
                        pRefTail->pNext = pNewItem;
                        pRefTail = pNewItem;
                    }
                    else
                    {
                        pHead = malloc( sizeof(struct structTempMatchitem));
                        pHead->item = pNewNode;
                        pHead->pNext = NULL;
                        pRefTail = pHead;
                    }
                    
                    pDstDetail->nSize++;
                    
                    nMatchCount++;
                }
            } // if( pNode->pRefContactInfo )
            
            //pNode = pNode->pNext;
        }   // for( unsigned int itemIndex=0; itemIndex<pSrcDetail->nSize; ++itemIndex )
        
        {
            pDstDetail->nSize = 0;//nMatchCount;
            pDstDetail->ppItemContact = malloc( nMatchCount * sizeof(struct SortedContactDetailInfo*) );
            memset( pDstDetail->ppItemContact, 0, nMatchCount * sizeof(struct SortedContactDetailInfo*) );
            
            unsigned int nCount = 0;
            while ( pHead )
            {
                *(pDstDetail->ppItemContact + nCount) = pHead->item;
                struct structTempMatchitem* pTempNext = pHead->pNext;
                free( pHead );
                pHead = pTempNext;
                
                nCount++;
                pDstDetail->nSize = nCount;
                if( nCount > nMatchCount )
                {
                    // overflow.
                    printf("nCount overflow \n");
                    break;
                }
            }
            //int n = 0;
        }
    }
    
    return nRet;
}

int buildup_all_contacts_for_char( const struct ContactWithKey* pSrc, struct ContactWithChar* pDst )
{
    int nRet = 0;
    
    if( pSrc && pDst )
    {
        if( pSrc->nameSorted && pSrc->pinyinSorted )
        {
            pDst->phoneSorted = malloc( sizeof( struct ContactDetailListContainer) );
            pDst->pinyinSorted = malloc( sizeof( struct ContactDetailListContainer) );
            pDst->acronymSorted = malloc( sizeof( struct ContactDetailListContainer) );
            
            memset( pDst->phoneSorted, 0, sizeof( struct ContactDetailListContainer) );
            memset( pDst->pinyinSorted, 0, sizeof( struct ContactDetailListContainer) );
            memset( pDst->acronymSorted, 0, sizeof( struct ContactDetailListContainer) );
            
            pDst->phoneSorted->nGroup = ContactDetailGroupPhoneNumber;
            pDst->pinyinSorted->nGroup = ContactDetailGroupPinyin;
            pDst->acronymSorted->nGroup = ContactDetailGroupAcronym;
            
            dupe_all_detail_for_char(ContactDetailGroupPhoneNumber, pSrc->phoneSorted, pDst->phoneSorted );
            dupe_all_detail_for_char(ContactDetailGroupPinyin, pSrc->pinyinSorted, pDst->pinyinSorted );
            dupe_all_detail_for_char(ContactDetailGroupAcronym, pSrc->acronymSorted, pDst->acronymSorted );
            
            quick_sort_contacts_detail( ContactDetailGroupPhoneNumber, pDst->phoneSorted );
            quick_sort_contacts_detail( ContactDetailGroupPinyin, pDst->pinyinSorted );
            quick_sort_contacts_detail( ContactDetailGroupAcronym, pDst->acronymSorted );
        }
    }
    return nRet;
}

int buildup_cache_for_key( unsigned int nKey, const struct ContactWithKey* pSrc, struct ContactWithKey* pDst )
{
    int nRet = 0;
    
    if( pSrc && pDst )
    {
        if( pSrc->nameSorted && pSrc->phoneSorted && pSrc->pinyinSorted && pSrc->acronymSorted )
        {
            pDst->nKey = nKey;
            
            pDst->nameSorted = malloc( sizeof( struct ContactDetailListContainer) );
            pDst->phoneSorted = malloc( sizeof( struct ContactDetailListContainer) );
            pDst->pinyinSorted = malloc( sizeof( struct ContactDetailListContainer) );
            pDst->acronymSorted = malloc( sizeof( struct ContactDetailListContainer) );
            
            memset( pDst->nameSorted, 0, sizeof( struct ContactDetailListContainer) );
            memset( pDst->phoneSorted, 0, sizeof( struct ContactDetailListContainer) );
            memset( pDst->pinyinSorted, 0, sizeof( struct ContactDetailListContainer) );
            memset( pDst->acronymSorted, 0, sizeof( struct ContactDetailListContainer) );
            
            pDst->nameSorted->nGroup = ContactDetailGroupName;
            pDst->phoneSorted->nGroup = ContactDetailGroupPhoneNumber;
            pDst->pinyinSorted->nGroup = ContactDetailGroupPinyin;
            pDst->acronymSorted->nGroup = ContactDetailGroupAcronym;
            
            buildup_detail_cache_for_key(ContactDetailGroupName, nKey, pSrc->nameSorted, pDst->nameSorted );
            buildup_detail_cache_for_key(ContactDetailGroupPhoneNumber, nKey, pSrc->phoneSorted, pDst->phoneSorted );
            buildup_detail_cache_for_key(ContactDetailGroupPinyin, nKey, pSrc->pinyinSorted, pDst->pinyinSorted );
            buildup_detail_cache_for_key(ContactDetailGroupAcronym, nKey, pSrc->acronymSorted, pDst->acronymSorted );
            
            //printf("buildup_cache_for_key - sort\n");
            // sort detail
            quick_sort_contacts_detail( ContactDetailGroupName, pDst->nameSorted );
            quick_sort_contacts_detail( ContactDetailGroupPhoneNumber, pDst->phoneSorted );
            quick_sort_contacts_detail( ContactDetailGroupPinyin, pDst->pinyinSorted );
            quick_sort_contacts_detail( ContactDetailGroupAcronym, pDst->acronymSorted );
            //printf("buildup_cache_for_key - end\n");
        }
    }
    
    return nRet;
}

int buildup_detail_cache_for_key(unsigned int nGroup,
                                 unsigned int nKey,
                                 const struct ContactDetailListContainer* pSrcDetail,
                                 struct ContactDetailListContainer* pDstDetail )
{
    int nRet = 0;
    
    if( pSrcDetail && pDstDetail )
    {
        
        // the result match count is unknown, so we need a link-list to store in temp memory,
        // then build up result value, and copy the pointers to pointer array in the result.
        
        struct structTempMatchitem
        {
            struct SortedContactDetailInfo* item;
            struct structTempMatchitem* pNext;
        };
        
        struct structTempMatchitem* pHead = NULL;
        struct structTempMatchitem* pRefTail = NULL;
        
        unsigned int nMatchCount = 0;
        
        for( unsigned int itemIndex=0; itemIndex<pSrcDetail->nSize; ++itemIndex )
        {
            const struct SortedContactDetailInfo* pNode = *( pSrcDetail->ppItemContact + itemIndex);
            if( pNode->pRefContactInfo && pNode->nMatchKeyCount < kMaxSearchKeyHistory )
            {
                const char* pszValue = NULL;
                switch (nGroup)
                {
                    case ContactDetailGroupAcronym:
                        pszValue = pNode->pRefContactInfo->pszAcronym;
                        break;
                    case ContactDetailGroupPinyin:
                        pszValue = pNode->pRefContactInfo->pszPinyin;
                        break;
                    case ContactDetailGroupName:
                        pszValue = pNode->pRefContactInfo->pszName;
                        break;
                    case ContactDetailGroupPhoneNumber:
                        pszValue = pNode->pRefContactInfo->pszPhoneNumber;
                        break;
                    default:
                        printf( "WHY NO VALID VALUE? nGroup:%d\n", nGroup );
                        continue;
                        break;
                }
                
                if( NULL == pszValue )
                {
                    //printf( "WHY NO VALID VALUE 2? nGroup:%d\n", nGroup );
                    continue;
                }
                
                if( 0 == pNode->nMatchKeyCount )
                {
                    // first match
                    
                    const char* p = pszValue;
                    unsigned int nPos = 1;
                    while( *p )
                    {
                        int nMatch = -1;
                        
                        // only match cap-alpha for  the first pinyin.
                        if( ContactDetailGroupPinyin == nGroup )
                        {
                            nMatch = is_first_key_match_char( nKey, *p );
                        }
                        else
                        {
                            nMatch = is_key_match_char( nKey, *p );
                        }
                        
                        if( 0 == nMatch )
                        {
                            struct SortedContactDetailInfo* pNewNode = malloc(sizeof(struct SortedContactDetailInfo));
                            memset(pNewNode, 0, sizeof(struct SortedContactDetailInfo));
                            pNewNode->nGroup = nGroup;
                            pNewNode->nIndex = nMatchCount;
                            pNewNode->nMatchKeyCount = 1;
                            pNewNode->nRange[0] = nPos;
                            
                            pNewNode->pRefContactInfo = pNode->pRefContactInfo;
                            
                            //                            if( pDstDetail->pHead && pDstDetail->pTail )
                            //                            {
                            //                                pDstDetail->pTail->pNext = pNewNode;
                            //                            }
                            //                            else
                            //                            {
                            //                                pDstDetail->pHead = pNewNode;
                            //                            }
                            //                            pDstDetail->pTail = pNewNode;
                            if( pRefTail )
                            {
                                struct structTempMatchitem* pNewItem = malloc( sizeof(struct structTempMatchitem));
                                pNewItem->item = pNewNode;
                                pNewItem->pNext = NULL;
                                
                                pRefTail->pNext = pNewItem;
                                pRefTail = pNewItem;
                            }
                            else
                            {
                                pHead = malloc( sizeof(struct structTempMatchitem));
                                pHead->item = pNewNode;
                                pHead->pNext = NULL;
                                pRefTail = pHead;
                            }
                            
                            pDstDetail->nSize++;
                            
                            nMatchCount++;
                        }
                        
                        nPos++;
                        p++;
                    }
                }
                else
                {
                    // next match
                    
                    unsigned int nOldMatchCount = pNode->nMatchKeyCount;
                    unsigned int nFirstPos = pNode->nRange[nOldMatchCount-1];
                    
                    //// the MAX SIZE is old match count, but real data maybe less than that value.
                    //pDstDetail->ppItemContact = malloc( nOldMatchCount * sizeof(struct SortedContactDetailInfo*) );
                    //memset( pDstDetail->ppItemContact, 0, nOldMatchCount * sizeof(struct SortedContactDetailInfo*) );
                    
                    if( nFirstPos < strlen(pszValue) )
                    {
                        char chNextTest = *( pszValue + nFirstPos );
                        
                        int nIsMatch = is_key_match_char( nKey, chNextTest );
                        if( 0 == nIsMatch )
                        {
                            if( pNode->nMatchKeyCount < kMaxSearchKeyHistory )
                            {
                                struct SortedContactDetailInfo* pNewNode = malloc(sizeof(struct SortedContactDetailInfo));
                                memset(pNewNode, 0, sizeof(struct SortedContactDetailInfo));
                                pNewNode->nGroup = nGroup;
                                pNewNode->nIndex = nMatchCount;
                                
                                for( unsigned int i=0; i<nOldMatchCount; ++i )
                                {
                                    pNewNode->nRange[i] = pNode->nRange[i];
                                }
                                
                                pNewNode->nRange[nOldMatchCount] = pNewNode->nRange[nOldMatchCount-1] + 1;
                                
                                pNewNode->nMatchKeyCount = pNode->nMatchKeyCount + 1;
                                pNewNode->pRefContactInfo = pNode->pRefContactInfo;
                                
                                if( pRefTail )
                                {
                                    struct structTempMatchitem* pNewItem = malloc( sizeof(struct structTempMatchitem));
                                    pNewItem->item = pNewNode;
                                    pNewItem->pNext = NULL;
                                    
                                    pRefTail->pNext = pNewItem;
                                    pRefTail = pNewItem;
                                }
                                else
                                {
                                    pHead = malloc( sizeof(struct structTempMatchitem));
                                    pHead->item = pNewNode;
                                    pHead->pNext = NULL;
                                    pRefTail = pHead;
                                }
                                
                                pDstDetail->nSize++;
                                
                                nMatchCount++;
                            }
                            else
                            {
                                // overflow.
                                printf("nMatchKeyCount overflow \n");
                            }
                        }
                    }
                    else if( nFirstPos == strlen(pszValue) )
                    {
                    }
                    else
                    {
                        printf( "WHY ( nFirstPos > strlen(pszValue) )? count:%d pos:%d value:%s\n",
                               nOldMatchCount,nFirstPos, pszValue );
                    }
                }
            } // if( pNode->pRefContactInfo && pNode->nMatchKeyCount < kMaxSearchKeyHistory )
            
            //pNode = pNode->pNext;
        }   // for( unsigned int itemIndex=0; itemIndex<pSrcDetail->nSize; ++itemIndex )
        
        if( nMatchCount > 0 && pHead )
        {
            pDstDetail->nSize = 0;//nMatchCount;
            pDstDetail->ppItemContact = malloc( nMatchCount * sizeof(struct SortedContactDetailInfo*) );
            memset( pDstDetail->ppItemContact, 0, nMatchCount * sizeof(struct SortedContactDetailInfo*) );
            
            unsigned int nCount = 0;
            while ( pHead )
            {
                *(pDstDetail->ppItemContact + nCount) = pHead->item;
                struct structTempMatchitem* pTempNext = pHead->pNext;
                free( pHead );
                pHead = pTempNext;
                
                nCount++;
                pDstDetail->nSize = nCount;
                if( nCount > nMatchCount )
                {
                    // overflow.
                    printf("nCount overflow \n");
                    break;
                }
            }
            //int n = 0;
        }
    }
    
    return nRet;
}

int buildup_detail_cache_for_char(unsigned int nGroup,
                                  char nChar,
                                  const struct ContactDetailListContainer* pSrcDetail,
                                  struct ContactDetailListContainer* pDstDetail )
{
    int nRet = 0;
    
    if( pSrcDetail && pDstDetail )
    {
        // the result match count is unknown, so we need a link-list to store in temp memory,
        // then build up result value, and copy the pointers to pointer array in the result.
        
        struct structTempMatchitem
        {
            struct SortedContactDetailInfo* item;
            struct structTempMatchitem* pNext;
        };
        
        struct structTempMatchitem* pHead = NULL;
        struct structTempMatchitem* pRefTail = NULL;
        
        unsigned int nMatchCount = 0;
        
        for( unsigned int itemIndex=0; itemIndex < pSrcDetail->nSize; ++itemIndex )
        {
            const struct SortedContactDetailInfo* pNode = *( pSrcDetail->ppItemContact + itemIndex);
            if( pNode->pRefContactInfo && pNode->nMatchKeyCount < kMaxSearchKeyHistory )
            {
                const char* pszValue = NULL;
                switch (nGroup)
                {
                    case ContactDetailGroupAcronym:
                        pszValue = pNode->pRefContactInfo->pszAcronym;
                        break;
                    case ContactDetailGroupPinyin:
                        pszValue = pNode->pRefContactInfo->pszPinyin;
                        break;
                    case ContactDetailGroupName:
                        pszValue = pNode->pRefContactInfo->pszName;
                        break;
                    case ContactDetailGroupPhoneNumber:
                        pszValue = pNode->pRefContactInfo->pszPhoneNumber;
                        break;
                    default:
                        printf( "WHY NO VALID VALUE? nGroup:%d\n", nGroup );
                        continue;
                        break;
                }
                
                if( NULL == pszValue )
                {
                    //printf( "WHY NO VALID VALUE 2? nGroup:%d\n", nGroup );
                    continue;
                }
                
                if( 0 == pNode->nMatchKeyCount )
                {
                    // first match
                    
                    const char* p = pszValue;
                    unsigned int nPos = 1;
                    while( *p )
                    {
                        int nMatch = -1;
                        
                        // only match cap-alpha for  the first pinyin.
                        nMatch = is_char_match_char( nChar, *p );
                        
                        if( 0 == nMatch )
                        {
                            if( ContactDetailGroupPinyin == nGroup && ( *p <'A' || *p > 'Z' ) )
                            {
                                // careful!! the first pinyin must in CAP!!
                            }
                            else
                            {
                                struct SortedContactDetailInfo* pNewNode = malloc(sizeof(struct SortedContactDetailInfo));
                                memset(pNewNode, 0, sizeof(struct SortedContactDetailInfo));
                                pNewNode->nGroup = nGroup;
                                pNewNode->nIndex = nMatchCount;
                                pNewNode->nMatchKeyCount = 1;
                                pNewNode->nRange[0] = nPos;
                                
                                pNewNode->pRefContactInfo = pNode->pRefContactInfo;
                                
                                if( pRefTail )
                                {
                                    struct structTempMatchitem* pNewItem = malloc( sizeof(struct structTempMatchitem));
                                    pNewItem->item = pNewNode;
                                    pNewItem->pNext = NULL;
                                    
                                    pRefTail->pNext = pNewItem;
                                    pRefTail = pNewItem;
                                }
                                else
                                {
                                    pHead = malloc( sizeof(struct structTempMatchitem));
                                    pHead->item = pNewNode;
                                    pHead->pNext = NULL;
                                    pRefTail = pHead;
                                }
                                
                                pDstDetail->nSize++;
                                
                                nMatchCount++;
                            }
                        }
                        
                        nPos++;
                        p++;
                    }
                }
                else
                {
                    // next match
                    
                    unsigned int nOldMatchCount = pNode->nMatchKeyCount;
                    unsigned int nFirstPos = pNode->nRange[nOldMatchCount-1];
                    
                    //// the MAX SIZE is old match count, but real data maybe less than that value.
                    //pDstDetail->ppItemContact = malloc( nOldMatchCount * sizeof(struct SortedContactDetailInfo*) );
                    //memset( pDstDetail->ppItemContact, 0, nOldMatchCount * sizeof(struct SortedContactDetailInfo*) );
                    
                    if( nFirstPos < strlen(pszValue) )
                    {
                        char chNextTest = *( pszValue + nFirstPos );
                        
                        int nIsMatch = is_char_match_char( nChar, chNextTest );
                        if( 0 == nIsMatch )
                        {
                            if( pNode->nMatchKeyCount < kMaxSearchKeyHistory )
                            {
                                struct SortedContactDetailInfo* pNewNode = malloc(sizeof(struct SortedContactDetailInfo));
                                memset(pNewNode, 0, sizeof(struct SortedContactDetailInfo));
                                pNewNode->nGroup = nGroup;
                                pNewNode->nIndex = nMatchCount;
                                
                                for( unsigned int i=0; i<nOldMatchCount; ++i )
                                {
                                    pNewNode->nRange[i] = pNode->nRange[i];
                                }
                                
                                pNewNode->nRange[nOldMatchCount] = pNewNode->nRange[nOldMatchCount-1] + 1;
                                
                                pNewNode->nMatchKeyCount = pNode->nMatchKeyCount + 1;
                                pNewNode->pRefContactInfo = pNode->pRefContactInfo;
                                
                                if( pRefTail )
                                {
                                    struct structTempMatchitem* pNewItem = malloc( sizeof(struct structTempMatchitem));
                                    pNewItem->item = pNewNode;
                                    pNewItem->pNext = NULL;
                                    
                                    pRefTail->pNext = pNewItem;
                                    pRefTail = pNewItem;
                                }
                                else
                                {
                                    pHead = malloc( sizeof(struct structTempMatchitem));
                                    pHead->item = pNewNode;
                                    pHead->pNext = NULL;
                                    pRefTail = pHead;
                                }
                                
                                pDstDetail->nSize++;
                                
                                nMatchCount++;
                            }
                            else
                            {
                                // overflow.
                                printf("nMatchKeyCount overflow \n");
                            }
                        }
                    }
                    else if( nFirstPos == strlen(pszValue) )
                    {
                    }
                    else
                    {
                        printf( "WHY ( nFirstPos > strlen(pszValue) )? count:%d pos:%d value:%s\n",
                               nOldMatchCount,nFirstPos, pszValue );
                    }
                }
            } // if( pNode->pRefContactInfo && pNode->nMatchKeyCount < kMaxSearchKeyHistory )
            
            //pNode = pNode->pNext;
        }   // for( unsigned int itemIndex=0; itemIndex<pSrcDetail->nSize; ++itemIndex )
        
        if( nMatchCount > 0 && pHead )
        {
            pDstDetail->nSize = 0;//nMatchCount;
            pDstDetail->ppItemContact = malloc( nMatchCount * sizeof(struct SortedContactDetailInfo*) );
            memset( pDstDetail->ppItemContact, 0, nMatchCount * sizeof(struct SortedContactDetailInfo*) );
            
            unsigned int nCount = 0;
            while ( pHead )
            {
                *(pDstDetail->ppItemContact + nCount) = pHead->item;
                struct structTempMatchitem* pTempNext = pHead->pNext;
                free( pHead );
                pHead = pTempNext;
                
                nCount++;
                pDstDetail->nSize = nCount;
                if( nCount > nMatchCount )
                {
                    // overflow.
                    printf("nCount overflow \n");
                    break;
                }
            }
            //int n = 0;
        }
    }
    
    return nRet;
}

int is_key_match_char( unsigned int nKey , char chTest )
{
    int nRet = -1;
    if( 0 == nKey && ('0' == chTest) )
    {
        nRet = 0;
    }
    else if( 1 == nKey && ('1' == chTest) )
    {
        nRet = 0;
    }
    else if( 2 == nKey &&
            ('A' == chTest || 'a' == chTest ||
             'B' == chTest || 'b' == chTest ||
             'C' == chTest || 'c' == chTest ||
             '2' == chTest ) )
    {
        nRet = 0;
    }
    else if( 3 == nKey &&
            ('D' == chTest || 'd' == chTest ||
             'E' == chTest || 'e' == chTest ||
             'F' == chTest || 'f' == chTest ||
             '3' == chTest ) )
    {
        nRet = 0;
    }
    else if( 4 == nKey &&
            ('G' == chTest || 'g' == chTest ||
             'H' == chTest || 'h' == chTest ||
             'I' == chTest || 'i' == chTest ||
             '4' == chTest ) )
    {
        nRet = 0;
    }
    else if( 5 == nKey &&
            ('J' == chTest || 'j' == chTest ||
             'K' == chTest || 'k' == chTest ||
             'L' == chTest || 'l' == chTest ||
             '5' == chTest ) )
    {
        nRet = 0;
    }
    else if( 6 == nKey &&
            ('M' == chTest || 'm' == chTest ||
             'N' == chTest || 'n' == chTest ||
             'O' == chTest || 'o' == chTest ||
             '6' == chTest ) )
    {
        nRet = 0;
    }
    else if( 7 == nKey &&
            ('P' == chTest || 'p' == chTest ||
             'Q' == chTest || 'q' == chTest ||
             'R' == chTest || 'r' == chTest ||
             'S' == chTest || 's' == chTest ||
             '7' == chTest ) )
    {
        nRet = 0;
    }
    else if( 8 == nKey &&
            ('T' == chTest || 't' == chTest ||
             'U' == chTest || 'u' == chTest ||
             'V' == chTest || 'v' == chTest ||
             '8' == chTest ) )
    {
        nRet = 0;
    }
    else if( 9 == nKey &&
            ('W' == chTest || 'w' == chTest ||
             'X' == chTest || 'x' == chTest ||
             'Y' == chTest || 'y' == chTest ||
             'Z' == chTest || 'z' == chTest ||
             '9' == chTest ) )
    {
        nRet = 0;
    }
    
    return nRet;
}

int is_first_key_match_char( unsigned int nKey , char chTest )
{
    int nRet = -1;
    if( 0 == nKey && ('0' == chTest) )
    {
        nRet = 0;
    }
    else if( 1 == nKey && ('1' == chTest) )
    {
        nRet = 0;
    }
    else if( 2 == nKey &&
            ('A' == chTest ||
             'B' == chTest ||
             'C' == chTest ||
             '2' == chTest ) )
    {
        nRet = 0;
    }
    else if( 3 == nKey &&
            ('D' == chTest ||
             'E' == chTest ||
             'F' == chTest ||
             '3' == chTest ) )
    {
        nRet = 0;
    }
    else if( 4 == nKey &&
            ('G' == chTest ||
             'H' == chTest ||
             'I' == chTest ||
             '4' == chTest ) )
    {
        nRet = 0;
    }
    else if( 5 == nKey &&
            ('J' == chTest ||
             'K' == chTest ||
             'L' == chTest ||
             '5' == chTest ) )
    {
        nRet = 0;
    }
    else if( 6 == nKey &&
            ('M' == chTest ||
             'N' == chTest ||
             'O' == chTest ||
             '6' == chTest ) )
    {
        nRet = 0;
    }
    else if( 7 == nKey &&
            ('P' == chTest ||
             'Q' == chTest ||
             'R' == chTest ||
             'S' == chTest ||
             '7' == chTest ) )
    {
        nRet = 0;
    }
    else if( 8 == nKey &&
            ('T' == chTest ||
             'U' == chTest ||
             'V' == chTest ||
             '8' == chTest ) )
    {
        nRet = 0;
    }
    else if( 9 == nKey &&
            ('W' == chTest ||
             'X' == chTest ||
             'Y' == chTest ||
             'Z' == chTest ||
             '9' == chTest ) )
    {
        nRet = 0;
    }
    
    return nRet;
}

int is_char_match_char( char nChar, char chTest )
{
    int nRet = -1;
    if( chTest == nChar )
    {
        nRet = 0;
    }
    else
    {
        char ch1 = nChar;
        if( nChar >= 'A' && nChar <= 'Z' )
        {
            ch1 = nChar - 'A' + 'a';
        }
        char ch2 = chTest;
        if( chTest >= 'A' && chTest <= 'Z' )
        {
            ch2 = chTest - 'A' + 'a';
        }
        
        if( ch1 == ch2 )
        {
            nRet = 0;
        }
    }
    return nRet;
}

double calc_name_string_weight( const char* pszName )
{
    double nRet = 0.0f;
    if( pszName )
    {
        // always calc 10 char.
        const char* p = pszName;
        for (unsigned int i=0; i<10; ++i)
        {
            int nCharWeight = 0;
            char charAlpha = *p;
            if( charAlpha )
            {
                ++p;
                if( charAlpha >= 'A' && charAlpha <= 'Z' )
                {
                    nCharWeight = charAlpha - 'A';
                }
                else if( charAlpha >= 'a' && charAlpha <= 'z' )
                {
                    nCharWeight = charAlpha - 'a';
                }
                else if( charAlpha >= '0' && charAlpha <= '9' )
                {
                    nCharWeight = charAlpha - '0' + 'z' - 'a';
                }
                else
                {
                    nCharWeight = 'z' - 'a' + 10 + 1;
                }
            }
            nRet = nRet * (double)('Z'-'A'+10.0+1.0) + (double)nCharWeight;
        }
    }
    return nRet;
}

double calc_phone_number_weight( const char* pszPhoneNumber )
{
    double nRet = 0.0f;
    if( pszPhoneNumber )
    {
        // always calc 11 digit.
        const char* p = pszPhoneNumber;
        for (unsigned int i=0; i<11; ++i)
        {
            int nDigit = 0;
            char charDight = *p;
            if( charDight )
            {
                ++p;
                nDigit = charDight - '0';
                if( nDigit > 9 )
                {
                    nDigit = 9;
                }
                else if( nDigit < 0 )
                {
                    nDigit = 0;
                }
            }
            nRet = nRet * 10.0f + (double)nDigit;
        }
    }
    return nRet;
}

int push_one_char(void* pInstance, char nchar)
{
    int nRet = 0;
    if( pInstance && allContactInstances )
    {
        struct InstancePackage* instance = pInstance;
        
        if( instance->nHistoryKeyPressCount < kMaxSearchKeyHistory )
        {
            struct ContactWithChar* pSrc = NULL;
            struct ContactWithChar* pDst = &(instance->historyObjectWithChar[instance->nHistoryKeyPressCount]);
            if( 0 == instance->nHistoryKeyPressCount )
            {
                pSrc = &(instance->allContactsForChar);
            }
            else
            {
                pSrc = &(instance->historyObjectWithChar[instance->nHistoryKeyPressCount-1]);
            }
            memset( pDst, 0, sizeof(struct ContactWithChar) );
            pDst->nIndex = instance->nHistoryKeyPressCount;
            
            if( pSrc->phoneSorted )
            {
                pDst->phoneSorted = malloc(sizeof(struct ContactDetailListContainer));
                memset(pDst->phoneSorted, 0, sizeof(struct ContactDetailListContainer));
                buildup_detail_cache_for_char(ContactDetailGroupPhoneNumber, nchar, pSrc->phoneSorted, pDst->phoneSorted );
                if( 0 == pDst->phoneSorted->nSize )
                {
                    free( pDst->phoneSorted );
                    pDst->phoneSorted = NULL;
                }
                else
                {
                    quick_sort_contacts_detail( ContactDetailGroupPhoneNumber, pDst->phoneSorted );
                }
            }
            
            if( pSrc->pinyinSorted )
            {
                pDst->pinyinSorted = malloc(sizeof(struct ContactDetailListContainer));
                memset(pDst->pinyinSorted, 0, sizeof(struct ContactDetailListContainer));
                buildup_detail_cache_for_char(ContactDetailGroupPinyin, nchar, pSrc->pinyinSorted, pDst->pinyinSorted );
                if( 0 == pDst->pinyinSorted->nSize )
                {
                    free( pDst->pinyinSorted );
                    pDst->pinyinSorted = NULL;
                }
                else
                {
                    quick_sort_contacts_detail( ContactDetailGroupPinyin, pDst->pinyinSorted );
                }
            }
            
            if( pSrc->acronymSorted )
            {
                pDst->acronymSorted = malloc(sizeof(struct ContactDetailListContainer));
                memset(pDst->acronymSorted, 0, sizeof(struct ContactDetailListContainer));
                buildup_detail_cache_for_char(ContactDetailGroupAcronym, nchar, pSrc->acronymSorted, pDst->acronymSorted );
                if( 0 == pDst->acronymSorted->nSize )
                {
                    free( pDst->acronymSorted );
                    pDst->acronymSorted = NULL;
                }
                else
                {
                    quick_sort_contacts_detail( ContactDetailGroupAcronym, pDst->acronymSorted );
                }
            }
            
            instance->nHistoryKeyPressCount++;
        }
    }
    return nRet;
}
