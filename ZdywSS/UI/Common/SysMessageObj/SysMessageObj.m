//
//  SysMessageObj.m
//  ZdywClient
//
//  Created by ddm on 7/10/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "SysMessageObj.h"

@implementation SysMessageObj

- (id)initWithDictory:(NSDictionary*)dic{
    self = [super init];
    if (self) {
        id contentStr = [dic objectForKey:@"content"];
        if (contentStr && ![contentStr isKindOfClass:[NSNull class]]) {
            _msg_text = contentStr;
        }
        
        id titleStr = [dic objectForKey:@"title"];
        if (titleStr && ![titleStr isKindOfClass:[NSNull class]]) {
            _msg_title = titleStr;
        }
        
        id msgNum = [dic objectForKey:@"id"];
        if (msgNum && ![msgNum isKindOfClass:[NSNull class]]) {
            _msg_msgId = [msgNum integerValue];
        }
        
        id redirect_typeStr = [dic objectForKey:@"redirect_type"];
        if (redirect_typeStr && ![redirect_typeStr isKindOfClass:[NSNull class]]) {
            _msg_redirectType = redirect_typeStr;
        }
        
        id redirectPageStr = [dic objectForKey:@"redirect_target"];
        if (redirectPageStr && ![redirectPageStr isKindOfClass:[NSNull class]]) {
            _msg_redirectPage = redirectPageStr;
        }
        
        id buttonTitleStr = [dic objectForKey:@"redirect_btn_text"];
        if (buttonTitleStr && ![buttonTitleStr isKindOfClass:[NSNull class]]) {
            _msg_buttonTitle = buttonTitleStr;
        }
        
        id msg_urlstr = [dic objectForKey:@"redirect_target"];
        if (msg_urlstr && ![msg_urlstr isKindOfClass:[NSNull class]]) {
            _msg_url = msg_urlstr;
        }
        
        _msg_Type = 0;
        if ([_msg_redirectType isEqualToString:@"in"]) {
            _msg_Type = 0;
        } else {
            _msg_Type = 1;
        }
        if (_msg_Type == 1) {
            NSString *strURL = [dic objectForKey:@"redirect_target"];
            if([strURL length] > 0)
            {
                _msg_redirectPage = strURL;
            }
        }
    }
    return self;
}

@end
