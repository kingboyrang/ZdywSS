//
//  ContactListCell.m
//  ZdywClient
//
//  Created by ddm on 5/23/14.
//  Copyright (c) 2014 GuoLing. All rights reserved.
//

#import "ContactListCell.h"

@interface ContactListCell ()

@property (nonatomic, strong) UIImageView *separateLine;

@end

@implementation ContactListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _contactNameLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 242, 28)];
        _contactNameLable.backgroundColor = [UIColor clearColor];
        _contactNameLable.clearsContextBeforeDrawing = NO;
        [self addSubview:_contactNameLable];
        
        _callPhoneBtn = [[UIButton alloc] initWithFrame:CGRectMake(260, 15, 40, 28)];
        _callPhoneBtn.backgroundColor = [UIColor clearColor];
        [_callPhoneBtn addTarget:self action:@selector(makeCallForContact) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_callPhoneBtn];
        [_callPhoneBtn setHidden:YES];
        
        _separateLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 59, 320, 0.5)];
        [_separateLine setBackgroundColor:[UIColor colorWithRed:233.0/255 green:233.0/255 blue:233.0/255 alpha:1.0]];
        [self addSubview:_separateLine];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)makeCallForContact{
    if (_contactListCellDelegate && [_contactListCellDelegate respondsToSelector:@selector(makeCallToContact:)]) {
        [_contactListCellDelegate makeCallToContact:_contactInfo];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setIsLastCell:(BOOL)isLastCell{
        _separateLine.hidden = isLastCell;
}

@end
