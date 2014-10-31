//
//  UserRechargeCell.m
//  ZdywClient
//
//  Created by ddm on 6/25/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "UserRechargeCell.h"

@implementation UserRechargeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _rechargeNameLable = [[UILabel alloc] initWithFrame:CGRectMake(26, 15, 260, 22)];
        [self addSubview:_rechargeNameLable];
        
        UIImageView * separateLineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 53.5, 320, 0.5)];
        [separateLineImage setBackgroundColor:[UIColor colorWithRed:228.0/255 green:228.0/255 blue:228.0/255 alpha:1.0]];
        [self addSubview:separateLineImage];
        
        UIImageView * detailImage = [[UIImageView alloc] initWithFrame:CGRectMake(290, 18, 15, 18)];
        detailImage.image = [UIImage imageNamed:@"contact_detail_btn"];
        [self addSubview:detailImage];
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
