//
//  DeskContactEngine.m
//  ContactManager
//  联系人快捷方式
//  Created by mini1 on 13-6-8.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import "DeskContactEngine.h"
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#import "ContactManager.h"

@interface DeskContactEngine()

/*
 功能：启线程创建web服务
 */
- (void)handleStartWebServer;

/*
 功能：处理客户端对web服务的请求
 */
- (void)handleWebRequest:(NSNumber *)fdNum;

/*
 功能：处理客户端对web服务的请求
 */
- (void)handleObserveServer;

@end

@implementation DeskContactEngine

@synthesize contactID;
@synthesize socketError;
@synthesize headImageData = _headImageData;  //桌面图标数据(Base64加密),每次创建快捷图标时，先必须生成该数据,否则桌面的图标可能会显示不准确或无法显示

@synthesize htmlResourcePath; //网页文件的路径
@synthesize mySchemName;  //服务名称（在info.plist中配置的url schem)

- (void)dealloc
{
    if (nil != _observeServerTimer)
    {
        if ([_observeServerTimer isValid])
        {
            [_observeServerTimer invalidate];
            _observeServerTimer = nil;
        }
    }
    
    [self stopServer];
    
    self.headImageData = nil;
    self.htmlResourcePath = nil;
    self.mySchemName = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        _server_socket_fd = 0;
        
        _contactID = kInValidContactID;
        
        _socketError = NO;
        
        //启动监测web服务的计时器
        _observeServerTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                               target:self
                                                             selector:@selector(handleObserveServer)
                                                             userInfo:nil
                                                              repeats:YES];
        [_observeServerTimer retain];
    }
    
    return self;
}

/*
 函数描述：开启服务
 输入参数：port     端口号
 schemName 服务名称（在info.plist中配置的url schem)
 filePath  html网页的路径
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)startServerWithPort:(NSInteger)port schemName:(NSString *)schemName htmlPath:(NSString *)filePath
{
    [self stopServer];
    
    if (0 == [schemName length] + [filePath length])
    {
        NSLog(@"ContactManager_%s 参数错误",__FUNCTION__);
        return;
    }
    
    _port = port;
    self.mySchemName = schemName;
    self.htmlResourcePath = filePath;
    
    _startWebServerThread = [[NSThread alloc] initWithTarget:self
                                                    selector:@selector(handleStartWebServer)
                                                      object:nil];
    
    [_startWebServerThread start];
}

/*
 函数描述：开启服务线程
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)handleStartWebServer
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    self.socketError = NO;
    
    struct sockaddr_in serv_addr;
    
    // Set up socket
    if((_server_socket_fd = socket(AF_INET, SOCK_STREAM,0)) < 0)
    {
        self.socketError = YES;
        
        return;
    }
    
    // Serve to a random port
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    serv_addr.sin_port = htons(_port);
    
    // Bind
    if(bind(_server_socket_fd, (struct sockaddr *)&serv_addr,sizeof(serv_addr)) < 0)
    {
        self.socketError = YES;
        
        return;
    }
    
    // Listen
    if(listen(_server_socket_fd, 64) < 0)
    {
        self.socketError = YES;
        
        return;
    }
    
    // Respond to requests until the service shuts down
    int client_socket_fd;
    socklen_t length;
    static struct sockaddr_in client_addr;
    
    while (true)
    {
        length = sizeof(client_addr);
        
        if((client_socket_fd = accept(_server_socket_fd, (struct sockaddr *)&client_addr, &length)) < 0)
        {
            self.socketError = YES;
            
            return;
        }
        
        [self handleWebRequest:[NSNumber numberWithInt:client_socket_fd]];
    }
    
    [pool release];
}

/*
 函数描述：停止服务
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)stopServer
{
    if (_startWebServerThread)
    {
        [_startWebServerThread cancel];
        [_startWebServerThread release];
        _startWebServerThread = nil;
    }
    
    if (_server_socket_fd > 0)
    {
        close(_server_socket_fd);
        _server_socket_fd = 0;
    }
    
    _socketError = NO;
}

/*
 函数描述：监测Color字符串是否正确
 输入参数：strColor
 输出参数：N/A
 返 回 值：BOOL 是否正确
 作    者：刘斌
 */
- (BOOL)isHex16ColorString:(NSString *)strColor
{
    if (7 != [strColor length])
    {
        return NO;
    }
    
    if (![strColor hasSuffix:@"#"])
    {
        return NO;
    }
    
    for (int i = 1; i < [strColor length]; ++i)
    {
        char cc = [strColor characterAtIndex:i];
        if ((cc >= '0' && cc <= '9') || (cc >= 'a' && cc <= 'f'))
        {
            continue;
        }
        else
        {
            return NO;
        }
    }
    
    return YES;
}

/*
 函数描述：处理客户端对web服务的请求
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)handleWebRequest:(NSNumber *)fdNum
{
    int fd = [fdNum intValue];
    
    NSMutableString *strShortcutsInfo = [NSMutableString stringWithContentsOfFile:self.htmlResourcePath encoding:NSUTF8StringEncoding error:nil];
    
    //替换scheme和personID
    strShortcutsInfo = (NSMutableString *)[strShortcutsInfo stringByReplacingOccurrencesOfString:@"$APP_SCHEME$" withString:self.mySchemName];
    NSString *strPersonID = [NSString stringWithFormat:@"%d", self.contactID];
    strShortcutsInfo = (NSMutableString *)[strShortcutsInfo stringByReplacingOccurrencesOfString:@"$PERSON_ID$" withString:strPersonID];
    
    // 头像
    if (nil == self.headImageData)
    {
        self.headImageData = [NSData data];
    }
    NSMutableString *strImage = [[NSMutableString alloc] initWithData:self.headImageData encoding:NSUTF8StringEncoding];
    strShortcutsInfo = (NSMutableString *)[strShortcutsInfo stringByReplacingOccurrencesOfString:@"$ICON_DATA$" withString:strImage];
    [strImage release];
    
    //姓名
    ContactNode *oneContact = [[ContactManager shareInstance] getOneContactByID:self.contactID];
    NSString *strName = @"陌生人";
    if (nil != oneContact)
    {
        strName = [oneContact getContactFullName];
        if (0 == [[strName stringByReplacingOccurrencesOfString:@" " withString:@""] length])
        {
            strName = @"陌生人";
        }
    }
    strShortcutsInfo = (NSMutableString *)[strShortcutsInfo stringByReplacingOccurrencesOfString:@"$USER_NAME$" withString:strName];
    
    NSMutableString *str = [NSMutableString stringWithFormat:@"HTTP/1.1 302\nConnection:keep-alive\nLocation:%@\nContent-Type:text/html; charset=UTF-8\nServer:nginx/1.0.12", strShortcutsInfo];
    
    NSMutableData *data = (NSMutableData *)[str dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"data length = %d", [data length]);
    
    int ret = send(fd, [data bytes], [data length], 0);
    
    close(fd);
}

/*
 函数描述：处理客户端对web服务的请求
 输入参数：N/A
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)handleObserveServer
{
    if(self.socketError)
    {
        if(_server_socket_fd > 0)
        {
            int ret = close(_server_socket_fd);
            NSLog(@"ret = %d", ret);
        }
        
        if([_startWebServerThread isFinished])
        {
            [self startServerWithPort:_port schemName:self.mySchemName htmlPath:self.htmlResourcePath];
        }
    }
}

/*
 函数描述：创建桌面快捷方式
 输入参数：cID    联系人的ID
 输出参数：N/A
 返 回 值：N/A
 作    者：刘斌
 */
- (void)createDeskContactWithContactID:(NSInteger)cID
{
    if (cID != kInValidContactID)
    {
        self.contactID = cID;
        NSString *urlStr = [NSString stringWithFormat:@"http://localhost:%d",_port];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    }
}

#pragma mark -
#pragma mark other fun

@end
