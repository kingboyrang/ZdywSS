//
//  UserMessageCell.m
//  ZdywClient
//
//  Created by ddm on 7/3/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "UserMessageCell.h"

#define ShowViewHeight  70

@interface UserMessageCell ()

@property (nonatomic, strong) UILabel *userInfoLabel;
@property (nonatomic, strong) UIButton *msgDetailBtn;

@end

@implementation UserMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        _showView = [[UIView alloc] initWithFrame:CGRectMake(10, 20, 300, 70)];
        [_showView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_showView];
        
        _userInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 280, 20)];
        _userInfoLabel.numberOfLines = 0;
        _userInfoLabel.lineBreakMode = UILineBreakModeWordWrap;
        _userInfoLabel.textColor = [UIColor blackColor];
        _userInfoLabel.font = [UIFont systemFontOfSize:15.0];
        [_showView addSubview:_userInfoLabel];
        
        _msgDetailView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 300, 30)];
        [_msgDetailView setBackgroundColor:[UIColor clearColor]];
        [_showView addSubview:_msgDetailView];
        
        UILongPressGestureRecognizer *longPressGr = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressDeleAction:)];
        [_showView setBackgroundColor:[UIColor whiteColor]];
        [_showView setUserInteractionEnabled:YES];
        [_showView addGestureRecognizer:longPressGr];
        
        UIImageView *separateLineImageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 0.5)];
        [separateLineImageview setBackgroundColor:[UIColor colorWithRed:234.0/255 green:234.0/255 blue:234.0/255 alpha:1.0]];
        [_msgDetailView addSubview:separateLineImageview];
        
        UILabel * detailLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 20)];
        detailLable.text = @"了解详情";
        detailLable.font = [UIFont systemFontOfSize:14.0];
        detailLable.textColor = [UIColor colorWithRed:5.0/255 green:146.0/255 blue:215.0/255 alpha:1.0];
        [_msgDetailView addSubview:detailLable];
        
        UIImageView *detailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(260, 6, 15, 18)];
        detailImageView.image = [UIImage imageNamed:@"contact_detail_btn.png"];
        [_msgDetailView addSubview:detailImageView];
        
        UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMsgDetail)];
        self.userInteractionEnabled = YES;
        [_msgDetailView addGestureRecognizer:tapGr];
        
        [self setBackgroundColor:[UIColor clearColor]];
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

#pragma mark - PublicMethod

- (void)setMsgStr:(NSString *)msgStr{
    _msgStr = msgStr;
    CGSize size = CGSizeMake(280,60);
    CGSize labelsize = [_msgStr sizeWithFont:_userInfoLabel.font constrainedToSize:size];
    NSInteger lableHeight = labelsize.height;
    if (lableHeight < 20) {
        lableHeight = 20;
    }
    _userInfoLabel.frame = CGRectMake(_userInfoLabel.frame.origin.x, _userInfoLabel.frame.origin.y, labelsize.width, labelsize.height);
    _userInfoLabel.text = _msgStr;
    
    _msgDetailView.frame = CGRectMake(0, _userInfoLabel.frame.origin.y+lableHeight+10, _msgDetailView.frame.size.width,_msgDetailView.frame.size.height);
    _showView.frame = CGRectMake(_showView.frame.origin.x, _showView.frame.origin.y, _showView.frame.size.width, ShowViewHeight+lableHeight-20);
    
    _showView.layer.masksToBounds = YES;
    _showView.layer.cornerRadius = 5.0;
    _showView.layer.borderWidth = 1.0;
    _showView.layer.borderColor = [UIColor colorWithRed:234.0/255 green:234.0/255 blue:234.0/255 alpha:1.0].CGColor;
}

#pragma mark - PrivateMethod

- (void)showMsgDetail{
    if (_delegate && [_delegate respondsToSelector:@selector(showMsgDetailView:)]) {
        [_delegate showMsgDetailView:_index];
    }
}

- (NSInteger)msgCellHeight{
    return _showView.frame.size.height+40;
}

- (void)longPressDeleAction:(UILongPressGestureRecognizer *)recognizer{
    [self.superview becomeFirstResponder];
    UIMenuController *pasteCopyMenuController = [UIMenuController sharedMenuController];
    if (!pasteCopyMenuController.menuVisible) {
        [_showView becomeFirstResponder];
        [_showView canBecomeFirstResponder];
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"删除"
                                                          action:@selector(deleteMsg)];
        UIMenuItem *pasteItem = [[UIMenuItem alloc] initWithTitle:@"取消"
                                                           action:@selector(cancelDele)];
        [pasteCopyMenuController setMenuItems:[NSArray arrayWithObjects:copyItem,pasteItem,nil]];
        [pasteCopyMenuController setTargetRect:CGRectMake(_showView.frame.origin.x, _showView.frame.origin.y+10, _showView.frame.size.width, _showView.frame.size.height) inView:_showView.superview];
        [pasteCopyMenuController setMenuVisible:YES animated:YES];
        [_showView setBackgroundColor:[UIColor colorWithRed:243.0/255 green:243.0/255 blue:243.0/255 alpha:1.0]];
        if (_delegate && [_delegate respondsToSelector:@selector(deleMsgIndex:)]) {
            [_delegate deleMsgIndex:_index];
        }
    }
}

- (void)deleteMsg{
}

- (void)cancelDele{
}

@end
