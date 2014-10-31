//
//  UserSetUpCell.m
//  ZdywClient
//
//  Created by ddm on 6/21/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "UserSetUpCell.h"

@implementation UserSetUpCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 13, 200, 20)];
        [_titleLable setTextColor:[UIColor blackColor]];
        _titleLable.font = [UIFont systemFontOfSize:16.0];
        _titleLable.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleLable];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
