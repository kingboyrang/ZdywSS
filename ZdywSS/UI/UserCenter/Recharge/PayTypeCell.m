//
//  PayTypeCell.m
//  ZdywClient
//
//  Created by ddm on 6/25/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "PayTypeCell.h"

@implementation PayTypeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _payTypeName = [[UILabel alloc] initWithFrame:CGRectMake(75, 17, 245, 20)];
        [self addSubview:_payTypeName];
        
        _payTypeImageview = [[UIImageView alloc] initWithFrame:CGRectMake(20, 5, 43, 43)];
        [_payTypeImageview setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_payTypeImageview];
        
        UIImageView* separateLineImage = [[UIImageView alloc] initWithFrame:CGRectMake(75, 53.5, 245, 0.5)];
        [separateLineImage setBackgroundColor:[UIColor colorWithRed:219.0/255 green:219.0/255 blue:214.0/255 alpha:1.0]];
        [self addSubview:separateLineImage];
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
