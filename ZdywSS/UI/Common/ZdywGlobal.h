//
//  ZdywGlobal.h
//  ZdywMini
//  全局控制的一些宏
//  Created by mini1 on 14-5-28.
//  Copyright (c) 2014年 Guoling. All rights reserved.
//

#ifndef ZdywMini_ZdywGlobal_h
#define ZdywMini_ZdywGlobal_h


#define L(obj)          NSLocalizedString (obj, nil)
#define kZdywIsIos7 ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)       //是否为ios7
#define kZdywIsRetain4  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)    //是否为4寸屏

#define kZdywScreenWidth 320.0f
#define kZdywScreenHeight  (kZdywIsRetain4 ? 568.0f : 480.0f)

#define kNavigationBarTintColor         [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
//导航栏的设置
#define kNavigationBarBgColor           [UIColor colorWithRed:28.0/255 green:28.0/255 blue:28.0/255 alpha:1.0] //导航背景设置
#define kNavigationBarBackGroundColor   [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] //导航栏返回字体颜色设置
#define kNavigationBarTitleFontColor    [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]//导航栏标题字体颜色设置
#define kNavigationBarTitleFontSize     [UIFont fontWithName:@"Arial-Bold" size:22.0] //导航栏标题字体大小设置
#define kNavigationBarTitleHasShadow    1  //导航栏标题是否有阴影（0表示无 1:表示有）
#define kNavigationBarTitleShadowColor  [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8]//导航栏标题阴影颜色设置

//项目中字体颜色设置
#define kZdywFontColor                  [UIColor colorWithRed:1.0/255.0 green:168.0/255.0 blue:230.0/255.0 alpha:1.0] //整个字体颜色配置
#define kZdywMainSelectedFontColor      [UIColor colorWithRed:1.0/255.0 green:168.0/255.0 blue:230.0/255.0 alpha:1.0] //通话记录与联系人选中时的颜色
#define kZdywMainNormalFontColor        [UIColor colorWithRed:1.0/255.0 green:168.0/255.0 blue:230.0/255.0 alpha:1.0] //通话记录与联系人未选中时的颜色
#endif
