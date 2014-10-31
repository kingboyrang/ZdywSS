//
//  ContactDetailHeadView.m
//  ZdywClient
//
//  Created by ddm on 6/16/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "ContactDetailHeadView.h"

@implementation ContactDetailHeadView

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
    _nameLable = [[UILabel alloc] initWithFrame:CGRectMake(30, 58, 200, 30)];
    _nameLable.backgroundColor = [UIColor clearColor];
    _nameLable.font = [UIFont systemFontOfSize:22.0];
    _nameLable.textColor = [UIColor whiteColor];
    _nameLable.backgroundColor = [UIColor clearColor];
    [self addSubview:_nameLable];
    
    _officeLable = [[UILabel alloc] initWithFrame:CGRectMake(30, 90, 250, 20)];
    _officeLable.backgroundColor = [UIColor clearColor];
    _officeLable.font = [UIFont systemFontOfSize:14.0];
    _officeLable.textColor = [UIColor whiteColor];
    _officeLable.backgroundColor = [UIColor clearColor];
    [self addSubview:_officeLable];
    
    _positionNameLable = [[UILabel alloc] initWithFrame:CGRectMake(30, 110, 250, 20)];
    _positionNameLable.backgroundColor = [UIColor clearColor];
    _positionNameLable.font = [UIFont systemFontOfSize:14.0];
    _positionNameLable.textColor = [UIColor whiteColor];
    _positionNameLable.backgroundColor = [UIColor clearColor];
    [self addSubview:_positionNameLable];
}

- (void)updateUI{
    if (![_positionNameLable.text length] && [_officeLable.text length]) {
        _nameLable.frame = CGRectMake(30, 78, _nameLable.frame.size.width, _nameLable.frame.size.height);
        _officeLable.frame = CGRectMake(30, 110, _officeLable.frame.size.width, _officeLable.frame.size.height);
        [_positionNameLable setHidden:YES];
        [_officeLable setHidden:NO];
    } else if([_positionNameLable.text length] && ![_officeLable.text length]){
        _nameLable.frame = CGRectMake(30, 78, _nameLable.frame.size.width, _nameLable.frame.size.height);
        _positionNameLable.frame = CGRectMake(30, 110, _officeLable.frame.size.width, _officeLable.frame.size.height);
        [_positionNameLable setHidden:NO];
        [_officeLable setHidden:YES];
    } else if (![_positionNameLable.text length] && ![_officeLable.text length]){
        _nameLable.frame = CGRectMake(30, 98, _nameLable.frame.size.width, _nameLable.frame.size.height);
        [_positionNameLable setHidden:YES];
        [_officeLable setHidden:YES];
    } else{
        _nameLable.frame = CGRectMake(30, 58, _nameLable.frame.size.width, _nameLable.frame.size.height);
        _officeLable.frame = CGRectMake(30, 90, _officeLable.frame.size.width, _officeLable.frame.size.height);
        [_positionNameLable setHidden:NO];
        [_officeLable setHidden:NO];
    }
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
