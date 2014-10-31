//
//  SQL.h
//  ZdywDBManager
//
//  Created by mini1 on 14-5-6.
//  Copyright (c) 2014年 Guoling. All rights reserved.
//

#ifndef BaseCore_SQL_h
#define BaseCore_SQL_h


//通话记录建表
#define kSQLCreateTableCallRecord @"create table if not exists CallRecord(\
recordID integer primary key autoincrement,\
contactID integer not null,\
phoneNumber text,\
duration integer,\
callDate text,\
callType integer not null)"

//插入通话记录
#define kSQLInsertCallRecord @"insert into CallRecord(\
contactID,\
phoneNumber,\
duration,\
callDate,\
callType) \
values (?,?,?,?,?)"

//通话记录查询所有
#define kSQLQueryAllCallRecord @"select \
recordID,\
contactID,\
phoneNumber,\
duration,\
callDate,\
callType \
from CallRecord \
order by callDate desc"

//按通话类型查找通话记录
#define kSQLQueryCallRecordByType @"select \
recordID,\
contactID,\
phoneNumber,\
duration,\
callDate,\
callType \
from CallRecord where \
callType = ? \
order by callDate desc"

//删除某一条通话记录
#define kSQLDeleteOneCallRecord  @"delete from CallRecord where \
recordID = ?"

//删除某一电话号码的通话记录
#define kSQLDeleteCallRecordByPhone @"delete from CallRecord where \
phoneNumber = ?"

//删除某一联系人的通话记录
#define kSQLDeleteCallRecordByContactID @"delete from CallRecord where \
contactID = ?"

//批量删除某一联系人的通话记录
#define kSQLDeleteCallRecordMulity(a) [NSString stringWithFormat:@"delete from CallRecord where recordID = %d",a]

//删除所有的通话记录
#define kSQLDeleteAllCallRecord @"delete from CallRecord"


//创建常用联系人表
#define kSQLCreateTableCommonContact @"create table if not exists CommonContact(\
_ID integer primary key autoincrement,\
contactID integer not null)"

//添加常用联系人
#define kSQLInsertTableCommonContact @"insert into CommonContact(\
contactID) \
values (?)"

//查询常用联系人
#define kSQLQueryAllCommonContact @"select distinct(contactID) from CommonContact"

//移除常用联系人
#define kSQLDeleteCommonContact @"delete from CommonContact where contactID = ?"


#pragma mark - 系统公告

//建表
#define kSQLSysMessageCreateTable @"create table if not exists SysMessage(\
msg_id integer primary key asc autoincrement default 1,\
msg_text text,\
msg_time text,\
msg_IsRead integer,\
msg_title text,\
msg_msgId integer,\
msg_Type integer,\
msg_redirectType integer,\
msg_redirectPage text,\
msg_buttonTitle text\
)"

//查询单条记录
#define kSQLSysMessageQueryOneMessage @"select \
msg_id,\
msg_text,\
msg_time,\
msg_IsRead,\
msg_title,\
msg_msgId,\
msg_Type,\
msg_redirectType,\
msg_redirectPage,\
msg_buttonTitle \
from SysMessage \
where \
msg_msgId = ? \
order by msg_time desc"


//查询全部记录
#define kSQLSysMessageQueryAllMessage @"select \
msg_id,\
msg_text,\
msg_time,\
msg_IsRead,\
msg_title,\
msg_msgId,\
msg_Type,\
msg_redirectType,\
msg_redirectPage,\
msg_buttonTitle \
from SysMessage \
order by msg_time desc"

//查询某一类型的全部记录
#define kSQLSysMessageQueryMessageForType @"select \
msg_id,\
msg_text,\
msg_time,\
msg_IsRead,\
msg_title,\
msg_msgId,\
msg_Type,\
msg_redirectType,\
msg_redirectPage,\
msg_buttonTitle \
from SysMessage \
where \
msg_Type = ? \
order by msg_time desc"

//删除单条记录
#define kSQLSysMessageDeleteOne @"delete from SysMessage \
where \
msg_msgId = ?"

//删除某一类型的记录
#define kSQLSysMessageDeleteForType @"delete from SysMessage \
where \
msg_Type = ?"

//删除全部记录
#define kSQLSysMessageDeleteAll @"delete from SysMessage"

//修改某一条记录
#define kSQLSysMessageModifyOne @"update SysMessage set \
msg_text = ?,\
msg_time = ?,\
msg_IsRead = ?,\
msg_title = ?,\
msg_Type = ?,\
msg_redirectType = ?,\
msg_redirectPage = ?,\
msg_buttonTitle = ? \
where \
msg_msgId = ?"

//修改是否已读
#define kSQLSysMessageModifyReadFlag @"update SysMessage set \
msg_IsRead = ? \
where \
msg_msgId = ?"

//插入一条记录
#define kSQLSysMessageInsertOne @"insert into SysMessage(\
msg_text,\
msg_time,\
msg_IsRead,\
msg_title,\
msg_msgId,\
msg_Type,\
msg_redirectType,\
msg_redirectPage,\
msg_buttonTitle\
) values(?,?,?,?,?,?,?,?,?)"

#pragma mark - 任务体系
#define kSQLActivityCreateTable @"create table if not exists Activity(\
ac_ID integer primary key,\
ac_type integer not null,\
ac_endDate text,\
ac_finishFlag integer,\
ac_title text,\
ac_desc text,\
ac_tips text,\
ac_jumpPage text,\
ac_jumpButtonTitle text,\
ac_showFlag integer,\
ac_sortIndex integer,\
ac_isNormal integer,\
ac_parentTitle text)"

#define kSQLActivityInsertOneActivity @"insert into Activity\
(ac_ID,ac_type,ac_endDate,ac_finishFlag,ac_title,ac_desc,ac_tips,ac_jumpPage,ac_jumpButtonTitle,ac_showFlag,ac_sortIndex,ac_isNormal,ac_parentTitle)\
values\
(?,?,?,?,?,?,?,?,?,?,?,?,?)"

#define kSQLActivityModifyOneActivity @"update Activity set \
ac_type = ? and \
ac_endDate = ? and \
ac_finishFlag = ? and \
ac_title = ? and \
ac_desc = ? and \
ac_tips = ? and \
ac_jumpPage = ? and \
ac_jumpButtonTitle = ? and \
ac_showFlag = ? and \
ac_sortIndex = ? and \
ac_isNormal = ? and \
ac_parentTitle = ? \
where ac_ID = ?"

#define kSQLActivityModifyOneActivityFinishFlag @"update Activity set \
ac_finishFlag = ? \
where ac_ID = ?"

#define kSQLActivityQueryAll @"select \
ac_ID,\
ac_type,\
ac_endDate,\
ac_finishFlag,\
ac_title,\
ac_desc,\
ac_tips,\
ac_jumpPage,\
ac_jumpButtonTitle,\
ac_showFlag,\
ac_sortIndex,\
ac_isNormal,\
ac_parentTitle \
from Activity order by ac_sortIndex asc"

#define kSQLActivityQueryByType @"select \
ac_ID,\
ac_type,\
ac_endDate,\
ac_finishFlag,\
ac_title,\
ac_desc,\
ac_tips,\
ac_jumpPage,\
ac_jumpButtonTitle,\
ac_showFlag,\
ac_sortIndex,\
ac_isNormal,\
ac_parentTitle \
from Activity \
where ac_type = ? \
order by ac_sortIndex asc"

#define kSQLActivityQueryByFinishFlag @"select \
ac_ID,\
ac_type,\
ac_endDate,\
ac_finishFlag,\
ac_title,\
ac_desc,\
ac_tips,\
ac_jumpPage,\
ac_jumpButtonTitle,\
ac_showFlag,\
ac_sortIndex,\
ac_isNormal,\
ac_parentTitle \
from Activity \
where ac_finishFlag = ? \
order by ac_sortIndex asc"

#define kSQLActivityQueryOne @"select \
ac_ID,\
ac_type,\
ac_endDate,\
ac_finishFlag,\
ac_title,\
ac_desc,\
ac_tips,\
ac_jumpPage,\
ac_jumpButtonTitle,\
ac_showFlag,\
ac_sortIndex,\
ac_isNormal,\
ac_parentTitle \
from Activity \
where ac_ID = ?"

//查寻正在进行中的任务数
#define kSQLActivityQueryUnderWayNumber @"select num(ac_ID) from Activity where ac_finishFlag = 1"

#define kSQLActivityDeleteOne @"delete from Activity where ac_ID = ?"

#define kSQLActivityDeleteAll @"delete from Activity"

#pragma mark - 用户行为统计

#define kSQLUserStatisticCreateTable @"create table if not exists UserStatistic(\
ust_ID integer primary key autoincrement,\
ust_page text not null,\
ust_evnet text not null,\
ust_start integer not null,\
ust_duration integer not null,\
ust_flag integer not null)"

#define kSQLUserStatisticInsertOne @"insert into UserStatistic(\
ust_page,\
ust_evnet,\
ust_start,\
ust_duration,\
ust_flag) values (?,?,?,?,?)"

#define kSQLUserStatisticUpdateFlag @"update UserStatistic set ust_flag=? where ust_ID=?"

#define kSQLUserStatisticDelete   @"delete from UserStatistic where ust_page=\"%@\" and ust_evnet=\"%@\" and ust_start=%d and ust_flag=0"

#define kSQLUserStatisticSelect @"select ust_ID,ust_page,ust_evnet,ust_start,ust_duration from UserStatistic where ust_flag = 0"

#define kSQLUserStatisticInsert @"insert into UserStatistic(ust_page,ust_evnet,ust_start,ust_duration,ust_flag) values (\"%@\",\"%@\",%d,%d,%d)"

#pragma mark - 富媒体消息

#define kSQLUserRichMsgCreateTable @"create table if not exists RichMessage(\
rmgId integer primary key autoincrement,\
msgId integer not null,\
msgType text,\
msgTypeName text,\
msgStyle integer,\
effectTime text,\
topFlag integer,\
msgTime text)"

#define kSQLUserRichMsgContentCreateTable @"create table if not exists RichMsgContent(\
rmcId integer primary key autoincrement,\
msgId integer not null,\
msgTitle text,\
summary text,\
imgUrl text,\
jumpType text,\
jumpBtnTitle text,\
jumpUrl text,\
imgIndex integer)"

#define kSQLRichMsgInsert(a) [NSString stringWithFormat:@"insert into RichMessage(msgId,msgType,msgTypeName,msgStyle,effectTime,topFlag,msgTime) values %@",a]

#define kSQLRichContentInsert(a) [NSString stringWithFormat:@"insert into RichMsgContent(msgId,msgTitle,summary,imgUrl,jumpType,jumpBtnTitle,jumpUrl,imgIndex) values %@",a]

#define kSQLRichMsgQueryByPage @"select rmgId,msgId,msgType,msgTypeName,msgStyle,effectTime,topFlag,msgTime \
from RichMessage order by topFlag desc,rmgId desc limit ?,?"

#define kSQLRichMsgQueryOne @"select rmgId,msgId,msgType,msgTypeName,msgStyle,effectTime,topFlag,msgTime \
from RichMessage where msgId = ?"

#define kSQLRichContentQueryForMsgId @"select \
rmcId,msgId,msgTitle,summary,imgUrl,jumpType,jumpBtnTitle,jumpUrl,imgIndex \
from RichMsgContent where msgId = ? order by imgIndex"

#define kSQLRichContentQueryOne @"select \
rmcId,msgId,msgTitle,summary,imgUrl,jumpType,jumpBtnTitle,jumpUrl,imgIndex \
from RichMsgContent where msgId = ? and imgIndex = ?"

#define kSQLRichMsgQueryCount @"select count(msgId) from RichMessage"

#define kSQLRichMsgUpdateTop @"update RichMessage set topFlag = 0"

#define kSQLRichMsgDeleteOne @"delete from RichMessage where msgId = ?"

#define kSQLRichMsgDeleteAll @"delete from RichMessage"

#define kSQLRichContentDeleteMsg @"delete from RichMsgContent where msgId = ?"

#define kSQLRichContentDeleteOne @"delete from RichMsgContent where msgId = ? and imgIndex = ?"

#define kSQLRichContentDeleteAll @"delete from RichMsgContent"


#endif
