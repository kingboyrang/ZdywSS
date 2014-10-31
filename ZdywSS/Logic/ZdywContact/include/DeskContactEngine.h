//
//  DeskContactEngine.h
//  ContactManager
//  联系人快捷方式
//  Created by mini1 on 13-6-8.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DeskContactEngine : NSObject
{
    int                 _server_socket_fd;                  //web服务监听socket
    NSThread            *_startWebServerThread;             //启动web服务的线程
    
    NSInteger           _contactID;                         //所选联系人的RecordID;
    
    BOOL                _socketError;                       //web服务器异常标志
    
    NSTimer             *_observeServerTimer;               //监视web服务计时器
    
    NSData              *_headImageData;                    //桌面图标数据Base64加密,每次创建快捷图标时，先必须生成该数据,否则桌面的图标可能会显示不准确或无法显示
    
    NSInteger           _port;
}

@property(nonatomic,assign) NSInteger   contactID;
@property(nonatomic,assign) BOOL        socketError;
@property(nonatomic,retain) NSData      *headImageData;  //桌面图标数据Base64加密,每次创建快捷图标时，先必须生成该数据,否则桌面的图标可能会显示不准确或无法显示
@property(nonatomic,retain) NSString    *htmlResourcePath; //网页文件的路径
@property(nonatomic,retain) NSString    *mySchemName;   //服务名称（在info.plist中配置的url schem)

/*
 函数描述：开启服务
 输入参数：port     端口号
         schemName 服务名称（在info.plist中配置的url schem)
         filePath  html网页的路径
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)startServerWithPort:(NSInteger)port
                  schemName:(NSString *)schemName
                   htmlPath:(NSString *)filePath;

/*
 函数描述：停止服务
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)stopServer;

/*
 函数描述：创建桌面快捷方式
 输入参数：cID    联系人的ID
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)createDeskContactWithContactID:(NSInteger)cID;

@end
