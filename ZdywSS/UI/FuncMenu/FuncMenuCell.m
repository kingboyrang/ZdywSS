//
//  FuncMenuCell.m
//  ZdywClient
//
//  Created by ddm on 6/9/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "FuncMenuCell.h"

@implementation FuncMenuCell

#pragma mark - liftCycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        
        _funcIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 6, 24, 24)];
        [self addSubview:_funcIconImageView];
        
        _funcNameLable = [[UILabel alloc] initWithFrame:CGRectMake(44, 6, 80, 24)];
        [_funcNameLable setFont:[UIFont systemFontOfSize:16.0]];
        [_funcNameLable setTextColor:[UIColor whiteColor]];
        _funcNameLable.backgroundColor = [UIColor clearColor];
        [self addSubview:_funcNameLable];
        
        _separatorLine = [[UIImageView alloc] initWithFrame:CGRectMake(10, 37.5, 157, 0.5)];
        [_separatorLine setBackgroundColor:[UIColor colorWithRed:76.0/255 green:76.0/255 blue:76.0/255 alpha:1.0]];
        [self addSubview:_separatorLine];
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

#pragma mark - PrivateMethod


@end
