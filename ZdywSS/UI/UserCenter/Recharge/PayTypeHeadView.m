//
//  PayTypeHeadView.m
//  ZdywClient
//
//  Created by ddm on 6/25/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "PayTypeHeadView.h"

@implementation PayTypeHeadView

#pragma mark - lifeCycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

#pragma mark - PrivateMethod

- (void)commonInit{
    UILabel *uidLable = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, 260, 20)];
    uidLable.text = [NSString stringWithFormat:@"账号: %@",[ZdywUtils getLocalStringDataValue:kZdywDataKeyUserID]];
    uidLable.textColor = [UIColor lightGrayColor];
    uidLable.backgroundColor = [UIColor clearColor];
    [self addSubview:uidLable];
    
    UILabel *phoneLable = [[UILabel alloc] initWithFrame:CGRectMake(30,29, 260, 20)];
    phoneLable.text = [NSString stringWithFormat:@"绑定手机号: %@",[ZdywUtils getLocalStringDataValue:kZdywDataKeyUserPhone]];
    phoneLable.textColor = [UIColor lightGrayColor];
    phoneLable.backgroundColor = [UIColor clearColor];
    [self addSubview:phoneLable];
    
    UILabel *packageTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, 62, 260, 20)];
    packageTitle.text = @"您选择的套餐为";
    [packageTitle setBackgroundColor:[UIColor clearColor]];
    [self addSubview:packageTitle];
    
    _packageName = [[UILabel alloc] initWithFrame:CGRectMake(30, 85, 260, 20)];
    _packageName.textColor = [UIColor colorWithRed:254.0/255 green:85.0/255 blue:0.0 alpha:1.0];
    _packageName.backgroundColor = [UIColor clearColor];
    [self addSubview:_packageName];
    
    UIImageView * separateLineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 114.5, 320, 0.5)];
    [separateLineImage setBackgroundColor:[UIColor colorWithRed:228.0/255 green:228.0/255 blue:228.0/255 alpha:1.0]];
    [self addSubview:separateLineImage];
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
