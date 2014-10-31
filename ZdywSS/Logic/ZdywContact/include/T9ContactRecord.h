//
//  T9ContactRecord.h
//  ContactManager
//
//  Created by mini1 on 13-6-6.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface T9ContactRecord : NSObject
{
    NSInteger               _index;
    NSInteger               _abRecordID;         // as ABRecordID
    
    unsigned int            _searchGroup;        // as enumContactDetailGroup
    
    NSString                *_strName;           // for free use.
    NSString                *_strValue;          // maybe acronym, pinyin, name, phone
    NSString                *_strPinyinOfAcronym;// store pinyin if the value is acroym, other type is unknown!!!
    NSRange                 _rangeMatch;
}

@property (readonly, assign) NSInteger      abRecordID;
@property (readonly, assign) unsigned int   searchGroup;
@property (readonly, retain) NSString*      strName;
@property (readonly, retain) NSString*      strValue;
@property (readonly, retain) NSString*      strPinyinOfAcronym;
@property (readonly, assign) NSRange        rangeMatch;


- (id)initWithIndex:(NSInteger)indexA
         abRecordID:(NSInteger)abRecordIDA
        searchGroup:(NSInteger)searchGroupA
               name:(NSString*)strNameA
              value:(NSString*)strValueA
    pinyinOfAcronym:(NSString*)strPinyinOfAcronymA
              range:(NSRange)rangeA;

@end
