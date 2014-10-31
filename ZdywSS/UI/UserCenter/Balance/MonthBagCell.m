//
//  MonthBagCell.m
//  ZdywClient
//
//  Created by ddm on 6/24/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "MonthBagCell.h"

@interface MonthBagCell ()

@property (nonatomic, strong) UILabel *bagTitle;
@property (nonatomic, strong) UILabel *bagChargeTime;

@end

@implementation MonthBagCell

#pragma mark - lifeCycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _bagTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 23, 260, 23)];
        _bagTitle.textColor = [UIColor blackColor];
        _bagTitle.font = [UIFont systemFontOfSize:18.0];
        _bagTitle.backgroundColor = [UIColor clearColor];
        [self addSubview:_bagTitle];
        
        _bagChargeTime = [[UILabel alloc] initWithFrame:CGRectMake(20, 46, 260, 23)];
        _bagChargeTime.textColor = [UIColor lightGrayColor];
        _bagChargeTime.font = [UIFont systemFontOfSize:16.0];
        _bagChargeTime.backgroundColor = [UIColor clearColor];
        [self addSubview:_bagChargeTime];
        
        UIImageView *separateLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 95.0, 320, 0.5)];
        separateLine.backgroundColor = [UIColor colorWithRed:235.0/255 green:235.0/255 blue:235.0/255 alpha:1.0];
        [self addSubview:separateLine];
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

- (void)setMonthBagModel:(MonthBagModel *)monthBagModel{
    _monthBagModel = monthBagModel;
    _bagTitle.text = _monthBagModel.bagName;
    _bagChargeTime.text = [NSString stringWithFormat:@"生效日期: %@",[_monthBagModel.buyTime substringToIndex:10]];
}

@end
