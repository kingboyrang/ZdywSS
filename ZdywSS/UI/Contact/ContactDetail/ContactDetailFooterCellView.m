//
//  ContactDetailFooterCellView.m
//  ZdywClient
//
//  Created by ddm on 6/18/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "ContactDetailFooterCellView.h"

@implementation ContactDetailFooterCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    _callDateLable = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 90, 20)];
    _callDateLable.textColor = [UIColor lightGrayColor];
    [_callDateLable setFont:[UIFont systemFontOfSize:15.0]];
    _callDateLable.backgroundColor = [UIColor clearColor];
    [self addSubview:_callDateLable];
    
    _callPhoneNumLable = [[UILabel alloc] initWithFrame:CGRectMake(160, 0, 140, 20)];
    _callPhoneNumLable.textColor = [UIColor lightGrayColor];
    _callPhoneNumLable.textAlignment = NSTextAlignmentRight;
    [_callPhoneNumLable setFont:[UIFont systemFontOfSize:15.0]];
    _callPhoneNumLable.backgroundColor = [UIColor clearColor];
    [self addSubview:_callPhoneNumLable];
    
    _callTimeLable = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, 60, 20)];
    _callTimeLable.textColor = [UIColor lightGrayColor];
    [_callTimeLable setFont:[UIFont systemFontOfSize:15.0]];
    _callTimeLable.backgroundColor = [UIColor clearColor];
    [self addSubview:_callTimeLable];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
