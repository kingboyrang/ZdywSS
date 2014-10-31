//
//  CallListCell.m
//  WldhClient
//
//  Created by mini1 on 13-8-6.
//  Copyright (c) 2013年 guoling. All rights reserved.
//

#import "CallListCell.h"

@implementation CallListCell
@synthesize nameLabel;
@synthesize phoneLabel;
@synthesize timeLabel;
@synthesize attributionLabel;
@synthesize cellIndexPath;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        // 联系人姓名
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, 160, 20)] ;
        [self.nameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        self.nameLabel.textAlignment = UITextAlignmentLeft;
        self.nameLabel.font = [UIFont systemFontOfSize:17.0];
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel setBackgroundColor:[UIColor clearColor]];
        
        // 电话号码
        self.phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 26, 160, 20)] ;
        [self.phoneLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        self.phoneLabel.textAlignment = UITextAlignmentLeft;
        self.phoneLabel.textColor = [UIColor darkGrayColor];
        self.phoneLabel.font = [UIFont systemFontOfSize:15.0];
        self.phoneLabel.backgroundColor = [UIColor clearColor];
//        [self.contentView addSubview:self.phoneLabel];
        
        // 时间
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 16, 105, 20)] ;
        [self.timeLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        self.timeLabel.textAlignment = UITextAlignmentRight;
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.font = [UIFont systemFontOfSize:15.0];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.timeLabel];
        
        // 地址
        self.attributionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 26, 200, 20)] ;
        [self.attributionLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        self.attributionLabel.textAlignment = UITextAlignmentLeft;
        self.attributionLabel.backgroundColor = UIColor.clearColor;
        self.attributionLabel.adjustsFontSizeToFitWidth = YES;
        self.attributionLabel.font = [UIFont systemFontOfSize:13.0];
        self.attributionLabel.backgroundColor = [UIColor clearColor];
        self.attributionLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.attributionLabel];
        
        self.buttomLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 53, 320, 0.5)];
        self.buttomLine.backgroundColor = [UIColor colorWithRed:214.0/255 green:214.0/255 blue:214.0/255 alpha:1.0];
        [self.contentView addSubview:self.buttomLine];
        
        _showCallRecordsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _showCallRecordsBtn.frame = CGRectMake(280, 2, 40, 50);
        [_showCallRecordsBtn addTarget:self action:@selector(showCallRecordDetail) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_showCallRecordsBtn];
        
        _btnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(290, 17, 15, 18)];
        _btnImageView.image = [UIImage imageNamed:@"contact_detail_btn.png"];
        _btnImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_btnImageView];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showCallRecordDetail{
    if (_delegate && [_delegate respondsToSelector:@selector(showRecordMegerDetail:)]) {
        [_delegate showRecordMegerDetail:_recordMegerNode];
    }
}

@end
