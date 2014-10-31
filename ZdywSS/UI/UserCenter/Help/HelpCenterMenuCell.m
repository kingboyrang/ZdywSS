//
//  HelpCenterMenuCell.m
//  ZdywClient
//
//  Created by ddm on 6/20/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "HelpCenterMenuCell.h"

@interface HelpCenterMenuCell ()

@property (nonatomic, strong) UILabel *helpNameLable;

@end

@implementation HelpCenterMenuCell

#pragma mark - liftCycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - PrivateMethod

- (void)commonInit{
    
    _helpNameLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 14, 250, 20)];
    _helpNameLable.backgroundColor = [UIColor clearColor];
    [self addSubview:_helpNameLable];
    
    UIImageView * detailImage = [[UIImageView alloc] initWithFrame:CGRectMake(290, 15, 15, 18)];
    detailImage.image = [UIImage imageNamed:@"contact_detail_btn"];
    [self addSubview:detailImage];
    
    _separateLineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 47.0, 320, 0.5)];
    [_separateLineImage setBackgroundColor:[UIColor colorWithRed:219.0/255 green:219.0/255 blue:214.0/255 alpha:1.0]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [self addSubview:_separateLineImage];
    }
    
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)setHelpNameStr:(NSString *)helpNameStr{
    _helpNameStr = helpNameStr;
    _helpNameLable.text = _helpNameStr;
}

@end
