//
//  ContactNode.m
//  ContactManager
//
//  Created by mini1 on 13-6-5.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import "ContactNode.h"
#import "ChineseToPinyin.h"

@interface ContactNode()

//屏蔽掉特殊字符
- (NSString *)screenSpecialCharacterFromString:(NSString *)aStr;

//字符串中是否包含中文字符
- (BOOL)containsChineseCharacter:(NSString*)aStr;

@end

@implementation ContactNode

@synthesize contactID;         //联系人ID，同通讯录中的personID
@synthesize groupDict;         //分组的信息，以分组ID为Key
@synthesize firstName;
@synthesize middleName;
@synthesize lastName;
@synthesize nickName;
@synthesize firstPinyin;    //firstName拼音
@synthesize middlepinyin;   //middleName拼音
@synthesize lastPinyin;     //lastName拼音

@synthesize phoneDict;      //电话号码，以电话类型为key
@synthesize emailDict;      //邮箱地址，以邮箱为key
@synthesize socialDict;     //社交账号，以账号类型为key

@synthesize addressDict;    //地址，ContactAddress集合

@synthesize companyName;    //公司名称
@synthesize departmentName; //部门名称
@synthesize positionName;   //职位

@synthesize sex;             //性别
@synthesize birthday;       //生日
@synthesize photoData;
@synthesize phoneList;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.contactID = kInValidContactID;
        self.groupDict = [NSMutableDictionary dictionaryWithCapacity:2];
        self.firstName = @"";
        self.middleName = @"";
        self.lastName = @"";
        self.nickName = @"";
        self.firstPinyin = @"";
        self.middlepinyin = @"";
        self.lastPinyin = @"";
        self.phoneList = [NSMutableArray arrayWithCapacity:2];
        self.phoneDict = [NSMutableDictionary dictionaryWithCapacity:2];
        self.emailDict = [NSMutableDictionary dictionaryWithCapacity:2];
        self.socialDict = [NSMutableDictionary dictionaryWithCapacity:2];
        
        self.addressDict = [NSMutableDictionary dictionaryWithCapacity:2];
        self.companyName = @"";
        self.departmentName = @"";
        self.positionName = @"";
        
        self.sex = ContactSexTypeMale;
    }
    return self;
}

/*
 函数描述：字符串中是否包含中文字符
 输入参数：aStr   待判断的字符串
 输出参数：N/A
 返 回 值：BOOL   是否包含
 作    者：刘斌
 */
- (BOOL)containsChineseCharacter:(NSString*)aStr
{
    for(int i = 0; i < [aStr length]; ++i)
    {
        unichar a = [aStr characterAtIndex:i];
        if(a >= 0x4e00 && a <= 0x9fff)
        {
            return YES;
        }
    }
    
    return NO;
}

/*
 函数描述：获取联系人的全名称
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSString   联系人全名称
 作    者：刘斌
 */
- (NSString *)getContactFullName
{
    //生成规则:无中文：(firstName MiddleName LastName) 中文：（LastName MiddleName FirstName)
    NSMutableString *nameStr = [NSMutableString stringWithFormat:@""];
    
    NSString *fName = @"";
    NSString *lName = @"";
    NSString *mName = @"";
    
    if (0 != [self.firstName length])
    {
        fName = self.firstName;
    }
    
    if (0 != [self.middleName length])
    {
        mName = self.middleName;
    }
    
    if (0 != [self.lastName length])
    {
        lName = self.lastName;
    }
    
    BOOL hasChinese = ([self containsChineseCharacter:self.firstName]
                       || [self containsChineseCharacter:self.firstPinyin]
//                       || [self containsChineseCharacter:self.middleName]
//                       || [self containsChineseCharacter:self.middlepinyin]
                       || [self containsChineseCharacter:self.lastName]
                       || [self containsChineseCharacter:self.lastPinyin]);
    
    //有中文字符 按lastName MiddleName firstName获取
    if (hasChinese)
    {
        [nameStr appendString:lName];
//        if(0 != [nameStr length] && 0 != [mName length])
//        {
//            [nameStr appendString:@" "];
//        }
//        [nameStr appendString:mName];
        if(0 != [nameStr length] && 0 != [fName length])
        {
            [nameStr appendString:@" "];
        }
        [nameStr appendString:fName];
    }
    else
    {
        [nameStr appendString:fName];
//        if(0 != [nameStr length] && 0 != [mName length])
//        {
//            [nameStr appendString:@" "];
//        }
//        [nameStr appendString:mName];
        if(0 != [nameStr length] && 0 != [lName length])
        {
            [nameStr appendString:@" "];
        }
        [nameStr appendString:lName];
    }
    
    //若名字为空，获取电话号码
    if (0 == [nameStr length])
    {
        NSArray *pList = [self contactAllPhone];
        if (0 < [pList count])
        {
            return [pList objectAtIndex:0];
        }
        
        return @"";
    }
    
    return nameStr;
}

/*
 函数描述：获取联系人分区的键值
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSString   A-Z #中的一个键值
 作    者：刘斌
 */
- (NSString *)getContactSortKey
{
    //获取联系人的全名称
    NSString *nameStr = [self getContactFullName];
    
    if (0 == [nameStr length])
    {
        return @"#";
    }
    else
    {
        //名字转化为首字母拼音
        NSString *pinYinName = [[ChineseToPinyin pinyinFromChiniseString:nameStr] uppercaseString];
        
        if (0 == [pinYinName length])
        {
            return @"#";
        }
        else
        {
            char cc = [pinYinName characterAtIndex:0];
            if (cc < 'A' || cc > 'Z')
            {
                return @"#";
            }
            else
            {
                return [pinYinName substringWithRange:NSMakeRange(0, 1)];
            }
        }
    }
    
    return @"#";
}

/*
 函数描述：根据名字与其他联系人比较
 输入参数：otherContact : 其他联系人
 输出参数：N/A
 返 回 值：int   比较结果 1：排在前面 0 相等 -1 小于
 作    者：刘斌
 */
- (int)compareBynameWithOther:(ContactNode *)otherContact
{
    NSString *nameStr1 = [self getContactFullName];
    NSString *nameStr2 = [otherContact getContactFullName];
    
    if (0 == [nameStr2 length])
    {
        return 1;
    }
    else if([nameStr1 length] == 0)
    {
        return -1;
    }
    
    NSString *pinYinName1 = [[ChineseToPinyin pinyinFromChiniseString:nameStr1] uppercaseString];
    NSString *pinYinName2 = [[ChineseToPinyin pinyinFromChiniseString:nameStr2] uppercaseString];
    
    if (0 == [pinYinName1 length])
    {
        return 1;
    }
    else if(0 == [pinYinName2 length])
    {
        return -1;
    }
    
    char cc1 = [pinYinName1 characterAtIndex:0];
    char cc2 = [pinYinName2 characterAtIndex:0];
    if (cc2 < 'A' || cc2 > 'Z')
    {
        return 1;
    }
    else if (cc1 < 'A' || cc1 > 'Z')
    {
        return -1;
    }
    
    return [pinYinName1 compare:pinYinName2];
}

/*
 函数描述：屏蔽字符串中的特殊字符
 输入参数：aStr  要屏蔽的字符串
 输出参数：N/A
 返 回 值：NSString   屏蔽后的字符串
 作    者：刘斌
 */
- (NSString *)screenSpecialCharacterFromString:(NSString *)aStr
{
    if (0 == [aStr length])
    {
        return @"";
    }
    
    NSString *str = [NSString stringWithFormat:@"%@",aStr];
    
    str  = [str stringByReplacingOccurrencesOfString:@"!" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"*" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"'" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"(" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@")" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@";" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@":" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"&" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"=" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"+" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"$" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"," withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"/" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"?" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"%" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"#" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@"." withString:@""];
    str  = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    return str;
}

- (NSString *)jsonStringFromList:(NSArray *)aList inNode:(NSString *)nodeStr
{
    if (0 == [aList count] || 0 == [nodeStr length])
    {
        return @"";
    }
    
    NSMutableString *aStr = [NSMutableString stringWithString:@""];
    [aStr appendFormat:@"\"%@\":[",nodeStr];
    
    for (NSString *oneStr in aList)
    {
        NSString *bStr = [self screenSpecialCharacterFromString:oneStr];
        if (0 != [bStr length])
        {
            [aStr appendFormat:@"\"%@\",",bStr];
        }
    }
    
    if ([aStr length] > [nodeStr length] + 4)
    {
        [aStr deleteCharactersInRange:NSMakeRange([aStr length] - 1, 1)];
        [aStr appendString:@"],"];
        return aStr;
    }
    else
    {
        return @"";
    }
}

- (NSString *)jsonStringFromString:(NSString *)aStr inNode:(NSString *)nodeStr
{
    if (0 == [aStr length] || 0 == [nodeStr length])
    {
        return @"";
    }
    
    NSString *bStr = [self screenSpecialCharacterFromString:aStr];
    if ([bStr length] != 0)
    {
        return [NSString stringWithFormat:@"\"%@\":\"%@\",",nodeStr,bStr];
    }
    else
    {
        return @"";
    }
}

/*
 函数描述：根据联系人创建json字符串
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSString   json字符串
 作    者：刘斌
 */
- (NSString *)createJsonString
{
    if (self.contactID != kInValidContactID)
    {
        NSMutableString *jsonStr = [NSMutableString stringWithString:@"{"];
        
        [jsonStr appendFormat:@"\"contactid\":%d,",self.contactID];
        
        //分组信息
        NSArray *allGroupIDs = [self.groupDict allKeys];
        if (0 != [allGroupIDs count])
        {
            [jsonStr appendString:@"\"gid\":["];
            for (int i = 0; i < [allGroupIDs count]; ++i)
            {
                NSString *groupID = (NSString *)[allGroupIDs objectAtIndex:i];
                [jsonStr appendString:groupID];
                if (i != [allGroupIDs count] - 1)
                {
                    [jsonStr appendString:@","];
                }
            }
            [jsonStr appendString:@"],"];
        }
        
        //firstName
        [jsonStr appendString:[self jsonStringFromString:self.firstName inNode:@"firstname"]];
        
        //lastName
        [jsonStr appendString:[self jsonStringFromString:self.lastName inNode:@"lastname"]];
        
        //nickName
        [jsonStr appendString:[self jsonStringFromString:self.nickName inNode:@"nickname"]];
        
        //birthday
        if (nil != self.birthday)
        {
            [jsonStr appendFormat:@"\"birthday\":%.f,",[self.birthday timeIntervalSince1970]];
        }
        
        //公司
        [jsonStr appendString:[self jsonStringFromString:self.companyName inNode:@"company"]];
        
        //部门
        [jsonStr appendString:[self jsonStringFromString:self.departmentName inNode:@"department"]];
        
        //职位
        [jsonStr appendString:[self jsonStringFromString:self.positionName inNode:@"postion"]];
        
        //email
        if (0 != [self.emailDict count])
        {
            //普通邮箱
            NSArray *generalEmailList = [self.emailDict objectForKey:[NSString stringWithFormat:@"%d",
                                                                      ContactEmailTypeOther]];
            [jsonStr appendString:[self jsonStringFromList:generalEmailList
                                                    inNode:@"emailGeneral"]];
            
            //工作邮箱
            NSArray *workEmailList = [self.emailDict objectForKey:[NSString stringWithFormat:@"%d",
                                                                   ContactEmailTypeWork]];
            [jsonStr appendString:[self jsonStringFromList:workEmailList
                                                    inNode:@"emailWork"]];
            
            //家庭邮箱
            NSArray *homeEmailList = [self.emailDict objectForKey:[NSString stringWithFormat:@"%d",
                                                                   ContactEmailTypeHome]];
            [jsonStr appendString:[self jsonStringFromList:homeEmailList
                                                    inNode:@"emailHome"]];
        }
        
//        //地址
//        if (0 != [self.addressDict count])
//        {
//            //家庭地址
//            ContactAddressNode *homeAddress = (ContactAddressNode *)[self.addressDict objectForKey:[NSString stringWithFormat:@"%d",
//                                                                                                    ContactAddressTypeHome]];
//            [jsonStr appendFormat:@"\"addressHome\":"];
//            
//            if (0 != [homeAddress.countryName length])
//            {
//                [jsonStr appendString:[homeAddress contactAddressString]];
//            }
//            
//            if (0 != [homeAddress.postCode length])
//            {
//                [jsonStr appendFormat:@"\"postcodeHome\":\"%@\",",homeAddress.postCode];
//            }
//        
//            //工作地址
//            ContactAddressNode *workAddress = (ContactAddressNode *)[self.addressDict objectForKey:[NSString stringWithFormat:@"%d",
//                                                                                                    ContactAddressTypeWork]];
//            [jsonStr appendFormat:@"\"addressWork\":"];
//            
//            if (0 != [workAddress.countryName length])
//            {
//                [jsonStr appendString:[workAddress contactAddressString]];
//            }
//            
//            if (0 != [workAddress.postCode length])
//            {
//                [jsonStr appendFormat:@"\"postcodeWork\":\"%@\",",workAddress.postCode];
//            }
//        }
        
        //phone
        if (0 != [self.phoneDict count])
        {
            //工作电话(phoneWork)
            NSArray *workPhoneList = [self.phoneDict objectForKey:[NSString stringWithFormat:@"%d",
                                                                   ContactPhoneTypeWork]];
            [jsonStr appendString:[self jsonStringFromList:workPhoneList
                                                    inNode:@"phoneWork"]];
            
            //电话(phoneHome)
            NSArray *homePhoneList = [self.phoneDict objectForKey:[NSString stringWithFormat:@"%d",
                                                                   ContactPhoneTypeHome]];
            [jsonStr appendString:[self jsonStringFromList:homePhoneList
                                                    inNode:@"phoneHome"]];
            
            //电话(phoneGeneral)
            NSArray *generalPhoneList = [self.phoneDict objectForKey:[NSString stringWithFormat:@"%d",
                                                                      ContactPhoneTypeOtherNum]];
            [jsonStr appendString:[self jsonStringFromList:generalPhoneList
                                                    inNode:@"phoneGeneral"]];
            
            //电话(faxWork)
            NSArray *workFaxList = [self.phoneDict objectForKey:[NSString stringWithFormat:@"%d",
                                                                 ContactPhoneTypeWorkFax]];
            [jsonStr appendString:[self jsonStringFromList:workFaxList
                                                    inNode:@"faxWork"]];
            
            //电话(faxHome)
            NSArray *homeFaxList = [self.phoneDict objectForKey:[NSString stringWithFormat:@"%d",
                                                                 ContactPhoneTypeHomeFax]];
            [jsonStr appendString:[self jsonStringFromList:homeFaxList
                                                    inNode:@"faxHome"]];
            
            //电话(faxGeneral)
            NSArray *generalFaxList = [self.phoneDict objectForKey:[NSString stringWithFormat:@"%d",
                                                                    ContactPhoneTypeOtherFax]];
            [jsonStr appendString:[self jsonStringFromList:generalFaxList
                                                    inNode:@"faxGeneral"]];
            
            //电话(mobileWork)
            NSArray *workmobileList = [self.phoneDict objectForKey:[NSString stringWithFormat:@"%d",
                                                                    ContactPhoneTypeMobile]];
            [jsonStr appendString:[self jsonStringFromList:workmobileList
                                                    inNode:@"mobileWork"]];
            
            //电话(mobileHome)
            NSArray *homeMobileList = [self.phoneDict objectForKey:[NSString stringWithFormat:@"%d",
                                                                    ContactPhoneTypeIphone]];
            [jsonStr appendString:[self jsonStringFromList:homeMobileList
                                                    inNode:@"mobileHome"]];
            
            //电话(mobileGeneral)
            NSArray *generalMobileList = [self.phoneDict objectForKey:[NSString stringWithFormat:@"%d",
                                                                       ContactPhoneTypeMain]];
            [jsonStr appendString:[self jsonStringFromList:generalMobileList
                                                    inNode:@"mobileGeneral"]];
        }
        
        if ([jsonStr hasSuffix:@","])
        {
            [jsonStr replaceCharactersInRange:NSMakeRange(jsonStr.length - 1, 1)
                                   withString:@"}"];
        }
        else
        {
            [jsonStr appendString:@"}"];
        }
        
        return jsonStr;
    }
    
    return @"";
}

/*
 函数描述：是否包含另一联系人的所有电话号码
 输入参数：otherContact : 其他联系人
 输出参数：N/A
 返 回 值：BOOL   是否包含
 作    者：刘斌
 */
- (BOOL)isContainsAllPhoneInOthers:(ContactNode *)otherContact
{
    //先判断数量
    if ([otherContact.phoneDict count] == 0 || [otherContact.phoneDict count] > [self.phoneDict count])
    {
        return NO;
    }
    
    //用来存放本身所有的电话号码
    NSMutableArray *aList = [[NSMutableArray alloc] initWithCapacity:2];
    
    for (NSArray *onePhoneList in [self.phoneDict allValues])
    {
        [aList addObjectsFromArray:onePhoneList];
    }
    
    NSArray *aKeyList = [otherContact.phoneDict allKeys];
    for (NSString *oneKey in aKeyList)
    {
        NSArray *otherPhoneList = [otherContact.phoneDict objectForKey:oneKey];
        
        for (NSString *oneNum in otherPhoneList)
        {
            if (![aList containsObject:oneNum])
            {
                return NO;
            }
        }
    }    
    return YES;
}

/*
 函数描述：合并另一联系人的不同的电话号码
 输入参数：otherContact : 其他联系人
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)megerOtherContactPhones:(ContactNode *)otherContact
{
    if (nil == otherContact || 0 == [otherContact.phoneDict count])
    {
        return;
    }
    
    //用来存放本身所有的电话号码
    NSMutableArray *aList = [[NSMutableArray alloc] initWithCapacity:2];
    
    for (NSArray *onePhoneList in [self.phoneDict allValues])
    {
        [aList addObjectsFromArray:onePhoneList];
    }
    
    NSArray *aKeyList = [otherContact.phoneDict allKeys];
    for (NSString *oneKey in aKeyList)
    {
        //获取他人某一类型的电话号码
        NSArray *otherPhoneList = [otherContact.phoneDict objectForKey:oneKey];
        
        //将自己某一类型的电话号码存放到某一中间变量中
        NSMutableArray *bList = [[NSMutableArray alloc] initWithCapacity:2];
        NSArray *cList = (NSArray *)[self.phoneDict objectForKey:oneKey];
        [bList addObjectsFromArray:cList];
        
        //若他人该类型的电话号码没在我自己的电话号码中，添加到自己的该类型的电话号码中
        for (NSString *oneNum in otherPhoneList)
        {
            if (![aList containsObject:oneNum])
            {
                [aList addObject:oneNum];
                [bList addObject:oneNum];
            }
        }
        
        [self.phoneDict setObject:bList forKey:oneKey];
    }
    [self.phoneList removeAllObjects];
}

/*
 函数描述：根据地址本联系人信息创建数据
 输入参数：onePerson : 地址本联系人
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)createContactDataWithPerson:(ABRecordRef)onePerson
{
    if (NULL == onePerson)
    {
        return;
    }
    
    [self.phoneList removeAllObjects];
    
    //获取recordID
    self.contactID = ABRecordGetRecordID(onePerson);
    
    //获取firstName
    self.firstName = (__bridge NSString*)ABRecordCopyValue(onePerson, kABPersonFirstNameProperty);
    
    //middleName
    self.middleName = (__bridge NSString *)ABRecordCopyValue(onePerson, kABPersonMiddleNameProperty);
    
    //lastName
    self.lastName = (__bridge NSString *)ABRecordCopyValue(onePerson, kABPersonLastNameProperty);
    
    //nickName
    self.nickName = (__bridge NSString*)ABRecordCopyValue(onePerson, kABPersonNicknameProperty);
    
    // 读取firstname拼音音标
    self.firstPinyin = (__bridge NSString*)ABRecordCopyValue(onePerson, kABPersonFirstNamePhoneticProperty);
    
    //读取middleName拼音音标
    self.middlepinyin = (__bridge NSString *)ABRecordCopyValue(onePerson, kABPersonMiddleNamePhoneticProperty);
    
    // 读取lastname拼音音标
    self.lastPinyin = (__bridge NSString*)ABRecordCopyValue(onePerson, kABPersonLastNamePhoneticProperty);
    
    //birthDay
    self.birthday = (__bridge NSDate*)ABRecordCopyValue(onePerson, kABPersonBirthdayProperty);
    
    //读取公司
    self.companyName = (__bridge NSString*)ABRecordCopyValue(onePerson, kABPersonOrganizationProperty);
    
    // 读取部门
    self.departmentName = (__bridge NSString*)ABRecordCopyValue(onePerson, kABPersonDepartmentProperty);
    
    // 读取职位
    self.positionName = (__bridge NSString*)ABRecordCopyValue(onePerson, kABPersonJobTitleProperty);
    
    // 获取email多值
    ABMultiValueRef emailList = ABRecordCopyValue(onePerson, kABPersonEmailProperty);
    int emailcount = ABMultiValueGetCount(emailList);
    if (emailcount !=0)
    {
        for (int x = 0; x < emailcount; x++)
        {
            //获取email Label
//            CFStringRef cfEmailLabel = ABMultiValueCopyLabelAtIndex(emailList, x);
//            NSString *emailLabelLoalized = (NSString*)ABAddressBookCopyLocalizedLabel(cfEmailLabel);
            
            
            
            //获取email值
            NSString* emailContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emailList, x);
            if (0 != [emailContent length])
            {
                
                NSMutableArray *generalEmailList = [NSMutableArray arrayWithCapacity:2];
                ContactEmailType emailType = ContactEmailTypeWork;
                
                
                NSString *eKey = [NSString stringWithFormat:@"%d",emailType];
                NSArray *eList = (NSArray *)[self.emailDict objectForKey:eKey];
                [generalEmailList addObjectsFromArray:eList];
                [generalEmailList addObject:emailContent];
                [self.emailDict setObject:generalEmailList
                                   forKey:eKey];
            }
        }
    }
    
    
    // 读取地址多值
    ABMultiValueRef address = ABRecordCopyValue(onePerson, kABPersonAddressProperty);
    int addressCount = ABMultiValueGetCount(address);
    for (int j = 0; j < addressCount; ++j)
    {
        ContactAddressNode *workAddress = [[ContactAddressNode alloc] init];
        NSDictionary* personaddress =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(address, j);
        
        NSString* country = [personaddress valueForKey:(NSString *)kABPersonAddressCountryKey];
        workAddress.countryName = [self screenSpecialCharacterFromString:country];
        
        NSString* state = [personaddress valueForKey:(NSString *)kABPersonAddressStateKey];
        workAddress.stateName = [self screenSpecialCharacterFromString:state];
        
        NSString* city = [personaddress valueForKey:(NSString *)kABPersonAddressCityKey];
        workAddress.cityName = [self screenSpecialCharacterFromString:city];
        
        NSString* street = [personaddress valueForKey:(NSString *)kABPersonAddressStreetKey];
        workAddress.streetName = [self screenSpecialCharacterFromString:street];
        
        NSString* zip = [personaddress valueForKey:(NSString *)kABPersonAddressZIPKey];
        workAddress.postCode = [self screenSpecialCharacterFromString:zip];
        
        //获取地址Label
        NSString * label = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(address, j);
        NSString * personPhoneLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel((__bridge CFStringRef)label);
        if ([personPhoneLabel isEqualToString:@"工作"])
        {
            [self.addressDict setObject:workAddress
                                 forKey:[NSString stringWithFormat:@"%d",ContactAddressTypeWork]];
        }
        else
        {
            [self.addressDict setObject:workAddress
                                 forKey:[NSString stringWithFormat:@"%d",ContactAddressTypeHome]];
        }
    }
    
    // 读取电话多值
    ABMultiValueRef phone = ABRecordCopyValue(onePerson, kABPersonPhoneProperty);
    int phoneCount = ABMultiValueGetCount(phone);
    for (int i = 0; i < phoneCount; ++i)
    {
        ContactPhoneType phoneType = ContactPhoneTypeOtherNum;
        
        //获取該Label下的电话值
        NSString * tempPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, i);
        NSString * personPhone = [NSString stringWithString:tempPhone];
        NSString *phoneNum = [self screenSpecialCharacterFromString:personPhone];
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (0 != [phoneNum length])
        {
            //获取电话Label
            NSString * label = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phone, i);
            NSString * personPhoneLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel((__bridge CFStringRef)label);
            if ([personPhoneLabel isEqualToString:@"工作"])
            {
                phoneType = ContactPhoneTypeWork;
            }
            else if ([personPhoneLabel isEqualToString:@"住宅"])
            {
                phoneType = ContactPhoneTypeHome;
            }
            else if ([personPhoneLabel isEqualToString:@"住宅传真"])
            {
                phoneType = ContactPhoneTypeHomeFax;
            }
            else if ([personPhoneLabel isEqualToString:@"工作传真"])
            {
                phoneType = ContactPhoneTypeWorkFax;
            }
            else
            {
                phoneType = ContactPhoneTypeOtherNum;
            }
            
            NSString *pKey = [NSString stringWithFormat:@"%d",phoneType];
            NSMutableArray *pList = [[NSMutableArray alloc] initWithCapacity:1];
            NSArray *ppList = (NSArray *)[self.phoneDict objectForKey:pKey];
            [pList addObjectsFromArray:ppList];
            [pList addObject:phoneNum];
            
            [self.phoneDict setObject:pList forKey:pKey];
        }
    }
    
//    //获取头像
//    if (ABPersonHasImageData(onePerson))
//    {
//        self.photoData = (NSData *)ABPersonCopyImageData(onePerson);
//    }
}

/*
 函数描述：将数据插入到地址本的联系人中
 输入参数：N/A
 输出参数：onePerson : 地址本联系人
 返 回 值：N/A
 作    者：刘斌
 */
- (void)insertDataIntoPerson:(ABRecordRef)onePerson
{
    if (NULL == onePerson)
    {
        return;
    }
    
    if (0 != [self.firstName length])
    {
        ABRecordSetValue(onePerson,
                         kABPersonFirstNameProperty,
                         (__bridge CFTypeRef)(self.firstName),
                         NULL);
    }
    if (0 != [self.lastName length])
    {
        ABRecordSetValue(onePerson,
                         kABPersonLastNameProperty,
                         (__bridge CFTypeRef)(self.lastName),
                         NULL);
    }
    
    if (0 != [self.middleName length])
    {
        ABRecordSetValue(onePerson,
                         kABPersonMiddleNameProperty,
                         (__bridge CFTypeRef)(self.middleName),
                         NULL);
    }
    
    if (0 != [self.nickName length])
    {
        ABRecordSetValue(onePerson,
                         kABPersonNicknameProperty,
                         (__bridge CFTypeRef)(self.nickName),
                         NULL);
    }
    
    if (0 != [self.companyName length])
    {
        ABRecordSetValue(onePerson,
                         kABPersonOrganizationProperty,
                         (__bridge CFTypeRef)(self.companyName),
                         NULL);
    }
    
    if (0 != [self.departmentName length])
    {
        ABRecordSetValue(onePerson,
                         kABPersonDepartmentProperty,
                         (__bridge CFTypeRef)(self.departmentName),
                         NULL);
    }
    
    if (0 != [self.positionName length])
    {
        ABRecordSetValue(onePerson,
                         kABPersonJobTitleProperty,
                         (__bridge CFTypeRef)(self.firstName),
                         NULL);
    }
    
    if (nil != self.birthday)
    {
        ABRecordSetValue(onePerson,
                         kABPersonBirthdayProperty,
                         (__bridge CFTypeRef)(self.birthday),
                         NULL);
    }
    
    if (nil != self.photoData)
    {
        ABPersonSetImageData(onePerson,
                             (__bridge CFDataRef)self.photoData,
                             NULL);
    }
    
    if (0 != [self.phoneDict count])
    {
        ABMutableMultiValueRef phoneMulti = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        NSArray *pKeyList = [self.phoneDict allKeys];
        for (NSString *oneKey in pKeyList)
        {
            ContactPhoneType pType = (ContactPhoneType)[oneKey intValue];
            CFStringRef labelName = kABOtherLabel;
            switch (pType)
            {
                case ContactPhoneTypeHome:
                    labelName = kABHomeLabel;
                    break;
                case ContactPhoneTypeHomeFax:
                    labelName = kABPersonPhoneHomeFAXLabel;
                    break;
                case ContactPhoneTypeIphone:
                    labelName = kABPersonPhoneIPhoneLabel;
                    break;
                case ContactPhoneTypeMain:
                    labelName = kABPersonPhoneMainLabel;
                    break;
                case ContactPhoneTypeMobile:
                    labelName = kABPersonPhoneMobileLabel;
                    break;
                case ContactPhoneTypeOtherFax:
                    labelName = kABPersonPhoneOtherFAXLabel;
                    break;
                case ContactPhoneTypeOtherNum:
                    labelName = kABOtherLabel;
                    break;
                case ContactPhoneTypeWork:
                    labelName = kABWorkLabel;
                    break;
                case ContactPhoneTypeWorkFax:
                    labelName = kABPersonPhoneWorkFAXLabel;
                    break;
                default:
                    break;
            }
            
            NSArray *pList = [self.phoneDict objectForKey:oneKey];
            
            for (NSString *onePhoneNum in pList)
            {
                ABMultiValueAddValueAndLabel(phoneMulti,
                                             (__bridge CFTypeRef)(onePhoneNum),
                                             labelName,
                                             NULL);
            }
        }
        
        ABRecordSetValue(onePerson,
                         kABPersonPhoneProperty,
                         phoneMulti,
                         NULL);
        CFRelease(phoneMulti);
    }
    
    if (0 != [self.addressDict count])
    {
        ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
        
        NSArray *dKeyList = [self.addressDict allKeys];
        for (NSString *oneKey in dKeyList)
        {
            ContactAddressType dType = (ContactAddressType)[oneKey intValue];
            CFStringRef labelName = kABOtherLabel;
            switch (dType)
            {
                case ContactAddressTypeHome:
                    labelName = kABHomeLabel;
                    break;
                case ContactAddressTypeOther:
                    labelName = kABOtherLabel;
                    break;
                case ContactAddressTypeWork:
                    labelName = kABWorkLabel;
                    break;
                    
                default:
                    break;
            }
            
            ContactAddressNode *address = (ContactAddressNode *)[self.addressDict objectForKey:oneKey];
            NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
            if (0 != [address.countryName length])
            {
                [addressDictionary setObject:address.countryName
                                      forKey:(NSString *)kABPersonAddressCountryKey];
            }
            if (0 != [address.stateName length])
            {
                [addressDictionary setObject:address.stateName
                                      forKey:(NSString *)kABPersonAddressStateKey];
            }
            if (0 != [address.cityName length])
            {
                [addressDictionary setObject:address.cityName
                                      forKey:(NSString *)kABPersonAddressCityKey];
            }
            if (0 != [address.streetName length])
            {
                [addressDictionary setObject:address.streetName
                                      forKey:(NSString *)kABPersonAddressStreetKey];
            }
            if (0 != [address.postCode length])
            {
                [addressDictionary setObject:address.postCode
                                      forKey:(NSString *)kABPersonAddressZIPKey];
            }
            
            ABMultiValueAddValueAndLabel(multi,
                                         (__bridge CFTypeRef)(addressDictionary),
                                         labelName,
                                         NULL);
        }
        
        ABRecordSetValue(onePerson,
                         kABPersonAddressProperty,
                         multi,
                         NULL);
        CFRelease(multi);
    }
    
    if (0 != [self.emailDict count])
    {
        ABMutableMultiValueRef emailMulti = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        NSArray *eKeyList = [self.emailDict allKeys];
        for (NSString *oneKey in eKeyList)
        {
            ContactEmailType eType = (ContactEmailType)[oneKey intValue];
            CFStringRef labelName = kABOtherLabel;
            switch (eType)
            {
                case ContactEmailTypeHome:
                    labelName = kABHomeLabel;
                    break;
                case ContactEmailTypeOther:
                    labelName = kABOtherLabel;
                    break;
                case ContactEmailTypeWork:
                    labelName = kABWorkLabel;
                    break;
                default:
                    break;
            }
            
            NSArray *eList = [self.emailDict objectForKey:oneKey];
            
            for (NSString *oneEmail in eList)
            {
                ABMultiValueAddValueAndLabel(emailMulti,
                                             (__bridge CFTypeRef)(oneEmail),
                                             labelName,
                                             NULL);
            }
        }
        
        ABRecordSetValue(onePerson,
                         kABPersonEmailProperty,
                         emailMulti,
                         NULL);
        CFRelease(emailMulti);
    }
}

/*
 函数描述：获取所有联系人的电话号码
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSArray   电话号码集合
 作    者：刘斌
 */
- (NSArray *)contactAllPhone
{
    if (0 == [self.phoneList count])
    {
        NSArray *keyList = [NSArray arrayWithObjects:
                            [NSString stringWithFormat:@"%d",ContactPhoneTypeMain],
                            [NSString stringWithFormat:@"%d",ContactPhoneTypeIphone],
                            [NSString stringWithFormat:@"%d",ContactPhoneTypeWork],
                            [NSString stringWithFormat:@"%d",ContactPhoneTypeHome],
                            [NSString stringWithFormat:@"%d",ContactPhoneTypeOtherNum],
                            [NSString stringWithFormat:@"%d",ContactPhoneTypeWorkFax],
                            [NSString stringWithFormat:@"%d",ContactPhoneTypeHomeFax],
                            [NSString stringWithFormat:@"%d",ContactPhoneTypeOtherFax],
                            nil];
        for (NSString *onekey in keyList)
        {
            NSArray *pList = [self.phoneDict objectForKey:onekey];
            [self.phoneList addObjectsFromArray:pList];
        }
    }
    
    return self.phoneList;
}

/*
 函数描述：联系人是否包含某个号码
 输入参数：strPhone   待判断的号码
 输出参数：N/A
 返 回 值：BOOL   是否包含
 作    者：刘斌
 */
- (BOOL)containsPhoneNumber:(NSString *)strPhone
{
    if (0 == [strPhone length])
    {
        return NO;
    }
    
    NSString *strDest = [self screenSpecialCharacterFromString:strPhone];
    if (0 == [strDest length])
    {
        return NO;
    }
    
    for (NSArray *aList in [self.phoneDict allValues])
    {
        for (NSString *phoneNum in aList)
        {
            NSString *strSrc = [self screenSpecialCharacterFromString:phoneNum];
            if (0 != [strSrc length])
            {
                if ([strSrc isEqualToString:strDest])
                {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

/*
 函数描述：根据json数据构建联系人数据
 输入参数：jsonDict   联系人信息
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)createContactDataWithJsonDict:(NSDictionary *)jsonDict
{
    id jContactID = [jsonDict objectForKey:@"contactid"];
    if (jContactID)
    {
        self.contactID = [jContactID integerValue];
    }
    
    self.firstName = [jsonDict objectForKey:@"firstname"];
    self.lastName = [jsonDict objectForKey:@"lastname"];
    self.nickName = [jsonDict objectForKey:@"nickname"];
    
    long jBirthday = [[jsonDict objectForKey:@"birthday"] longValue];
    if (jBirthday > 0)
    {
        self.birthday = [NSDate dateWithTimeIntervalSince1970:jBirthday];
    }
    
    self.companyName = [jsonDict objectForKey:@"company"];
    self.departmentName = [jsonDict objectForKey:@"department"];
    self.positionName = [jsonDict objectForKey:@"position"];
    
    NSArray *generalEmailList = [jsonDict objectForKey:@"emailGeneral"];
    if ([generalEmailList count] > 0)
    {
        [self.emailDict setObject:generalEmailList
                           forKey:[NSString stringWithFormat:@"%d",
                                   ContactEmailTypeOther]];
    }
    
    NSArray *workEmailList = [jsonDict objectForKey:@"emailWork"];
    if ([workEmailList count] > 0)
    {
        [self.emailDict setObject:workEmailList
                           forKey:[NSString stringWithFormat:@"%d",
                                   ContactEmailTypeWork]];
    }
    
    NSArray *homeEmailList = [jsonDict objectForKey:@"emailHome"];
    if ([homeEmailList count] > 0)
    {
        [self.emailDict setObject:homeEmailList
                           forKey:[NSString stringWithFormat:@"%d",
                                   ContactEmailTypeHome]];
    }
    
    NSArray *workPhoneList = [jsonDict objectForKey:@"phoneWork"];
    if ([workPhoneList count] > 0)
    {
        [self.phoneDict setObject:workPhoneList
                           forKey:[NSString stringWithFormat:@"%d",
                                   ContactPhoneTypeWork]];
    }
    
    NSArray *homePhoneList = [jsonDict objectForKey:@"phoneHome"];
    if ([homePhoneList count] > 0)
    {
        [self.phoneDict setObject:homePhoneList
                           forKey:[NSString stringWithFormat:@"%d",
                                   ContactPhoneTypeHome]];
    }
    
    NSArray *generalPhoneList = [jsonDict objectForKey:@"phoneGeneral"];
    if ([generalPhoneList count] > 0)
    {
        [self.phoneDict setObject:generalPhoneList
                           forKey:[NSString stringWithFormat:@"%d",
                                   ContactPhoneTypeOtherNum]];
    }
    
    NSArray *workFaxList = [jsonDict objectForKey:@"faxWork"];
    if ([workFaxList count] > 0)
    {
        [self.phoneDict setObject:workFaxList
                           forKey:[NSString stringWithFormat:@"%d",
                                   ContactPhoneTypeWorkFax]];
    }
    
    NSArray *homeFaxList = [jsonDict objectForKey:@"faxHome"];
    if ([homeFaxList count] > 0)
    {
        [self.phoneDict setObject:homeFaxList
                           forKey:[NSString stringWithFormat:@"%d",
                                   ContactPhoneTypeHomeFax]];
    }
    
    NSArray *generalFaxList = [jsonDict objectForKey:@"faxGeneral"];
    if ([generalFaxList count] > 0)
    {
        [self.phoneDict setObject:generalFaxList
                           forKey:[NSString stringWithFormat:@"%d",
                                   ContactPhoneTypeOtherFax]];
    }
    
    NSArray *workmobileList = [jsonDict objectForKey:@"mobileWork"];
    if ([workmobileList count] > 0)
    {
        [self.phoneDict setObject:workmobileList
                           forKey:[NSString stringWithFormat:@"%d",
                                   ContactPhoneTypeMobile]];
    }
    
    NSArray *homeMobileList = [jsonDict objectForKey:@"mobileHome"];
    if ([homeMobileList count] > 0)
    {
        [self.phoneDict setObject:homeMobileList
                           forKey:[NSString stringWithFormat:@"%d",
                                   ContactPhoneTypeIphone]];
    }
    
    NSMutableArray *generalMobileList = [NSMutableArray arrayWithCapacity:0];
    generalMobileList = [jsonDict objectForKey:@"mobileGeneral"];
    
    //删除mobileGeneral自己内部的重复电话
    NSMutableArray *categoryArray = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < [generalMobileList count]; i++){
        if ([categoryArray containsObject:[generalMobileList objectAtIndex:i]] == NO){
            [categoryArray addObject:[generalMobileList objectAtIndex:i]];
        }
    }
    
    //删除mobileGeneral包含其他项目的电话
    for (int i = 0; i < [categoryArray count]; i++) {
        if (![categoryArray count]) {
            break;
        }
        if ([workPhoneList containsObject:[categoryArray objectAtIndex:i]]) {
            [categoryArray removeObject:[categoryArray objectAtIndex:i]];
            i--;
        } else  if ([homePhoneList containsObject:[categoryArray objectAtIndex:i]]) {
            [categoryArray removeObject:[categoryArray objectAtIndex:i]];
            i--;
        }
        else if ([generalPhoneList containsObject:[categoryArray objectAtIndex:i]]) {
            [categoryArray removeObject:[categoryArray objectAtIndex:i]];
            i--;
        }
        else if ([workFaxList containsObject:[categoryArray objectAtIndex:i]]) {
            [categoryArray removeObject:[categoryArray objectAtIndex:i]];
            i--;
        }
        else if ([homeFaxList containsObject:[categoryArray objectAtIndex:i]]) {
            [categoryArray removeObject:[categoryArray objectAtIndex:i]];
            i--;
        }
        else if ([generalFaxList containsObject:[categoryArray objectAtIndex:i]]) {
            [categoryArray removeObject:[categoryArray objectAtIndex:i]];
            i--;
        }
        else if ([workmobileList containsObject:[categoryArray objectAtIndex:i]]) {
            [categoryArray removeObject:[categoryArray objectAtIndex:i]];
            i--;
        }
        else if ([homeMobileList containsObject:[categoryArray objectAtIndex:i]]) {
            [categoryArray removeObject:[categoryArray objectAtIndex:i]];
            i--;
        }
    }
    
    if ([categoryArray count] > 0)
    {
        [self.phoneDict setObject:categoryArray
                           forKey:[NSString stringWithFormat:@"%d",
                                   ContactPhoneTypeMain]];
    }
}

@end
