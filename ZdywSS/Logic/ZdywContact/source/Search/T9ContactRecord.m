//
//  T9ContactRecord.m
//  ContactManager
//
//  Created by mini1 on 13-6-6.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import "T9ContactRecord.h"

@implementation T9ContactRecord

@synthesize abRecordID = _abRecordID;
@synthesize searchGroup = _searchGroup;
@synthesize strName = _strName;
@synthesize strValue = _strValue;
@synthesize strPinyinOfAcronym = _strPinyinOfAcronym;
@synthesize rangeMatch = _rangeMatch;

- (id)initWithIndex:(NSInteger)indexA
         abRecordID:(NSInteger)abRecordIDA
        searchGroup:(NSInteger)searchGroupA
               name:(NSString*)strNameA
              value:(NSString*)strValueA
    pinyinOfAcronym:(NSString*)strPinyinOfAcronymA
              range:(NSRange)rangeA
{
    if( self = [super init] )
    {
        _index = indexA;
        _abRecordID = abRecordIDA;
        _searchGroup = searchGroupA;
        _rangeMatch = rangeA;
        _strName = strNameA;
        _strValue = strValueA;
        _strPinyinOfAcronym = strPinyinOfAcronymA;
        
        return self;
    }
    else
    {
        return nil;
    }
}

@end
