//
//  SystemNoticeView.m
//  ZdywClient
//
//  Created by ddm on 7/9/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "SystemNoticeView.h"
#import "UIImage+Scale.h"

#define cancleBtn_tag   102
#define jumpBtn_tag     103

@interface SystemNoticeView ()

@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UILabel *msgLable;
@property (nonatomic, strong) UIButton *cancleBtn;
@property (nonatomic, strong) UIButton *jumpBtn;

@end

@implementation SystemNoticeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - PublicMethod

- (id)initWithSysMessageObj:(SysMessageObj*)sysmessage{
    self = [super init];
    if (self) {
        _sysMessageObj = sysmessage;
        self.frame = CGRectMake(0, 0, 320, 240);
        [self setBackgroundColor:[UIColor whiteColor]];
        UIImageView *noticeIconImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 25, 21, 22)];
        noticeIconImage.image = [UIImage imageNamed:@"system_notice_icon"];
        [self addSubview:noticeIconImage];
        
        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(33, 25, 80, 26)];
        _titleLable.text = sysmessage.msg_title;
        _titleLable.backgroundColor = [UIColor clearColor];
        _titleLable.font = [UIFont systemFontOfSize:17.0];
        [self addSubview:_titleLable];
        
        UIImageView *titleLine = [[UIImageView alloc] initWithFrame:CGRectMake(10, 53, 300, 1)];
        titleLine.backgroundColor = [UIColor colorWithRed:215.0/255 green:215.0/255 blue:215.0/255 alpha:1.0];
        [self addSubview:titleLine];
        
        _msgLable = [[UILabel alloc] initWithFrame:CGRectMake(30, 70, 260, 100)];
        _msgLable.numberOfLines = 0;
        _msgLable.lineBreakMode = UILineBreakModeWordWrap;
        _msgLable.textColor = [UIColor blackColor];
        _msgLable.font = [UIFont systemFontOfSize:15.0];
        _msgLable.text = sysmessage.msg_text;
        [self addSubview:_msgLable];
        
        _jumpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _jumpBtn = [[UIButton alloc] initWithFrame:CGRectMake(197, self.frame.size.height-65, 98, 40)];
        [_jumpBtn setTitle:sysmessage.msg_buttonTitle forState:UIControlStateNormal];
        _jumpBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_jumpBtn.layer setMasksToBounds:YES];
        [_jumpBtn setTitleColor:[UIColor colorWithRed:5.0/255 green:146.0/255 blue:216.0/255 alpha:1.0] forState:UIControlStateNormal];
        [_jumpBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_jumpBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        _jumpBtn.layer.borderWidth = 1.0;
        _jumpBtn.layer.cornerRadius = 15.0;
        _jumpBtn.layer.borderColor = [UIColor colorWithRed:194.0/255 green:194.0/255 blue:194.0/255 alpha:1.0].CGColor;
        _jumpBtn.tag = jumpBtn_tag;
        [self addSubview:_jumpBtn];
        
        _cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(140, self.frame.size.height-10, 40, 5)];
        _cancleBtn.layer.masksToBounds = YES;
        _cancleBtn.layer.cornerRadius = 3.0;
        [_cancleBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:147.0/255 green:147.0/255 blue:147.0/255 alpha:1.0]] forState:UIControlStateNormal];
        [_cancleBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        _cancleBtn.tag = cancleBtn_tag;
        [self addSubview:_cancleBtn];
    }
    return self;
}

#pragma mark - PublicMethod

- (CGRect)systemNoticeFrame{
    CGSize labelsize = [_msgLable.text sizeWithFont:_msgLable.font constrainedToSize:CGSizeMake(260, 100)];
    NSInteger lableHeight = labelsize.height;
    if (lableHeight < 20) {
        lableHeight = 20;
    }
    _msgLable.frame = CGRectMake(30, 70, 260, lableHeight);
    [_msgLable sizeToFit];
    self.frame = CGRectMake(0, 0, 320, _msgLable.frame.origin.y+_msgLable.frame.size.height+83);
    _jumpBtn.frame = CGRectMake(197, self.frame.size.height-65, 95, 40);
    _cancleBtn.frame = CGRectMake(140, self.frame.size.height-10, 40, 5);
    return self.frame;
}

- (void)btnAction:(UIButton*)button{
    if (_delegate && [_delegate respondsToSelector:@selector(systemNoticeView:dissMiss:)]) {
        [_delegate systemNoticeView:_sysMessageObj dissMiss:button.tag];
    }
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
