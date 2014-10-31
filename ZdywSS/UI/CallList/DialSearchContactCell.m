//
//  DialSearchContactCell.m
//  WldhClient
//  拨号盘搜索联系人界面
//  Created by mini1 on 13-8-1.
//  Copyright (c) 2013年 guoling. All rights reserved.
//

#import "DialSearchContactCell.h"
#import "FontManager.h"
#import "FontLabelStringDrawing.h"

@interface DialSearchContactCell()

@property (nonatomic ,strong) UIImageView *separateLineImageView;

@end

@implementation DialSearchContactCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        // 名字
        _contactNameLab = [[FontLabel alloc] initWithFrame:CGRectMake(10, 11, 100, 32)] ;
        [self.contactNameLab setLineBreakMode:NSLineBreakByTruncatingTail];
        self.contactNameLab.textAlignment = UITextAlignmentLeft;
        self.contactNameLab.backgroundColor = UIColor.clearColor;
        self.contactNameLab.font = [UIFont boldSystemFontOfSize:16];
        self.contactNameLab.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.contactNameLab];
        
        // 电话或者名字拼音
        _phoneNumberLab = [[FontLabel alloc] initWithFrame:CGRectMake(110, 11, 160, 32)] ;
        [self.phoneNumberLab setLineBreakMode:NSLineBreakByTruncatingTail];
        self.phoneNumberLab.textAlignment = UITextAlignmentLeft;
        self.phoneNumberLab.backgroundColor = UIColor.clearColor;
        self.phoneNumberLab.font = [UIFont boldSystemFontOfSize:16];
        self.phoneNumberLab.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:self.phoneNumberLab];
        
        _detailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_detailBtn setFrame:CGRectMake(280, 10, 30, 35)];
        [_detailBtn setBackgroundImage:[UIImage imageNamed:@"contact_detail_btn.png"] forState:UIControlStateNormal];
        [_detailBtn addTarget:self action:@selector(showDetailView) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_detailBtn];
        
        _separateLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 53, self.frame.size.width, 1)];
        [_separateLineImageView setBackgroundColor:[UIColor colorWithRed:234.0/255 green:234.0/255 blue:234.0/255 alpha:1.0]];
        [self.contentView addSubview:_separateLineImageView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// 判断字符串是否包含汉字
// string : 需要判断的字符串
- (BOOL)isContainChinese:(NSString*)string;
{
    for(int i = 0; i < [string length]; ++i)
    {
        unichar a = [string characterAtIndex:i];
        if(a >= 0x4e00 && a <= 0x9fff)
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)showDetailView{
    if (_delegate && [_delegate respondsToSelector:@selector(showContactDetail:)]) {
        [_delegate showContactDetail:_contactID];
    }
}

- (void)createCustomColorLabe:(T9ContactRecord*)contactRecordA
{
    UIColor *colorHot = [UIColor colorWithRed:248.0/255.0 green:79.0/255.0 blue:33.0/255.0 alpha:1.0];
    BOOL isHanzi = [self isContainChinese:contactRecordA.strName];
    if (isHanzi)
    {
        self.contactNameLab.zAttributedText = nil;
        self.contactNameLab.text = contactRecordA.strName;
    }
    else
    {
        ZMutableAttributedString *str = [[ZMutableAttributedString alloc] initWithString:contactRecordA.strName];
        
        if( 1 == contactRecordA.searchGroup && contactRecordA.rangeMatch.length > 0 )
        {
            if( contactRecordA.rangeMatch.location + contactRecordA.rangeMatch.length <= str.length )
            {
                [str addAttribute:ZForegroundColorAttributeName value:colorHot range:contactRecordA.rangeMatch];
            }
            else
            {
                NSLog( @"WHY rangeMatch is over the strValue? %@ [%d + %d]",
                      str, contactRecordA.rangeMatch.location, contactRecordA.rangeMatch.length );
            }
        }
        
        self.contactNameLab.zAttributedText = str;
    }
    
    ZMutableAttributedString *str = nil;
    int nSearchGroup = contactRecordA.searchGroup;
    if ( (3 == nSearchGroup || 2 == nSearchGroup )
        && contactRecordA.rangeMatch.length > 0 )
    {
        str = [[ZMutableAttributedString alloc] initWithString:contactRecordA.strValue];
        if( contactRecordA.rangeMatch.location + contactRecordA.rangeMatch.length <= str.length )
        {
            [str addAttribute:ZForegroundColorAttributeName value:colorHot range:contactRecordA.rangeMatch];
        }
        else
        {
            NSLog( @"WHY rangeMatch is over the strValue? %@ [%d + %d]",
                  str, contactRecordA.rangeMatch.location, contactRecordA.rangeMatch.length );
        }
    }
    else if ( 1 == nSearchGroup && contactRecordA.rangeMatch.length > 0 )
    {
        str = [[ZMutableAttributedString alloc] initWithString:contactRecordA.strValue];
    }
    else if ( 4 == nSearchGroup && contactRecordA.rangeMatch.length > 0 )
    {
        str = [[ZMutableAttributedString alloc] initWithString:contactRecordA.strPinyinOfAcronym];
        NSString *strAcronym = contactRecordA.strValue;
        NSString *strPinyin = contactRecordA.strPinyinOfAcronym;
        NSInteger nextSearchBeginIndex = 0;
        for (NSInteger index = contactRecordA.rangeMatch.location;
             index < contactRecordA.rangeMatch.location + contactRecordA.rangeMatch.length;
             ++index)
        {
            NSRange tmpRange = [strPinyin rangeOfString:[strAcronym substringWithRange:NSMakeRange( index, 1)]
                                                options:NSCaseInsensitiveSearch
                                                  range:NSMakeRange(nextSearchBeginIndex,
                                                                    [strPinyin length] - nextSearchBeginIndex)];
            nextSearchBeginIndex = tmpRange.location + 1;
            if ( tmpRange.location != NSNotFound )
            {
                [str addAttribute:ZForegroundColorAttributeName value:colorHot range:tmpRange];
                tmpRange.location = NSNotFound;
            }
            else
            {
                NSLog(@"WHY NOT FOUND PINYIN in ACRONYM???");
                break;
            }
        }
    }
    else
    {
        str = [[ZMutableAttributedString alloc] initWithString:contactRecordA.strValue];
    }
    if( str )
    {
        self.phoneNumberLab.zAttributedText = str;
    }
}

@end
