//
//  T9SearchEngine.h
//  ContactManager
//
//  Created by mini1 on 13-6-6.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface T9SearchEngine : NSObject
{
    void*       instance;
    BOOL        bIniting;                   //正在初始化
    BOOL        bInitSuccess;               //初始化结果
    
    BOOL        bTryToUseButNoInitSuccess;
    
    NSMutableArray*    arrayResult;    // item as id<T9ContactRecord*>
    BOOL       bHasResult;
}

@property(nonatomic,retain) NSMutableArray   *mySearchResult;

/*
 函数描述：加载搜索数据源
 输入参数：dataList   数据源
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)reloadDataSource:(NSArray *)dataList;

/*
 函数描述：重新加载搜索数据源
 输入参数：dataList   数据源
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)reloadDataSourceForSearchOnly:(NSArray *)dataList;

/*
 函数描述：搜索键入栈
 输入参数：key   键值(0~9)
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)pushOneKey:(NSInteger)key;

/*
 函数描述：搜索键出栈
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)popOneKey;

/*
 函数描述：重置搜索键值栈
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)resetKey;

/*
 函数描述：获取搜索结果
 输入参数：N/A
 输出参数：N/A
 返 回 值：NSArray   搜索结果
 作    者：刘斌
 */
- (NSArray*)getSearchResult;

/*
 函数描述：根据匹配字符串获取搜索结果
 输入参数：strSearchText    匹配字符串
 输出参数：N/A
 返 回 值：NSArray   搜索结果
 作    者：刘斌
 */
- (NSArray*)searchTextOnly:(NSString*)strSearchText;

@end
