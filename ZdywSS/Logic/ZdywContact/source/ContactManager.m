//
//  ContactManager.m
//  ContactManager
//
//  Created by mini1 on 13-6-5.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import "ContactManager.h"
#import "T9ContactRecord.h"
#import "ZdywDBManager.h"

void AddressBookDataChangeCallback(ABAddressBookRef addressBook, CFDictionaryRef info, void *context);

static ContactManager *stat_contactManager = nil;

@interface ContactManager()

//生成电话号码和联系人的关系，用来通过电话号码快速定位到联系人
- (void)createPhoneRelationShipWithContactIDs;

@end

@implementation ContactManager

@synthesize allContactDict = _allContactDict;
@synthesize sortContactDict = _sortContactDict;
@synthesize sortKeyList = _sortKeyList;
@synthesize commonContactIDList = _commonContactIDList;
@synthesize myCommonContactEngine = _myCommonContactEngine;
@synthesize myRecordEngine = _myRecordEngine;
@synthesize myDeskContactEngine = _myDeskContactEngine;
@synthesize myPhoneOwnerShipEngine = _myPhoneOwnerShipEngine;
@synthesize myAddressBookHandle = _myAddressBookHandle;
@synthesize canLoadData;
@synthesize loadContactFlag = _loadContactFlag;

- (id)init
{
    self = [super init];
    if (self)
    {
//        _loadHeadQueue = dispatch_queue_create("LoadContactHeadQueue", NULL);
        _loadHeadQueue = [[NSOperationQueue alloc] init];
        [_loadHeadQueue setMaxConcurrentOperationCount:1];
        
        _allContactDict = [[NSMutableDictionary alloc] initWithCapacity:2];
        _sortKeyList = [[NSMutableArray alloc] initWithCapacity:2];
        _sortContactDict = [[NSMutableDictionary alloc] initWithCapacity:2];
        _commonContactIDList = [[NSMutableArray alloc] initWithCapacity:2];
        _phoneRelationDict = [[NSMutableDictionary alloc] initWithCapacity:2];
        _contactHeadDict = [[NSMutableDictionary alloc] initWithCapacity:2];
        _loadContactFlag = NO;
        _loadSearchEngineFlag = NO;
        self.canLoadData = YES;
        _contactLoadCondition = [[NSCondition alloc] init];
        
        _mySearchEngine = [[T9SearchEngine alloc] init];
        _myKeySearchEngine = [[T9SearchEngine alloc] init];
        
        _myRecordEngine = [[RecordEngine alloc] init];
        _myCommonContactEngine = [[CommonContactEngine alloc] init];
        _myDeskContactEngine = [[DeskContactEngine alloc] init];
        _myPhoneOwnerShipEngine = [[PhoneOnwerShipEngine alloc] init];
        
        [self performSelectorOnMainThread:@selector(registerAddressBookObeserver)
                               withObject:nil
                            waitUntilDone:YES];
    }
    return self;
}

- (void)dealloc
{
    if (nil != _refreshTimer)
    {
        if ([_refreshTimer isValid])
        {
            [_refreshTimer invalidate];
        }
        [_refreshTimer release];
        _refreshTimer = nil;
    }
    
    if (_mySearchEngine)
    {
        [_mySearchEngine release];
        _mySearchEngine = nil;
    }
    
    if (_myCommonContactEngine)
    {
        [_myCommonContactEngine release];
        _myCommonContactEngine = nil;
    }
    
    if (_myRecordEngine)
    {
        [_myRecordEngine release];
        _myRecordEngine = nil;
    }
    
    if (_myKeySearchEngine)
    {
        [_myKeySearchEngine release];
        _myKeySearchEngine = nil;
    }
    
    if (_myPhoneOwnerShipEngine)
    {
        [_myPhoneOwnerShipEngine release];
        _myPhoneOwnerShipEngine = nil;
    }
    
    self.myDeskContactEngine = nil;
    
    [_commonContactIDList release];
    _commonContactIDList = nil;
    
    [_sortKeyList release];
    _sortKeyList = nil;
    
    [_sortContactDict release];
    _sortContactDict = nil;
    
    [_allContactDict release];
    _allContactDict = nil;
    
    [_contactHeadDict release];
    _contactHeadDict = nil;
    
    [_contactLoadCondition release];
    _contactLoadCondition = nil;
    
//    dispatch_release(_loadHeadQueue);
    [_loadHeadQueue cancelAllOperations];
    [_loadHeadQueue release];
    _loadHeadQueue = nil;
    
    if (_myAddressBookHandle)
    {
        ABAddressBookUnregisterExternalChangeCallback(_myAddressBookHandle, AddressBookDataChangeCallback, self);
    }
    
    [super dealloc];
}

/*
 函数描述：单列
 输入参数：N/A
 输出参数：N/A
 返 回 值：ContactManager   单例对象
 作    者：刘斌
 */
+ (ContactManager *)shareInstance
{
    @synchronized(self)
    {
        if (stat_contactManager == nil)
        {
            stat_contactManager = [[ContactManager alloc] init];
        }
    }
    
    return stat_contactManager;
}

/*
 函数描述：监听通讯录
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)registerAddressBookObeserver
{
    _myAddressBookHandle = NULL;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        _myAddressBookHandle = ABAddressBookCreateWithOptions(NULL, NULL);
    }
    else
    {
        _myAddressBookHandle = ABAddressBookCreate();
    }
    ABAddressBookRegisterExternalChangeCallback(_myAddressBookHandle, AddressBookDataChangeCallback, NULL);
}

/*
 函数描述：创建用户数据库
 输入参数：userID
 输出参数：N/A
 返 回 值：BOOL   成功与否
 作    者：刘斌
 */
- (BOOL)createUserDataBaseWithUserID:(NSString *)userID
{
    if (0 == [userID length])
    {
        return NO;
    }
    
    //初始化数据库
    NSArray *aLis = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                        NSUserDomainMask, YES);
    if ([aLis count] > 0)
    {
        BOOL ret = [[ZdywDBManager shareInstance] createUserDatabase:userID];
        
        return ret;
    }
    else
    {
        NSLog(@"获取document目录失败");
        return NO;
    }
}

//生成电话号码和联系人的关系，用来通过电话号码快速定位到联系人
- (void)createPhoneRelationShipWithContactIDs
{
    if (_loadContactFlag)
    {
        return;
    }
    
    for (NSString *aKey in _sortKeyList)
    {
        NSArray *aList = [_sortContactDict objectForKey:aKey];
        for (ContactNode *oneContact in aList)
        {
            for (NSArray *phoneList in [oneContact.phoneDict allValues])
            {
                for (NSString *phoneNum in phoneList)
                {
                    NSMutableArray *idList = [[NSMutableArray alloc] initWithCapacity:2];
                    
                    NSArray *pList = [_phoneRelationDict objectForKey:phoneNum];
                    [idList addObjectsFromArray:pList];
                    if (![idList containsObject:[NSNumber numberWithInt:oneContact.contactID]])
                    {
                        [idList addObject:[NSNumber numberWithInt:oneContact.contactID]];
                    }
                    
                    [_phoneRelationDict setObject:idList
                                           forKey:phoneNum];
                    [idList release];
                }
            }
        }
    }
}

/*
 函数描述：加载联系人线程
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)loadContactThread
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyLoadContactDataBegin
                                                        object:nil
                                                      userInfo:nil];
    
    _loadContactFlag = YES;
    
    ABAddressBookRef  addressBookhandle = NULL;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        addressBookhandle = ABAddressBookCreateWithOptions(NULL, NULL);
    }
    else
    {
        addressBookhandle = ABAddressBookCreate();
    }
    
    if (addressBookhandle == NULL)
    {
        _loadContactFlag = NO;
        return;
    }
    
    NSLog(@"联系人开始加载");
    
    [_contactLoadCondition lock];
    [_sortContactDict removeAllObjects];
    [_sortKeyList removeAllObjects];
    [_allContactDict removeAllObjects];
    [_phoneRelationDict removeAllObjects];
    
    //取得所有地址本的信息
    CFArrayRef personList = ABAddressBookCopyArrayOfAllPeople(addressBookhandle);
    CFIndex pCount = CFArrayGetCount(personList);
    
    NSMutableArray *keyList = [[NSMutableArray alloc] initWithCapacity:2];
    
    for (int i = 0; i < pCount; ++i)
    {
        ABRecordRef onePerson = CFArrayGetValueAtIndex(personList, i);
        
        ContactNode *oneContact = [[ContactNode alloc] init];
        [oneContact createContactDataWithPerson:onePerson];
        
        if (kInValidContactID != oneContact.contactID)
        {
            [_allContactDict setObject:oneContact
                                forKey:[NSString stringWithFormat:@"%d",oneContact.contactID]];
            
            //获取联系人所在的分区
            NSString *sortKey = [oneContact getContactSortKey];
            
            //添加到相应的分区中
            NSArray *aList = [_sortContactDict objectForKey:sortKey];
            NSMutableArray *bList = [[NSMutableArray alloc] initWithCapacity:2];
            [bList addObjectsFromArray:aList];
            [bList addObject:oneContact];
            [_sortContactDict setObject:bList//[bList sortedArrayUsingSelector:@selector(compareBynameWithOther:)]
                                 forKey:sortKey];
            [bList release];
            
            //添加分区键值
            if (![keyList containsObject:sortKey])
            {
                [keyList addObject:sortKey];
            }
        }
    }
    
    //对键值排序
    [_sortKeyList addObjectsFromArray:[keyList sortedArrayUsingSelector:@selector(compare:)]];
    
    //调整#的位置
    NSInteger index = [_sortKeyList indexOfObject:@"#"];
    if (index != NSNotFound)
    {
        [_sortKeyList removeObjectAtIndex:index];
        [_sortKeyList addObject:@"#"];
    }
    
    //每一分区的联系人排序
    for (NSString *aKey in _sortKeyList)
    {
        NSMutableArray *sortedList = [[NSMutableArray alloc] initWithCapacity:2];
        [sortedList addObjectsFromArray:[_sortContactDict objectForKey:aKey]];
        [_sortContactDict setObject:[sortedList sortedArrayUsingSelector:@selector(compareBynameWithOther:)]
                             forKey:aKey];
        [sortedList release];
    }
    
    _loadContactFlag = NO;
    
    
    //加载常用联系人
    [self pickUpCommonContact];
    
    //创建电话号码与联系人的关系
    [self createPhoneRelationShipWithContactIDs];
    
    //加载搜索引擎
    [self performSelectorOnMainThread:@selector(startSearchEngine)
                           withObject:nil
                        waitUntilDone:YES];
    
    [_contactLoadCondition unlock];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyContactDataChanged
                                                        object:nil
                                                      userInfo:nil];
    
    NSLog(@"联系人加载结束");
    
    [pool release];
}

- (void)lockRefresh
{
    _isDataChanged = YES;
    if (nil != _refreshTimer)
    {
        if ([_refreshTimer isValid])
        {
            [_refreshTimer invalidate];
        }
        [_refreshTimer release];
        _refreshTimer = nil;
    }
    
    _refreshTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(unLockRefresh)
                                                    userInfo:nil
                                                     repeats:NO] retain];
}

- (void)unLockRefresh
{
    _isDataChanged = NO;
}

/*
 函数描述：加载联系人
 输入参数：N/A
 输出参数：N/A
 返 回 值：BOOL   是否可以加载
 作    者：刘斌
 */
- (BOOL)loadAllContact
{
    if (!self.canLoadData)
    {
        return NO;
    }
    
    if ([self addressBookIsAuthentication:NO])
    {
        [[ContactManager shareInstance] clearContactHeadCache];
        
        if (!_isDataChanged)
        {
            [self performSelectorOnMainThread:@selector(lockRefresh)
                                   withObject:nil
                                waitUntilDone:YES];
        }
        else
        {
            return NO;
        }
        
        //开启加载线程
        //[NSThread detachNewThreadSelector:@selector(loadContactThread) toTarget:self withObject:nil];
        
        //创建操作队列
        NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
        //设置队列中最大的操作数
        [operationQueue setMaxConcurrentOperationCount:1];
        //创建操作（最后的object参数是传递给selector方法的参数）
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadContactThread) object:nil];
        //将操作添加到操作队列
        [operationQueue addOperation:operation];
        [operation release];
        [operationQueue release];
        
        return YES;
    }
    else
    {
        NSLog(@"通讯录未鉴权");
        return NO;
    }
}

/*
 函数描述：获取排序后的联系人列表
 输入参数：removeList : 删除的联系人ID列表
 输出参数：sList      : 排序索引的key
 返 回 值：NSDictionary   处理后的联系人排序列表
 作    者：刘斌
 */
- (NSDictionary *)getSortContactDictAfterRemoveList:(NSArray *)removeList
                                 outWithSortKeyList:(NSMutableArray **)sList
{
    @synchronized(_sortContactDict)
    {
        if (_loadContactFlag)
        {
            return nil;
        }
        
        if (0 == [_sortContactDict count])
        {
            return nil;
        }
        
        [*sList removeAllObjects];
        [*sList addObjectsFromArray:_sortKeyList];
        
        NSMutableDictionary *existDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [existDict addEntriesFromDictionary:_sortContactDict];
        
        for (id oneContactID in removeList)
        {
            //获取联系人
            ContactNode *oneContact = [self getOneContactByID:[oneContactID integerValue]];
            if (nil != oneContact)
            {
                //获取联系人所在的分区
                NSString *sortKey = [oneContact getContactSortKey];
                
                NSArray *contactList = [existDict objectForKey:sortKey];
                
                //从列表中删除ID为oneContactID 的联系人
                NSMutableArray *aList = [NSMutableArray arrayWithCapacity:2];
                [aList addObjectsFromArray:contactList];
                for (ContactNode *aContact in aList)
                {
                    if (aContact.contactID == [oneContactID intValue])
                    {
                        [aList removeObject:aContact];
                        if ([aList count] == 0)
                        {
                            if ([*sList indexOfObject:sortKey] != NSNotFound)
                            {
                                [*sList removeObject:sortKey];
                            }
                        }
                        break;
                    }
                }
                [existDict setObject:aList forKey:sortKey];
            }
        }
        
        return existDict;
    }
}

/*
 函数描述：通讯录是否鉴权
 输入参数：N/A
 输出参数：N/A
 返 回 值：BOOL   是否可以鉴权了
 作    者：刘斌
 */
- (BOOL)addressBookIsAuthentication:(BOOL)isCompleteBlock
{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        if (status == kABAuthorizationStatusNotDetermined)
        {
            if (isCompleteBlock)
            {
                dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                
                __block BOOL hasGranted = NO;
                ABAddressBookRef addressBookhandle = ABAddressBookCreateWithOptions(NULL, NULL);
                ABAddressBookRequestAccessWithCompletion(addressBookhandle, ^(bool granted, CFErrorRef error) {
                    hasGranted = granted;
                    dispatch_semaphore_signal(sema);
                });
                dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
                dispatch_release(sema);
                
                if (hasGranted)
                {
                    [self loadAllContact];
                }
            }
        }
        
        return (status == kABAuthorizationStatusAuthorized);
    }
    else
    {
        return YES;
    }
}

/*
 函数描述：根据联系人ID获取联系人的信息
 输入参数：contactID   联系人ID
 输出参数：N/A
 返 回 值：ContactNodel   联系人信息
 作    者：刘斌
 */
- (ContactNode *)getOneContactByID:(NSInteger)contactID
{
    if (_loadContactFlag || kInValidContactID == contactID)
    {
        return nil;
    }
    else
    {
        return [_allContactDict objectForKey:[NSString stringWithFormat:@"%d",contactID]];
    }
}

/*
 函数描述：根据联系人ID获取通讯录联系人的信息
 输入参数：contactID   联系人ID
 输出参数：N/A
 返 回 值：ABRecordRef   联系人信息
 作    者：刘斌
 */
- (ABRecordRef)getOneABRecordWithID:(NSInteger)contactID
{
    if (kInValidContactID == contactID)
    {
        return NULL;
    }
    
    if (_loadContactFlag)
    {
        return NULL;
    }
    
    ABAddressBookRef  addressBookhandle = NULL;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        addressBookhandle = ABAddressBookCreateWithOptions(NULL, NULL);
    }
    else
    {
        addressBookhandle = ABAddressBookCreate();
    }
    
    if (NULL == addressBookhandle)
    {
        return NULL;
    }
    
    ABRecordRef onePerson = ABAddressBookGetPersonWithRecordID(addressBookhandle, contactID);
    return onePerson;
}

/*
 函数描述：删除联系人
 输入参数：contactID  联系人的ID
 输出参数：N/A
 返 回 值：BOOL       是否删除成功
 作    者：刘斌
 */
- (BOOL)deleteOneContactByID:(NSInteger)contactID
{
    if (kInValidContactID == contactID)
    {
        return NO;
    }
    
    if (_loadContactFlag)
    {
        return NO;
    }
    
    if (![self addressBookIsAuthentication:NO])
    {
        return NO;
    }
    
    ABAddressBookRef  addressBookhandle = NULL;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        addressBookhandle = ABAddressBookCreateWithOptions(NULL, NULL);
    }
    else
    {
        addressBookhandle = ABAddressBookCreate();
    }
    
    if (NULL == addressBookhandle)
    {
        return NO;
    }
    
    ABRecordRef onePerson = ABAddressBookGetPersonWithRecordID(addressBookhandle, contactID);
    BOOL ret = ABAddressBookRemoveRecord(addressBookhandle, onePerson, NULL);
    if (ret)
    {
        return ABAddressBookSave(addressBookhandle, NULL);
    }
    else
    {
        return NO;
    }
}

/*
 函数描述：修改或修改联系人
 输入参数：aContact 新的联系人信息
 输出参数：N/A
 返 回 值：BOOL   是否成功
 作    者：刘斌
 */
- (BOOL)updateOneContact:(ContactNode *)aContact
{
    if (nil == aContact)
    {
        return NO;
    }
    
    if (_loadContactFlag)
    {
        return NO;
    }
    
    if (![self addressBookIsAuthentication:NO])
    {
        return NO;
    }
    
    ABAddressBookRef  addressBookhandle = NULL;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        addressBookhandle = ABAddressBookCreateWithOptions(NULL, NULL);
    }
    else
    {
        addressBookhandle = ABAddressBookCreate();
    }
    
    if (NULL == addressBookhandle)
    {
        return NO;
    }
    
    BOOL ret = YES;
    ABRecordRef onePerson = ABAddressBookGetPersonWithRecordID(addressBookhandle, aContact.contactID);
    if (NULL == onePerson)
    {
        onePerson = ABPersonCreate();
        [aContact insertDataIntoPerson:onePerson];
        
        ret = ABAddressBookAddRecord(addressBookhandle, onePerson, NULL);
    }
    else
    {
        [aContact insertDataIntoPerson:onePerson];
    }
    
    if (ret)
    {
        return ABAddressBookSave(addressBookhandle, NULL);
    }
    else
    {
        return NO;
    }
}

/*
 函数描述：根据电话号码匹配联系人
 输入参数：phoneNum    电话号码
 输出参数：N/A
 返 回 值：ContactNode   联系人信息
 作    者：刘斌
 */
- (ContactNode *)contactInfoWithPhone:(NSString *)phoneNum
{
    if (0 == [phoneNum length])
    {
        return nil;
    }
    
    NSArray *aList = [_phoneRelationDict objectForKey:phoneNum];
    if (0 != [aList count])
    {
        return [self getOneContactByID:[[aList objectAtIndex:0] intValue]];
    }
    else
    {
        return nil;
    }
}

/*
 函数描述：清空联系人缓存
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)clearContactHeadCache
{
    @synchronized(_contactHeadDict)
    {
        [_loadHeadQueue cancelAllOperations];
        [_contactHeadDict removeAllObjects];
    }
}

- (void)loadHeadInThread:(NSString *)contactIDStr
{
    if (0 == [contactIDStr length])
    {
        return;
    }
    
    if (_loadContactFlag)
    {
        return;
    }
    
    
    NSAutoreleasePool  *pool = [[NSAutoreleasePool alloc] init];
    ABRecordRef onePerson = [self getOneABRecordWithID:[contactIDStr integerValue]];
    if (NULL != onePerson)
    {
        if (ABPersonHasImageData(onePerson))
        {
            NSData *imageData = (NSData*)ABPersonCopyImageDataWithFormat(onePerson, kABPersonImageFormatThumbnail);
            if (imageData)
            {
                UIImage *img = [UIImage imageWithData:imageData];
                if (nil != img)
                {
                    @synchronized(_contactHeadDict)
                    {
                        [_contactHeadDict setObject:[NSDictionary dictionaryWithObject:img
                                                                                forKey:@"Image"]
                                             forKey:contactIDStr];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyContactHeadChanged
                                                                            object:nil
                                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                    contactIDStr,@"ContactID",
                                                                                    img,@"Image",
                                                                                    nil]];
                    }
                    NSLog(@"取到%@头像",contactIDStr);
                }
                else
                {
                    NSLog(@"取到%@头像为空",contactIDStr);
                }
                
                
                CFRelease(imageData);
            }
            else
            {
                NSLog(@"取到%@头像为空",contactIDStr);
            }
        }
        else
        {
            NSLog(@"取到%@头像为空",contactIDStr);
        }
        CFRelease(onePerson);
    }
    
    [pool release];
}

/*
 函数描述：根据联系人ID获取联系人头像
 输入参数：contactID  联系人的ID
 输出参数：N/A
 返 回 值：UIImage   联系人头像
 作    者：刘斌
 */
- (UIImage *)contactHeadWithContactID:(NSInteger)contactID
{
    if (_loadContactFlag)
    {
        return nil;
    }
    
    NSDictionary *aDict = [_contactHeadDict objectForKey:[NSString stringWithFormat:@"%d",contactID]];
    if (nil == aDict)
    {
        [_contactHeadDict setObject:[NSDictionary dictionaryWithObject:@"" forKey:@"NoImage"]
                             forKey:[NSString stringWithFormat:@"%d",contactID]];
        
        NSInvocationOperation *loadHeadOperation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                        selector:@selector(loadHeadInThread:)
                                                                                          object:[NSString stringWithFormat:@"%d",contactID]];
        [_loadHeadQueue addOperation:loadHeadOperation];
        [loadHeadOperation release];
    }
    else
    {
        UIImage *aImage = [aDict objectForKey:@"Image"];
        return aImage;
    }
    
    return nil;
}

#pragma mark - 联系人的备份和恢复

/*
 函数描述：恢复联系人
 输入参数：jsonDataList 联系人json数据列表
 recoverType  恢复类型 0 完全覆盖本地数据 1与本地数据合并
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)recoveryContactWithDataList:(NSArray *)jsonDataList recoveryType:(NSUInteger)recoveryType
{
    if ([jsonDataList count] == 0)
    {
        return;
    }
    
    if ([self addressBookIsAuthentication:NO])
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        ABAddressBookRef  addressHandle;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
        {
            addressHandle = ABAddressBookCreateWithOptions(NULL, NULL);
        }
        else
        {
            addressHandle = ABAddressBookCreate();
        }
        
        NSMutableArray *recoveryList = [[NSMutableArray alloc] initWithCapacity:2];
        NSMutableArray *localList = [[NSMutableArray alloc] initWithCapacity:2];
        for (NSDictionary *oneJsonData in jsonDataList)
        {
            ContactNode *oneContact = [[ContactNode alloc] init];
            [oneContact createContactDataWithJsonDict:oneJsonData];
            [recoveryList addObject:oneContact];
            [oneContact release];
        }
        
        //取得所有地址本的信息
        CFArrayRef personList = ABAddressBookCopyArrayOfAllPeople(addressHandle);
        CFIndex pCount = CFArrayGetCount(personList);
        if (recoveryType == 0)
        {
            for (int i = 0; i < pCount; ++i)
            {
                ABRecordRef onePerson = CFArrayGetValueAtIndex(personList, i);
                ABAddressBookRemoveRecord(addressHandle, onePerson, NULL);
            }
            
            //添加新的
            for (ContactNode *aContact in recoveryList)
            {
                ABRecordRef newPerson = ABPersonCreate();
                [aContact insertDataIntoPerson:newPerson];
                ABAddressBookAddRecord(addressHandle, newPerson, NULL);
                CFRelease(newPerson);
            }
            
            ABAddressBookSave(addressHandle, NULL);
        } else {
            for (int i = 0; i < pCount; ++i)
            {
                ABRecordRef onePerson = CFArrayGetValueAtIndex(personList, i);
                ContactNode *oneContact = [[ContactNode alloc] init];
                [oneContact createContactDataWithPerson:onePerson];
                [localList addObject:oneContact];
            }
            for (ContactNode *recoveryNode in recoveryList) {
                BOOL isAlreadyExists = NO;
                for (ContactNode *localNode in localList) {
                    if ([[recoveryNode getContactFullName] isEqualToString:[localNode getContactFullName]] ) {
                        if (![localNode isContainsAllPhoneInOthers:recoveryNode]) {
                            [localNode megerOtherContactPhones:recoveryNode];
                            [self updateOneContact:localNode];
                        }
                        isAlreadyExists = YES;
                        break;
                    }
                }
                if (isAlreadyExists == NO) {
                    ABRecordRef newPerson = ABPersonCreate();
                    [recoveryNode insertDataIntoPerson:newPerson];
                    ABAddressBookAddRecord(addressHandle, newPerson, NULL);
                    CFRelease(newPerson);
                }
            }
            ABAddressBookSave(addressHandle, NULL);
        }
        [localList release];
        
        if (personList)
        {
            CFRelease(personList);
        }
        if (addressHandle)
        {
            CFRelease(addressHandle);
        }
        
        [recoveryList release];
        [pool release];
    }
}

/*
 函数描述：获取联系人备份的json字符串
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSString   json字符串
 作    者：刘斌
 */
- (NSString *)getRecoveryJsonString
{
    NSMutableString *jsonStr = [[NSMutableString alloc] initWithCapacity:1];
    
    if ([self addressBookIsAuthentication:NO])
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        ABAddressBookRef  addressHandle;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
        {
            addressHandle = ABAddressBookCreateWithOptions(NULL, NULL);
        }
        else
        {
            addressHandle = ABAddressBookCreate();
        }
        
        //取得所有地址本的信息
        CFArrayRef personList = ABAddressBookCopyArrayOfAllPeople(addressHandle);
        CFIndex pCount = CFArrayGetCount(personList);
        
        if (pCount > 0)
        {
            [jsonStr appendString:@"["];
            
            //获取分组信息，记录每个分组的信息（key：groupID  value：（分组名称、和成员ID列表组成的字典)
            NSMutableDictionary  *aDict = [[NSMutableDictionary alloc] initWithCapacity:2];
            
            //联系人在分组中的情况，记录每个联系人所在分组的ID数组（key：ContactID   value：groupID数组）
            NSMutableDictionary  *bDict = [[NSMutableDictionary alloc] initWithCapacity:2];
            
            //1.获取所有的分组
            CFArrayRef groupList = ABAddressBookCopyArrayOfAllGroups(addressHandle);
            CFIndex gCount = CFArrayGetCount(groupList);
            
            //2.获取每一分租的成员信息
            for (int i = 0; i < gCount; ++i)
            {
                ABRecordRef oneGroup = CFArrayGetValueAtIndex(groupList, i);
                CFArrayRef memberList = ABGroupCopyArrayOfAllMembers(oneGroup);
                CFIndex mCount = memberList != NULL ? CFArrayGetCount(memberList) : 0;
                
                //组名
                NSString *groupName = (NSString *)ABRecordCopyValue(oneGroup,kABGroupNameProperty);
                
                //分组ID
                ABRecordID groupID = ABRecordGetRecordID(oneGroup);
                
                //分组成员信息
                NSMutableArray *memberIDList = [[NSMutableArray alloc] initWithCapacity:2];
                
                for (int j = 0; j < mCount; ++j)
                {
                    ABRecordRef oneMerber = CFArrayGetValueAtIndex(memberList, j);
                    ABRecordID  memberID = ABRecordGetRecordID(oneMerber);
                    
                    //将该分组的ID加入到成员的分组列表中
                    NSString *aKey = [NSString stringWithFormat:@"%d",memberID];
                    NSMutableArray *bList = [[NSMutableArray alloc] initWithCapacity:2];
                    NSArray *aList = [bDict objectForKey:aKey];
                    [bList addObjectsFromArray:aList];
                    if (![bList containsObject:[NSNumber numberWithInt:groupID]])
                    {
                        [bList addObject:[NSNumber numberWithInt:groupID]];
                    }
                    [bDict setObject:bList forKey:aKey];
                    [bList release];
                    
                    
                    //该分组添加成员ID信息
                    [memberIDList addObject:[NSNumber numberWithInt:memberID]];
                }
                
                [aDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  memberIDList,@"member",
                                  groupName,@"name",
                                  nil]
                          forKey:[NSString stringWithFormat:@"%d",groupID]];
                
                [memberIDList release];
            }
            
            for (int i = 0; i < pCount; ++i)
            {
                ABRecordRef onePerson = CFArrayGetValueAtIndex(personList, i);
                ContactNode *oneContact = [[ContactNode alloc] init];
                [oneContact createContactDataWithPerson:onePerson];
                
                //设置联系人的分组信息
                NSArray *groupInfoList = [bDict objectForKey:[NSString stringWithFormat:@"%d",oneContact.contactID]];
                if (0 != [groupInfoList count])
                {
                    for (NSNumber *groupIDNum in groupInfoList)
                    {
                        NSString *gKey = [NSString stringWithFormat:@"%d",[groupIDNum intValue]];
                        //获取分组名称
                        NSString *aGroupName = nil;
                        NSDictionary *groupInfoDict = (NSDictionary *)[aDict objectForKey:gKey];
                        if (nil != groupInfoDict)
                        {
                            aGroupName = [groupInfoDict objectForKey:@"name"];
                        }
                        
                        if (nil == aGroupName)
                        {
                            aGroupName = @"";
                        }
                        
                        [oneContact.groupDict setObject:aGroupName
                                                 forKey:gKey];
                    }
                }
                else
                {
                    [oneContact.groupDict setObject:@""
                                             forKey:@"0"];
                }
                
                //创建该联系人的
                NSString *aStr = [oneContact createJsonString];
                if (0 != [aStr length])
                {
                    [jsonStr appendString:aStr];
                }
                
                if (i != pCount -1)
                {
                    [jsonStr appendString:@","];
                }
            }
            
            [bDict release];
            [aDict release];
            
            [jsonStr appendString:@"]"];
        }
        
        [pool release];
    }
    
    return [jsonStr autorelease];
}

#pragma mark - Search
- (void)loadSearchEngineThread
{
    while (_loadContactFlag)
    {
        NSLog(@"等待联系人加载完毕");
        usleep(100);
    }
    
    _loadSearchEngineFlag = YES;
    
    if (_mySearchEngine)
    {
        [_mySearchEngine reloadDataSourceForSearchOnly:[self.allContactDict allValues]];
    }
    
    if (_myKeySearchEngine)
    {
        [_myKeySearchEngine reloadDataSource:[self.allContactDict allValues]];
    }
    
    _loadSearchEngineFlag = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySearchLoadFinished
                                                        object:nil
                                                      userInfo:nil];
}

/*
 函数描述：初始化搜索引擎
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)startSearchEngine
{
    [NSThread detachNewThreadSelector:@selector(loadSearchEngineThread)
                             toTarget:self
                           withObject:nil];
}

/*
 函数描述：增加一个搜索键
 输入参数：NSInteger   搜索键（0~9）
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)pushOneKey:(NSInteger)aKey
{
    if (aKey < 0 || aKey > 9)
    {
        NSLog(@"搜索键值不在区域内");
    }
    
    if (_myKeySearchEngine && !_loadContactFlag && !_loadSearchEngineFlag)
    {
        [_myKeySearchEngine pushOneKey:aKey];
    }
}

/*
 函数描述：弹出最后一个搜索键
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)popOneKey
{
    if (_myKeySearchEngine && !_loadContactFlag && !_loadSearchEngineFlag)
    {
        [_myKeySearchEngine popOneKey];
    }
}

/*
 函数描述：重置搜索键
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)resetKey
{
    if (_myKeySearchEngine && !_loadContactFlag && !_loadSearchEngineFlag)
    {
        [_myKeySearchEngine resetKey];
    }
}

/*
 函数描述：根据匹配字符串搜索(T9ContactRecord对象集合）
 输入参数：strSearchText    匹配的字符串
 输出参数：N/A
 返 回 值：NSArray         搜索结果
 作    者：刘斌
 */
- (NSArray *)searchResultWithText:(NSString *)strSearchText
{
    if (_mySearchEngine && !_loadContactFlag && !_loadSearchEngineFlag)
    {
        return [_mySearchEngine searchTextOnly:strSearchText];
    }
    else
    {
        return nil;
    }
}

/*
 函数描述：根据匹配字符串获取搜索结果
 输入参数：strSearchText    匹配字符串
 rList             不在搜索范围内的联系人
 输出参数：N/A
 返 回 值：NSArray   搜索结果
 作    者：刘斌
 */
- (NSArray*)searchResultWithText:(NSString*)strSearchText removeList:(NSArray *)rList
{
    NSArray *aList = [self searchResultWithText:strSearchText];
    if (0 != [aList count])
    {
        NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:2];
        for (T9ContactRecord *oneRecord in aList)
        {
            NSNumber *key = [NSNumber numberWithInt:oneRecord.abRecordID];
            if (![rList containsObject:key])
            {
                [resultList addObject:oneRecord];
            }
        }
        return resultList;
    }
    else
    {
        return nil;
    }
}

/*
 函数描述：获取搜索结果(T9ContactRecord对象集合）
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSArray         搜索结果
 作    者：刘斌
 */
- (NSArray *)searchResult
{
    if (_myKeySearchEngine && !_loadContactFlag && !_loadSearchEngineFlag)
    {
        return [_myKeySearchEngine getSearchResult];
    }
    else
    {
        return nil;
    }
}

/*
 函数描述：获取搜索结果
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSArray   搜索结果
 rList       不再搜索范围内的联系人
 作    者：刘斌
 */
- (NSArray*)searchResultWithRemoveList:(NSArray *)rList
{
    NSArray *aList = [self searchResult];
    if (0 != [aList count])
    {
        NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:2];
        for (T9ContactRecord *oneRecord in aList)
        {
            NSNumber *key = [NSNumber numberWithInt:oneRecord.abRecordID];
            if (![rList containsObject:key])
            {
                [resultList addObject:oneRecord];
            }
        }
        return resultList;
    }
    else
    {
        return nil;
    }
}

#pragma mark - 常用联系人
/*
 函数描述：提取常用联系人
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)pickUpCommonContact
{
    if (_loadContactFlag)
    {
        
    }
    else
    {
        [_commonContactIDList removeAllObjects];
        
        //获取数据库中所有的常用联系人
        NSMutableArray  *commonList = [NSMutableArray arrayWithCapacity:2];
        [commonList addObjectsFromArray:[_myCommonContactEngine commonContactList]];
        
        for (NSString *oneKey in _sortKeyList)
        {
            NSArray *aList = [_sortContactDict objectForKey:oneKey];
            for (ContactNode *oneContact in aList)
            {
                NSNumber *cIDNum = [NSNumber numberWithInt:oneContact.contactID];
                if ([commonList containsObject:cIDNum])
                {
                    [_commonContactIDList addObject:cIDNum];
                }
            }
        }
    }
}

/*
 函数描述：刷新常用联系人
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)refreshCommonContact
{
    if (_loadContactFlag)
    {
        return;
    }
    else
    {
        [self pickUpCommonContact];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyCommonContactDataChanged
                                                            object:nil
                                                          userInfo:nil];
    }
}

/*
 函数描述：是否为常用联系人
 输入参数：contactID   联系人ID
 输出参数：N/A
 返 回 值：BOOL   是否为常用联系人
 作    者：刘斌
 */
- (BOOL)isCommonContactWithID:(NSInteger)contactID
{
    if (!_loadContactFlag)
    {
        NSNumber *oneNum = [NSNumber numberWithInteger:contactID];
        if ([self.commonContactIDList containsObject:oneNum])
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark - 通话记录
/*
 函数描述：合并通话记录
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSArray   RecordMegerNode集合
 作    者：刘斌
 */
- (NSArray *)megerContactRecord
{
    NSAutoreleasePool  *pool = [[NSAutoreleasePool alloc] init];
    
    //获取所有的通话记录
    NSArray *allRecordList = [_myRecordEngine allRecord];
    
    //用来存放通话记录的索引键值
    NSMutableArray *recordSortKeyList = [[NSMutableArray alloc] initWithCapacity:2];
    
    //用来存放通话记录
    NSMutableDictionary *recordDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    for (NSDictionary *oneRecordDic in allRecordList)
    {
        ContactRecordNode *oneRecord = [[ContactRecordNode alloc] initWithDictionary:oneRecordDic];
        //设置匹配到的联系人ID
        NSInteger pID = kInValidContactID;
        
        //获取通话记录对应的联系人
        ContactNode *oneContact = [self getOneContactByID:oneRecord.contactID];
        
        //若不存在，根据电话号码搜索联系人
        if (nil == oneContact)
        {
            oneContact = [self contactInfoWithPhone:oneRecord.phoneNum];
        }
        else  //判断电话号码是否在联系人中
        {
            NSArray *cList = [_phoneRelationDict objectForKey:oneRecord.phoneNum];
            if ([cList count] > 0)
            {
                //电话号码不在联系人中，匹配另一联系人
                if (![cList containsObject:[NSNumber numberWithInt:oneContact.contactID]]) 
                {
                    pID = [[cList objectAtIndex:0] integerValue];
                    oneContact = [self getOneContactByID:pID];
                }
                else //电话号码在联系人中，匹配该联系人
                {
                    
                }
            }
            else //电话号码不在联系人中
            {
                oneContact = nil;
            }
            
        }
        
        //若根据通电的电话也没有获取到联系人
        if (nil == oneContact)
        {
            pID = kInValidContactID;
        }
        else //根据电话获取到了联系人
        {
            pID = oneContact.contactID;
        }
        
        //设置索引的键值
        NSString *sortKey = nil;
        if (pID == kInValidContactID)
        {
            sortKey = [NSString stringWithFormat:@"phone_%@",oneRecord.phoneNum];
        }
        else
        {
            sortKey = [NSString stringWithFormat:@"contactID_%d",pID];
        }
        
        //判断是否已经记录该键值的通话记录了
        if (![recordSortKeyList containsObject:sortKey])
        {
            //没有记录，添加进入
            [recordSortKeyList addObject:sortKey];
            
            //创建一个通话记录的合并信息
            RecordMegerNode *newMergeRecord = [[RecordMegerNode alloc] init];
            newMergeRecord.lastDateString = oneRecord.recordDateString;
            newMergeRecord.lastTime = oneRecord.recordTotalTime;
            newMergeRecord.maxTime = oneRecord.recordTotalTime;
            newMergeRecord.minTime = oneRecord.recordTotalTime;
            newMergeRecord.phoneNumber = oneRecord.phoneNum;
            newMergeRecord.contactID = pID;
            newMergeRecord.contactName = (pID == kInValidContactID) ? oneRecord.phoneNum : [oneContact getContactFullName];
            
            //新建一个通话记录详情
//            RecordMegerDetailNode *recordDetail = [[RecordMegerDetailNode alloc] init];
//            recordDetail.phoneNumber = oneRecord.phoneNum;
//            [recordDetail.recordList addObject:oneRecord];
//            
//            //将通话记录详情放入合并信息中
//            [newMergeRecord.recordInfoDict setObject:[NSArray arrayWithObject:recordDetail]
//                                              forKey:[NSString stringWithFormat:@"%d",oneRecord.recordType]];
//            
//            [recordDetail release];
            
            //添加进入最近的通话记录
//            if ([newMergeRecord.lastRecordList count] < kLastContactRecordStoreCount)
            {
                [newMergeRecord.lastRecordList addObject:oneRecord];
            }
            
            //将合并信息存放到结果中
            [recordDict setObject:newMergeRecord forKey:sortKey];
            [newMergeRecord release];
        }
        else
        {
            //已经记录了，修改信息
            //获取合并信息
            RecordMegerNode *mergeRecord = (RecordMegerNode *)[recordDict objectForKey:sortKey];
            
            mergeRecord.maxTime = MAX(mergeRecord.maxTime, oneRecord.recordTotalTime);
            mergeRecord.minTime = MIN(mergeRecord.minTime, oneRecord.recordTotalTime);
            
            //获取合并信息中记录详情
//            NSString *rKey = [NSString stringWithFormat:@"%d",oneRecord.recordType];
//            NSMutableArray *rList = [[NSMutableArray alloc] initWithCapacity:2];
//            NSArray *nList = [mergeRecord.recordInfoDict objectForKey:rKey];
//            [rList addObjectsFromArray:nList];
//            
//            //判断当前记录详情记录中是否存在该号码的记录
//            BOOL hasDetailType = NO;
//            for (RecordMegerDetailNode *oneDetail in rList)
//            {
//                if ([oneDetail.phoneNumber isEqualToString:oneRecord.phoneNum])
//                {
//                    //当前记录详情记录中存在该号码的记录，将该条记录添加到记录详情中
//                    [oneDetail.recordList addObject:oneRecord];
//                    hasDetailType = YES;
//                    
//                    break;
//                }
//            }
//            
//            //当前记录详情记录中不存在该号码的记录,新建一个该号码的记录详情
//            if (!hasDetailType)
//            {
//                //新建一个通话记录详情
//                RecordMegerDetailNode *recordDetail = [[RecordMegerDetailNode alloc] init];
//                recordDetail.phoneNumber = oneRecord.phoneNum;
//                [recordDetail.recordList addObject:oneRecord];
//                [rList addObject:recordDetail];
//                [recordDetail release];
//            }
//            
//            [mergeRecord.recordInfoDict setObject:rList forKey:rKey];
//            [rList release];
            
            //添加进入最近的通话记录
//            if ([mergeRecord.lastRecordList count] < kLastContactRecordStoreCount)
            {
                [mergeRecord.lastRecordList addObject:oneRecord];
            }
            
            [recordDict setObject:mergeRecord forKey:sortKey];
        }
    }
    
    [pool release];
    
    //提取数据
    NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:2];
    for (NSString *oneKey in recordSortKeyList)
    {
        RecordMegerNode *aNode = (RecordMegerNode *)[recordDict objectForKey:oneKey];
        if (nil != aNode)
        {
            [resultList addObject:aNode];
        }
    }
    
    [recordSortKeyList release];
    [recordDict release];
    
    return resultList;
}

/*
 函数描述：去掉电话号码中的特殊字符
 输入参数：phoneNumber 电话号码
 countryCode 00开头的国家吗(如:0086)
 输出参数：N/A
 返 回 值：NSString   处理后的电话号码
 作    者：刘斌
 */
- (NSString *)deleteCountryCodeFromPhoneNumber:(NSString *)phoneNumber countryCode:(NSString *)countryCode
{
    if ([countryCode length] == 0 || [phoneNumber length] == 0)
    {
        return phoneNumber;
    }
    
    NSString *codeStr = [NSString stringWithFormat:@"%@",countryCode];
    if ([codeStr hasPrefix:@"+"])
    {
        codeStr = [codeStr stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"00"];
    }
    
    BOOL isChinese = [codeStr isEqualToString:@"0086"];
    
    NSString *aStr = [NSString stringWithFormat:@"%@",phoneNumber];
    
    // 去掉空格
    aStr = [aStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // 去掉'-'
    aStr = [aStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    // 去掉'('和')'
    aStr = [aStr stringByReplacingOccurrencesOfString:@"(" withString:@""];
    aStr = [aStr stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    //去掉"."和" "
    aStr  = [aStr stringByReplacingOccurrencesOfString:@"." withString:@""];
    aStr  = [aStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([aStr length] !=1)
    {
        
    
    if ([aStr hasPrefix:@"+"])
    {
        //将前面的+替换成00
        for (int i = 0; i < [aStr length]; ++i)
        {
            NSString *oneStr = [aStr substringWithRange:NSMakeRange(i, 1)];
            if (![oneStr isEqualToString:@"+"])
            {
                aStr = [aStr stringByReplacingCharactersInRange:NSMakeRange(0, i) withString:@"00"];
                break;
            }
        }
    }
    else if([aStr hasPrefix:@"000"] )
    {
        //将前面多余的0去掉
        for (int i = 2; i < [aStr length];)
        {
            NSString *oneStr = [aStr substringWithRange:NSMakeRange(i, 1)];
            if (![oneStr isEqualToString:@"0"])
            {
                aStr = [aStr stringByReplacingCharactersInRange:NSMakeRange(0, i-2) withString:@""];
            }
        }
    }else if([[aStr substringToIndex:2] isEqualToString:@"86"]){    //判断前两位为86则去掉转化为正常手机号
        aStr = [aStr substringFromIndex:2];
    }
    }
    if (isChinese) //中国区号码
    {
        //去掉国家吗
        if ([aStr hasPrefix:codeStr])
        {
            aStr = [aStr stringByReplacingCharactersInRange:NSMakeRange(0, [codeStr length]) withString:@""];
        }
        
        // 去掉号码前面加的“12593”
        if ([aStr hasPrefix:@"12593"])
        {
            aStr = [aStr stringByReplacingCharactersInRange:NSMakeRange(0, 5) withString:@""];
        }
        
        // 去掉号码前面加的“17951”
        if ([aStr hasPrefix:@"17951"])
        {
            aStr = [aStr stringByReplacingCharactersInRange:NSMakeRange(0, 5) withString:@""];
        }
        
        // 去掉号码前面加的“17911”
        if ([aStr hasPrefix:@"17911"])
        {
            aStr = [aStr stringByReplacingCharactersInRange:NSMakeRange(0, 5) withString:@""];
        }
    }
    
    return aStr;
}

/*
 函数描述：为电话号码加上国家吗
 输入参数：phoneNumber 电话号码
 countryCode 00开头的国家吗(如:0086)
 isChinese 是否为中国区登录
 输出参数：N/A
 返 回 值：NSString   处理后的电话号码
 作    者：刘斌
 */
- (NSString *)addCountryCodeForPhoneNumber:(NSString *)phoneNumber countryCode:(NSString *)countryCode
{
    if ([phoneNumber length] == 0 || [countryCode length] == 0)
    {
        return phoneNumber;
    }
    
    NSString *codeStr = [NSString stringWithFormat:@"%@",countryCode];
    if ([codeStr hasPrefix:@"+"])
    {
        codeStr = [codeStr stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"00"];
    }
    
    //先去掉该电话号码的特殊字符
    NSString *noCountryCodeNum = [self deleteCountryCodeFromPhoneNumber:phoneNumber countryCode:codeStr];
    
    if (0 != [noCountryCodeNum length])
    {
        if (![noCountryCodeNum hasPrefix:@"00"]) //未加上国家吗
        {
            return [NSString stringWithFormat:@"%@%@",codeStr,noCountryCodeNum];
        }
        else //已加上了国家码
        {
            return noCountryCodeNum;
        }
    }
    return phoneNumber;
}

/*
 函数描述：获取电话号码的归属地
 输入参数：phoneNumber 电话号码
 countryCode 00开头的国家吗(如:0086)
 输出参数：N/A
 返 回 值：NSString   号码归属地
 作    者：刘斌
 */
- (NSString *)phoneAttributionWithPhoneNumber:(NSString *)phoneNumber countryCode:(NSString *)countryCode
{
    BOOL isChinese = [countryCode isEqualToString:@"0086"] || [countryCode isEqualToString:@"+86"];
    //为电话号码加上国家吗
    NSString *aStr = [self addCountryCodeForPhoneNumber:phoneNumber countryCode:countryCode];
    
    return [self.myPhoneOwnerShipEngine getPhoneOnwerShipWithNumber:aStr isChineseNumber:isChinese];
}

/*
 函数描述：获取号码运营商
 输入参数：phoneNumber      电话号码
 isChina          是否为中国号码
 输出参数：N/A
 返 回 值:NSString     运营商名称
 作    者：丁大敏
 */

- (NSString *)PhoneOperatorsWithPhoneNumber:(NSString *)phoneNumber{
    return [self.myPhoneOwnerShipEngine getPhoneOperatorsWithNumber:phoneNumber];
}

/*
 函数描述：获取中国电话号码的区号
 输入参数：phoneNumber 电话号码
 输出参数：N/A
 返 回 值：NSString   区号
 作    者：刘斌
 */
- (NSString *)phoneZoneWithPhoneNumber:(NSString *)phoneNumber
{
    //为电话号码加上国家吗
    NSString *aStr = [self addCountryCodeForPhoneNumber:phoneNumber countryCode:@"0086"];
    
    return [self.myPhoneOwnerShipEngine getCityCode:aStr isChineseNumber:YES];
}

@end

#pragma mark - 地址本回调
void AddressBookDataChangeCallback(ABAddressBookRef addressBook, CFDictionaryRef info, void *context)
{
    [[ContactManager shareInstance] loadAllContact];
}
