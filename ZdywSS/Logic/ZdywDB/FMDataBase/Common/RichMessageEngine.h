//
//  RichMessageEngine.h
//  ZdywDBManager
//
//  Created by mini1 on 14-4-15.
//  Copyright (c) 2014年 dyn. All rights reserved.
//

#import <Foundation/Foundation.h>

enum
{
    RichMessagStyleText = 1,
    RichMessagStyleSignleText = 2,
    RichMessagStyleSignleImage = 3,
    RichMessagStyleMulityImage = 4,
};

typedef NSInteger RichMessagStyle;

@interface RichMessageObj : NSObject

@property(nonatomic,assign) NSInteger rmId;
@property(nonatomic,assign) NSInteger msgId;
@property(nonatomic,strong) NSString  *msgType;
@property(nonatomic,strong) NSString  *msgTypeName;
@property(nonatomic,assign) NSInteger msgStyle;
@property(nonatomic,strong) NSString  *effectTime;
@property(nonatomic,assign) NSInteger topFlag;
@property(nonatomic,strong) NSString  *msgTime;

@property(nonatomic,strong) NSMutableArray *msgContentList;

- (NSString *)createValues;

- (void)createDataWithDict:(NSDictionary *)dict;

@end

@interface RichContentObj : NSObject

@property(nonatomic,assign) NSInteger rcId;
@property(nonatomic,assign) NSInteger msgId;
@property(nonatomic,strong) NSString  *msgTitle;
@property(nonatomic,strong) NSString  *summary;
@property(nonatomic,strong) NSString  *imgUrl;
@property(nonatomic,strong) NSString  *jumpType;
@property(nonatomic,strong) NSString  *jumpBtnTitle;
@property(nonatomic,strong) NSString  *jumpUrl;
@property(nonatomic,assign) NSInteger imgIndex;

- (NSString *)createValues;

- (void)createDataWithDict:(NSDictionary *)dict;

@end

@interface RichMessageEngine : NSObject

+ (NSInteger)updateRichMessage:(NSArray *)msgList
                groupIsChanged:(BOOL)isChanged;

+ (BOOL)insertRichMessage:(RichMessageObj *)msgObj;

+ (BOOL)insertRichMessages:(NSArray *)msgObjList;

+ (NSArray *)richMessagesWithPage:(NSInteger)pageIndex pageSize:(NSInteger)pSize;

+ (RichMessageObj *)richMessageWithMsgId:(NSInteger)msgId;

+ (NSArray *)richContentsWithMsgId:(NSInteger)msgId;

+ (RichContentObj *)richContentWithMsgId:(NSInteger)msgId msgIndex:(NSInteger)msgIndex;

+ (BOOL)dropTopRichMessage;

+ (BOOL)deleteAllRichMessage;

+ (BOOL)deleteRichMessageWithMsgId:(NSInteger)msgId;

+ (BOOL)deleteAllRichContent;

+ (BOOL)deleteRichContentWithMsgId:(NSInteger)msgId;

+ (BOOL)deleteRichContentWithMsgId:(NSInteger)msgId msgIndex:(NSInteger)msgIndex;

+ (NSInteger)msgCount;

@end
