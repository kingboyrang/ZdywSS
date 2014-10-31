//
//  ContactDetailCell.m
//  ZdywClient
//
//  Created by ddm on 6/16/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "ContactDetailCell.h"
#import "UIImage+Scale.h"

@implementation ContactDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    _phoneLable = [[UILabel alloc] initWithFrame:CGRectMake(30, 20, 150, 25)];
    _phoneLable.font = [UIFont systemFontOfSize:18.0];
    _phoneLable.backgroundColor = [UIColor clearColor];
    [self addSubview:_phoneLable];
    
    _phoneTypeLable = [[UILabel alloc] initWithFrame:CGRectMake(175, 21, 80, 23)];
    _phoneTypeLable.font = [UIFont systemFontOfSize:14.0];
    _phoneTypeLable.textColor = [UIColor lightGrayColor];
    _phoneTypeLable.backgroundColor = [UIColor clearColor];
    [self addSubview:_phoneTypeLable];
    
    _phoneAreaLable = [[UILabel alloc] initWithFrame:CGRectMake(30, 42, 100, 20)];
    _phoneAreaLable.font = [UIFont systemFontOfSize:14.0];
    _phoneAreaLable.textColor = [UIColor lightGrayColor];
    _phoneAreaLable.backgroundColor = [UIColor clearColor];
    [self addSubview:_phoneAreaLable];
    
    _phoneOperatorsLable = [[UILabel alloc] initWithFrame:CGRectMake(120, 42, 100, 20)];
    _phoneOperatorsLable.font = [UIFont systemFontOfSize:14.0];
    _phoneOperatorsLable.textColor = [UIColor lightGrayColor];
    _phoneOperatorsLable.backgroundColor = [UIColor clearColor];
    [self addSubview:_phoneOperatorsLable];
    
    _callPhoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _callPhoneBtn.frame = CGRectMake(260, 20, 42, 41);
    _callPhoneBtn.layer.masksToBounds = YES;
    _callPhoneBtn.layer.cornerRadius = 15.0;
    _callPhoneBtn.layer.borderWidth = 1.0;
    _callPhoneBtn.layer.borderColor = [UIColor clearColor].CGColor;
    [_callPhoneBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:84.0/255 green:188.0/255 blue:4.0/255 alpha:1.0]] forState:UIControlStateNormal];
    [_callPhoneBtn addTarget:self action:@selector(callPhone) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_callPhoneBtn];
    
    UIImageView *callIcon = [[UIImageView alloc] initWithFrame:CGRectMake(266, 26, 30, 30)];
    callIcon.image = [UIImage imageNamed:@"findpwd_makecall.png"];
    [self addSubview:callIcon];
    
    _separateLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 77, 320, 1)];
    [_separateLine setBackgroundColor:[UIColor colorWithRed:236.0/255 green:236.0/255 blue:236.0/255 alpha:1.0]];
    [self addSubview:_separateLine];

}

- (void)callPhone{
    [[ZdywAppDelegate appDelegate] startCallWithPhoneNumber:_callNumber contactName:_callName  contactID:_callContactID];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
