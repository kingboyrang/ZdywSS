//
//  ContactDetailFooterView.m
//  ZdywClient
//
//  Created by ddm on 6/18/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "ContactDetailFooterView.h"
#import "ContactDetailFooterCellView.h"
#import "ContactRecordNode.h"
#import "ContactManager.h"

#define KContactDetailFooterCellHeight 20

@interface ContactDetailFooterView ()

@property (nonatomic, strong) UIScrollView *footerScrollView;

@end

@implementation ContactDetailFooterView

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

#pragma mark - PrivateMethod

- (void)commonInit{
    _footerScrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    [_footerScrollView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_footerScrollView];
}

- (void)setCallDetailList:(NSArray *)callDetailList{
    _callDetailList = callDetailList;
    if ([[_footerScrollView subviews] count]) {
        for (NSInteger i = 0; i<[_footerScrollView.subviews count]; i++) {
            ContactDetailFooterCellView *cellView = [_footerScrollView.subviews objectAtIndex:i];
            if (cellView && [cellView isKindOfClass:[ContactDetailFooterCellView class]]) {
                [cellView removeFromSuperview];
                i--;
            }
        }
    }
    for (NSInteger i = 0; i < [_callDetailList count]; i++) {
        ContactRecordNode *contactRecordNode = [_callDetailList objectAtIndex:i];
        ContactDetailFooterCellView *footerCell = [[ContactDetailFooterCellView alloc] initWithFrame:CGRectMake(0, 10+i*KContactDetailFooterCellHeight, 320, KContactDetailFooterCellHeight)];
        footerCell.callDateLable.text = [self getRecordDate:contactRecordNode.recordDateString];
        footerCell.callTimeLable.text = [self getRecordTime:contactRecordNode.recordDateString];
        
        footerCell.callPhoneNumLable.text = [[ContactManager shareInstance] deleteCountryCodeFromPhoneNumber:contactRecordNode.phoneNum
                                                                                                 countryCode:[ ZdywUtils getLocalStringDataValue:kCurrentCountryCode]];
        [_footerScrollView addSubview:footerCell];
    }
    [_footerScrollView setContentSize:CGSizeMake(320, 10+[_callDetailList count]*KContactDetailFooterCellHeight)];
}

- (NSString *)getRecordDate:(NSString *)recordDateStr{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd:HH:mm:ss"];
    NSDate *recordDate = [formatter dateFromString:recordDateStr];
    if (nil == recordDate)
    {
        NSLog(@"通话时间格式错误");
        return @"";
    }
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *nowComps = [calendar components:unitFlags fromDate:[NSDate date]];
    NSInteger nowYear = [nowComps year];
    NSInteger nowMonth = [nowComps month];
    NSInteger nowDay = [nowComps day];
    
    NSDateComponents *recordComps = [calendar components:unitFlags fromDate:recordDate];
    NSInteger recordYear = [recordComps year];
    NSInteger recordMonth = [recordComps month];
    NSInteger recordDay = [recordComps day];
    
    if (nowYear == recordYear && nowMonth == recordMonth && nowDay == recordDay) //当日
    {
        return @"今天";
    } else if (nowYear == recordYear && nowMonth == recordMonth && nowDay == recordDay+1) //昨天
    {
        return @"昨天";
    } else if (nowYear == recordYear) //当年
    {
        return [recordDateStr substringWithRange:NSMakeRange(5, 5)];
    } else {
        return [NSString stringWithFormat:@"%d",recordYear];
    }
}

- (NSString *)getRecordTime:(NSString *)recordTimeStr{
    NSString *recordTime = [recordTimeStr substringWithRange:NSMakeRange(11, 5)];
    return recordTime;
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
