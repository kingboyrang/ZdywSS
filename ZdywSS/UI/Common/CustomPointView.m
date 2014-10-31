//
//  CustomPointView.m
//  WldhClient
//
//  Created by ddm on 3/28/14.
//  Copyright (c) 2014 guoling. All rights reserved.
//

#import "CustomPointView.h"

@interface CustomPointView ()

@property (nonatomic, assign) BOOL isSelect;

@end

@implementation CustomPointView

#pragma mark - LiftCycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    _tipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 200)];
    _tipView.center = CGPointMake(self.center.x, self.center.y-20);
    _tipView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_tipView];
    
    _isSelect = NO;
    
    UIImageView *separateLineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, _tipView.frame.size.width, 1)];
    [separateLineImage setBackgroundColor:[UIColor colorWithRed:5.0/255 green:146.0/255 blue:215.0/255 alpha:1.0]];
    [_tipView addSubview:separateLineImage];
    
    _tipBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _tipView.frame.size.width,_tipView.frame.size.height)];
    [_tipBackgroundImageView setBackgroundColor:[UIColor clearColor]];
    [self.tipView addSubview:_tipBackgroundImageView];
    
    _tipTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, _tipView.frame.size.width, 30)];
    _tipTitle.font = [UIFont systemFontOfSize:19.0];
    _tipTitle.textAlignment = UITextAlignmentCenter;
    _tipTitle.backgroundColor = [UIColor clearColor];
    [_tipTitle setTextColor:[UIColor blackColor]];
    [self.tipView addSubview:_tipTitle];
    
    _tipLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 55, _tipView.frame.size.width-20*2, 60)];
    _tipLable.font = [UIFont systemFontOfSize:16.0];
    [_tipLable setNumberOfLines:0];
    _tipLable.lineBreakMode = UILineBreakModeWordWrap;
    [self.tipView addSubview:_tipLable];
    
    _tipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _tipButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 110, 18, 18)];
    [_tipButton setImage:[UIImage imageNamed:@"callback_tip_default"] forState:UIControlStateNormal];
    [_tipButton addTarget:self action:@selector(noTipBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_tipView addSubview:_tipButton];
    
    _noTipLable = [[UILabel alloc] initWithFrame:CGRectMake(45, 110, 80, 18)];
    _noTipLable.font = [UIFont systemFontOfSize:18.0];
    _noTipLable.text = @"不再提醒";
    _noTipLable.textColor = [UIColor lightGrayColor];
    [_tipView addSubview:_noTipLable];
    
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(45, 150, 178, 40)];
    _backButton.titleLabel.font = [UIFont systemFontOfSize:19.0];
    _backButton.layer.masksToBounds = YES;
    _backButton.layer.cornerRadius = 10.0;
    _backButton.layer.borderWidth = 1.0;
    _backButton.layer.borderColor = [UIColor colorWithRed:185.0/255 green:185.0/255 blue:185.0/255 alpha:1.0].CGColor;
    [_backButton addTarget:self action:@selector(disMissView) forControlEvents:UIControlEventTouchUpInside];
    [self.tipView addSubview:_backButton];
}


#pragma mark - ButtonAction

- (void)disMissView{
    [self removeFromSuperview];
    if (_delegate && [_delegate respondsToSelector:@selector(dismissCustomPointView)]) {
        [_delegate dismissCustomPointView];
    }
}

- (void)noTipBtnAction{
    if (_isSelect == NO) {
        [_tipButton setBackgroundImage:[UIImage imageNamed:@"callback_tip_select"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCallBackIsTip];
        _isSelect = YES;
    } else {
        [_tipButton setBackgroundImage:[UIImage imageNamed:@"callback_tip_default"] forState:UIControlStateNormal];
        _isSelect = NO;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kCallBackIsTip];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
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
