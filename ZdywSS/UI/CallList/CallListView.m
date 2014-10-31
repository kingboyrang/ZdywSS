//
//  CallListView.m
//  ZdywClient
//
//  Created by ddm on 6/9/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "CallListView.h"
#import "ContactManager.h"
#import "T9ContactRecord.h"

@interface CallListView (){
    NSInteger _dialPlateHeight;
}

@property (nonatomic, strong) UITableView       *callListTableView;
@property (nonatomic, strong) UITableView       *searchListTableView;
@property (nonatomic, strong) NSMutableArray    *callList;
@property (nonatomic, strong) NSMutableArray    *T9SearchList;
@property (nonatomic, strong) DialPlateView     *dialPlateView;
@property (nonatomic, strong) UIButton          *editBtn;
@property (nonatomic, strong) UIButton          *emptyBtn;
@property (nonatomic, assign) EditStatus        editStatus;
@property (nonatomic, strong) NSString          *T9KeyStr;
@property (nonatomic, strong) UIView            *tipsView;

@end

@implementation CallListView

#pragma mark - liftCycle

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
    [self InitMainView];
    [self callRecordDataChangedInMain];
    [self addObservers];
    self.backgroundColor = [UIColor clearColor];
    _callList = [[NSMutableArray alloc] initWithCapacity:2];
    _T9SearchList = [[NSMutableArray alloc] initWithCapacity:2];
    [self performSelector:@selector(reloadCallListData) withObject:nil afterDelay:2.0]; //延迟一秒加载，防止过早加载不能读取到电话号码地区
}

#pragma mark - Observers

- (void)addObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callRecordDataChanged)
                                                 name:@"CallRecordRefresh"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callRecordDataChanged)
                                                 name:kNotifyContactDataChanged
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callRecordDataChangedInMain)
                                                 name:KLoginSuccess
                                               object:nil];
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CallRecordRefresh" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifyContactDataChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KLoginSuccess object:nil];
}

#pragma mark - PrivateMethod

- (void)InitMainView{
    
    [self setBackgroundColor:[UIColor clearColor]];
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-75, 320, 75)];
    [_bottomView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_bottomView];
    
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    [lineImageView setBackgroundColor:[UIColor colorWithRed:231.0/255 green:231.0/255 blue:231.0/255 alpha:1.0]];
    [_bottomView addSubview:lineImageView];
    
    UIButton *unFlodBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [unFlodBtn setBackgroundImage:[UIImage imageNamed:@"dialplate_unflod_bg"] forState:UIControlStateNormal];
    [unFlodBtn addTarget:self action:@selector(dialUnflod) forControlEvents:UIControlEventTouchUpInside];
    [unFlodBtn setFrame:CGRectMake(123, 1, 75, 75)];
    [_bottomView addSubview:unFlodBtn];
    
    UIImageView *unFlodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(147, 20, 25, 26)];
    unFlodImageView.image = [UIImage imageNamed:@"dialplate_key_unflod"];
    [_bottomView addSubview:unFlodImageView];
    
    UILabel *unFlodLable = [[UILabel alloc] initWithFrame:CGRectMake(148, 43, 40, 20)];
    unFlodLable.text = @"拨号";
    [unFlodLable setFont:[UIFont systemFontOfSize:12.0]];
    [unFlodLable setBackgroundColor:[UIColor clearColor]];
    [_bottomView addSubview:unFlodLable];
    
    _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    _editBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [_editBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_editBtn setFrame:CGRectMake(273, 28, 40, 25)];
    [_editBtn addTarget:self action:@selector(editCallList) forControlEvents:UIControlEventTouchUpInside];
    _editStatus = EditStatus_Normal;
    [_bottomView addSubview:_editBtn];
    
    _emptyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_emptyBtn setTitle:@"清空" forState:UIControlStateNormal];
    [_emptyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_emptyBtn setFrame:CGRectMake(10, 28, 40, 25)];
    [_emptyBtn addTarget:self action:@selector(emptyCallList) forControlEvents:UIControlEventTouchUpInside];
    [_emptyBtn setHidden:YES];
    [_bottomView addSubview:_emptyBtn];
    
    _callListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - _bottomView.frame.size.height)];
    _callListTableView.backgroundColor = [UIColor clearColor];
    _callListTableView.showsVerticalScrollIndicator = NO;
    [_callListTableView setDelegate:self];
    [_callListTableView setDataSource:self];
    [_callListTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self addSubview:_callListTableView];
    
    _searchListTableView = [[UITableView alloc] initWithFrame:_callListTableView.frame];
    [_searchListTableView setDataSource:self];
    [_searchListTableView setDelegate:self];
    _searchListTableView.backgroundColor = [UIColor clearColor];
    [_searchListTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self addSubview:_searchListTableView];
    
    _tipsView = [[UIView alloc] initWithFrame:_callListTableView.frame];
    
    UILabel *tipLable = [[UILabel alloc] initWithFrame:CGRectMake(30, 50, 260, 50)];
    tipLable.text = @"暂没有通话记录";
    tipLable.textAlignment = NSTextAlignmentCenter;
    tipLable.font = [UIFont systemFontOfSize:16.0];
    tipLable.textColor = [UIColor lightGrayColor];
    tipLable.backgroundColor = [UIColor clearColor];
    [_tipsView addSubview:tipLable];
    [self addSubview:_tipsView];
    
    _dialPlateView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DialPlateView class]) owner:self options:nil] objectAtIndex:0];
    _dialPlateView.frame = CGRectMake(0, self.frame.size.height-_dialPlateView.frame.size.height, 320, _dialPlateView.frame.size.height);
    _dialPlateHeight =_dialPlateView.frame.size.height;
    _dialPlateView.dialPlateViewDelagate = self;
    [self addSubview:_dialPlateView];
}

- (void)callRecordDataChanged
{
    [self performSelectorOnMainThread:@selector(callRecordDataChangedInMain) withObject:nil waitUntilDone:YES];
}

- (void)reloadCallListData{
    [_callListTableView reloadData];
}

- (void)callRecordDataChangedInMain{
    @synchronized(_callList){
        [_callList removeAllObjects];
        NSArray *aList = [[ContactManager shareInstance] megerContactRecord];
        [_callList addObjectsFromArray:aList];
        if ([_callList count] > 0) {
            [_callListTableView setHidden:NO];
            [_tipsView setHidden:YES];
            _editBtn.enabled = YES;
            [_searchListTableView setHidden:YES];
        } else {
            [_callListTableView setHidden:YES];
            [_tipsView setHidden:NO];
            _editBtn.enabled = NO;
            [_searchListTableView setHidden:YES];
        }
        [_callListTableView reloadData];
    }
}

- (void)deleteAllRecordInMain
{
    BOOL ret = [[ContactManager shareInstance].myRecordEngine deleteAllRecord];
    if (ret)
    {
        @synchronized(self.callListTableView)
        {
            _editStatus = EditStatus_Finish;
            [_callList removeAllObjects];
            self.tipsView.hidden = NO;
            _editBtn.enabled = NO;
            [self editCallList];
            [_callListTableView reloadData];
        }
    }
    else
    {
        NSLog(@"删除所有通话记录失败");
    }
}

//处理通话时间
- (NSString *)callRecordTimeWithDateString:(NSString *)dateStr
{
    if (0 == [dateStr length])
    {
        NSLog(@"通话时间为空");
        return @"";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kContactRecordTimeFormatter];
    NSDate *recordDate = [formatter dateFromString:dateStr];
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
    NSInteger recordHour = [recordComps hour];
    NSInteger recordMinute = [recordComps minute];
    
    if (nowYear == recordYear && nowMonth == recordMonth && nowDay == recordDay) //当日
    {
        return [NSString stringWithFormat:@"%02d:%02d",recordHour,recordMinute];
    } else if (nowYear == recordYear && nowMonth == recordMonth && nowDay == recordDay+1) //昨天
    {
        return @"昨天";
    } else if (nowYear == recordYear) //当年
    {
        return [NSString stringWithFormat:@"%02d月%02d日",recordMonth,recordDay];
    } else {
        return [NSString stringWithFormat:@"%d",recordYear];
    }
}

#pragma mark - Common

- (void)updateSubViewFrame:(BOOL)bUpdata
{
    if(bUpdata)
    {
        //_bottomView.frame = CGRectMake(0, self.frame.size.height-75+kCallListViewOffSet, 320, 75);
        _bottomView.frame = CGRectMake(0, self.frame.size.height-75, 320, 75);
        
        _callListTableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - _bottomView.frame.size.height);
        _searchListTableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - _bottomView.frame.size.height);
        _dialPlateView.frame = CGRectMake(0, self.frame.size.height-_dialPlateView.frame.size.height+kCallListViewOffSet, 320, _dialPlateView.frame.size.height);
    }
    else
    {
        //_bottomView.frame = CGRectMake(0, self.frame.size.height-75-(2*kCallListViewOffSet), 320, 75);
        _bottomView.frame = CGRectMake(0, self.frame.size.height-75, 320, 75);
        _callListTableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - _bottomView.frame.size.height);
        _searchListTableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - _bottomView.frame.size.height);
        
        _dialPlateView.frame = CGRectMake(0, self.frame.size.height-_dialPlateView.frame.size.height, 320, _dialPlateView.frame.size.height);
    }

}
//获取联系人号码归属地
- (NSString *)phoneAttributionForPhone:(NSString *)phoneNumber
{
    
    NSString *attStr = [[ContactManager shareInstance] phoneAttributionWithPhoneNumber:phoneNumber
                                                                           countryCode:[ZdywUtils getLocalStringDataValue:kCurrentCountryCode]];
    if (0 == [attStr length])
    {
        attStr = @"未知";
    }
    attStr = [attStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    return attStr;
}

#pragma mark - BtnAction

- (void)editCallList{
    _searchListTableView.hidden = YES;
    if (_editStatus == EditStatus_Normal) {
        [_emptyBtn setHidden:NO];
        _editStatus = EditStatus_Finish;
        [_editBtn setTitle:@"完成" forState:UIControlStateNormal];
        for (CallListCell *cell in _callListTableView.visibleCells) {
            cell.showCallRecordsBtn.hidden = YES;
            cell.btnImageView.hidden = YES;
        }
    } else {
        [_emptyBtn setHidden:YES];
        _editStatus = EditStatus_Normal;
        [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        for (CallListCell *cell in _callListTableView.visibleCells) {
            cell.showCallRecordsBtn.hidden = NO;
            cell.btnImageView.hidden = NO;
        }
    }
    if (![_callList count]) {
        _editBtn.enabled = NO;
    }
    [self callListEdit];
}

- (void)emptyCallList{
    UIActionSheet *acsheet = [[UIActionSheet alloc] initWithTitle:nil
                                                         delegate:self
                                                cancelButtonTitle:@"取消"
                                           destructiveButtonTitle:@"清除最近所有通话"
                                                otherButtonTitles:nil];
    [acsheet showInView:[ZdywAppDelegate appDelegate].window];
}

- (void)callListEdit{
    if (self.callListTableView.editing||![_callList count])
    {
        [self.callListTableView setEditing:NO animated:YES];
    } else {
        [self.callListTableView setEditing:YES animated:YES];
    }
}

- (void)dialUnflod{
    [UIView animateWithDuration:0.35 animations:^{
        [_dialPlateView setHidden:NO];
        //_dialPlateView.frame = CGRectMake(0, self.frame.size.height-_dialPlateHeight, 320, _dialPlateHeight);
    } completion:^(BOOL finished) {
        [_dialPlateView setHidden:NO];
    }];
}

#pragma mark - Search
//获取搜索到的联系人
- (void)createSearchContact
{
    @synchronized(self.T9KeyStr)
    {
        [_T9SearchList removeAllObjects];
        [[ContactManager shareInstance] resetKey];
        
        if (0 != [self.T9KeyStr length])
        {
            for (int i = 0; i < [self.T9KeyStr length]; ++i)
            {
                NSInteger aKey = [[self.T9KeyStr substringWithRange:NSMakeRange(i, 1)] integerValue];
                [[ContactManager shareInstance] pushOneKey:aKey];
            }
        }
        else
        {
        }
        [self performSelectorOnMainThread:@selector(reloadSearch)
                               withObject:nil
                            waitUntilDone:YES];
    }
}

//刷新搜索数据
- (void)reloadSearch
{
    @synchronized(self.T9KeyStr)
    {
        [_T9SearchList removeAllObjects];
        //提取搜索数据
        NSArray *aList = [[ContactManager shareInstance] searchResult];
        [_T9SearchList addObjectsFromArray:aList];
        [self.searchListTableView reloadData];
    }
}

//添加一个搜索key
- (void)pushOneKey:(NSInteger)aKey
{
    @synchronized(self.T9KeyStr)
    {
        NSString *key = nil;
        if (aKey == 10) {
            key = @"*";
        }
        if (aKey == 11) {
            key = @"#";
        }
        if (aKey<10 && aKey>-1) {
            key = [NSString stringWithFormat:@"%d",aKey];
        }
        if (0 != [self.T9KeyStr length])
        {
            self.T9KeyStr = [self.T9KeyStr stringByAppendingString:key];
        }
        else
        {
            self.T9KeyStr = key;
        }
        [_callListTableView setHidden:YES];
        [_searchListTableView setHidden:NO];
        [_tipsView setHidden:YES];
        [[ContactManager shareInstance] pushOneKey:aKey];
        [self reloadSearch];
    }
}

//删除一个搜索键
- (void)popOneKey
{
    @synchronized(self.T9KeyStr)
    {
        NSInteger len = [self.T9KeyStr length];
        if (1 < len)
        {
            self.T9KeyStr = [self.T9KeyStr substringWithRange:NSMakeRange(0, len - 1)];
            [[ContactManager shareInstance] popOneKey];
        }
        else if(0 < len)
        {
            self.T9KeyStr = @"";
            [[ContactManager shareInstance] resetKey];
            if ([_callList count]) {
                [_callListTableView setHidden:NO];
                [_tipsView setHidden:YES];
            } else {
                [_tipsView setHidden:NO];
            }
            [_searchListTableView setHidden:YES];
            return;
        }
        else
        {
            if ([_callList count]) {
                [_callListTableView setHidden:NO];
                [_tipsView setHidden:YES];
            } else {
                [_tipsView setHidden:NO];
            }
            [_searchListTableView setHidden:YES];
            return;
        }
        [self reloadSearch];
    }
}

//删除键值
- (void)resetKey
{
    @synchronized(self.T9KeyStr)
    {
        self.T9KeyStr = @"";
        [[ContactManager shareInstance] resetKey];
        [self reloadSearch];
        [self T9KeyStr];
        if ([_callList count]) {
            [_callListTableView setHidden:NO];
            [_tipsView setHidden:YES];
        } else {
            [_tipsView setHidden:NO];
        }
        [_searchListTableView setHidden:YES];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        for (CallListCell *cell in _callListTableView.visibleCells) {
            cell.showCallRecordsBtn.hidden = NO;
        }
        [self performSelectorOnMainThread:@selector(deleteAllRecordInMain)
                               withObject:nil
                            waitUntilDone:YES];
    }
}

#pragma mark - CallListCellDelegate

- (void)showRecordMegerDetail:(RecordMegerNode *)recordNode{
    if (_delegate && [_delegate respondsToSelector:@selector(showRecordMegerDetailView:)]) {
        [_delegate showRecordMegerDetailView:recordNode];
    }
}

#pragma mark - DialSearchCellDelegate

- (void)showContactDetail:(NSInteger)contactID{
    if (_delegate && [_delegate respondsToSelector:@selector(showContactDetailViewWithContactID:)]) {
        [_delegate showContactDetailViewWithContactID:contactID];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (_dialPlateView.hidden == NO) {
        [UIView animateWithDuration:0.35 animations:^{
            //[_dialPlateView setFrame:CGRectMake(0, self.frame.size.height, 320, 0)];
        } completion:^(BOOL finished) {
            [_dialPlateView setHidden:YES];
        }];
    }
}

#pragma mark - DialPlateViewDelegate

- (void)dialViewAction:(NSInteger)buttonIndex dialPlateType:(DialPlateType)dialPlateType phoneLabel:(NSString *)phoneLableText{
    switch (dialPlateType) {
        case DialPlateType_DialNumber:{
            [self pushOneKey:buttonIndex];
            break;
        }
        case DialPlateType_DialDeleOne:{
            [self popOneKey];
            break;
        }
        case DialPlateType_DialDeleAll:{
            [self resetKey];
            break;
        }
        case DialPlateType_DialCallUser:{
            [[ZdywAppDelegate appDelegate] startCallWithPhoneNumber:phoneLableText contactName:nil contactID:-1];
            break;
        }
        case DialPlateType_DialFlod:{
            [UIView animateWithDuration:0.35 animations:^{
                //[_dialPlateView setFrame:CGRectMake(0, self.frame.size.height, 320, 0)];
            } completion:^(BOOL finished) {
                [_dialPlateView setHidden:YES];
            }];
            break;
        }
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _searchListTableView) {
        return 54;
    } else {
        return 54;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.callListTableView)
    {
        if (!tableView.editing)
            return UITableViewCellEditingStyleNone;
        else {
            return UITableViewCellEditingStyleDelete;
        }
    }
    else
    {
        return UITableViewCellEditingStyleNone;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.callListTableView)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _searchListTableView) {
        NSInteger count = [_T9SearchList count];
        if ([self.T9KeyStr length] > 0)
        {
            if (count > 0)
            {
                return count;
            } else {
                return 2;
            }
        } else {
            return count;
        }
    } else {
        return [_callList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _searchListTableView) {
        if ([_T9SearchList count] == 0 && [self.T9KeyStr length] > 0)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
            if (nil == cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"NormalCell"] ;
            }
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            if (indexPath.row == 0)
            {
                cell.textLabel.text = @"新建联系人";
                if (![cell.contentView viewWithTag:100]) {
                    CGRect r=cell.frame;
                    r.origin.y=54;
                    r.size.height=1;
                    UIView *menuCellBackView = [[UIView alloc] initWithFrame:r];
                    menuCellBackView.backgroundColor=[UIColor colorWithRed:234.0/255 green:234.0/255 blue:234.0/255 alpha:1.0];
                    menuCellBackView.tag=100;
                    [cell.contentView addSubview:menuCellBackView];
                }
            } else {
                cell.textLabel.text = @"添加到已有联系人";
            }
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                UIView *menuCellBackView = [[UIView alloc] initWithFrame:cell.frame];
                menuCellBackView.backgroundColor = [UIColor lightGrayColor];
                [cell setSelectedBackgroundView:menuCellBackView];
            }
            return cell;
        }
        else
        {
            DialSearchContactCell *cell = (DialSearchContactCell *)[tableView dequeueReusableCellWithIdentifier:@"SearchContactIn"];
            if (cell == nil)
            {
                cell = [[DialSearchContactCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:@"SearchContactIn"];
            }
            T9ContactRecord *oneRecord = [_T9SearchList objectAtIndex:indexPath.row];
            [cell setDelegate:self];
            cell.contactID = oneRecord.abRecordID;
            if (oneRecord)
            {
                [cell createCustomColorLabe:oneRecord];
            }
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                UIView *menuCellBackView = [[UIView alloc] initWithFrame:cell.frame];
                menuCellBackView.backgroundColor = [UIColor lightGrayColor];
                [cell setSelectedBackgroundView:menuCellBackView];
            }
            return cell;
        }
    } else {
        {
            CallListCell *cell = (CallListCell *)[tableView dequeueReusableCellWithIdentifier:@"CallList"];
            if (cell == nil)
            {
                cell = [[CallListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:@"CallList"] ;
                
            }
            [cell setDelegate:self];
            RecordMegerNode *oneRecord = (RecordMegerNode *)[_callList objectAtIndex:indexPath.row];
            cell.nameLabel.text = [NSString stringWithFormat:@"%@(%d)",oneRecord.contactName,[oneRecord.lastRecordList count]];
            if ([oneRecord.contactName isEqualToString:oneRecord.phoneNumber]) {
                cell.nameLabel.textColor = [UIColor colorWithRed:254.0/255 green:84.0/255 blue:0.0 alpha:1.0];
            } else {
                cell.nameLabel.textColor = [UIColor blackColor];
            }
            NSString *operatorStr = [[ContactManager shareInstance]PhoneOperatorsWithPhoneNumber:oneRecord.phoneNumber];
            cell.timeLabel.text = [self callRecordTimeWithDateString:oneRecord.lastDateString];
            cell.attributionLabel.text = [NSString stringWithFormat:@"%@  %@",[self phoneAttributionForPhone:oneRecord.phoneNumber],operatorStr];
            cell.cellIndexPath = indexPath;
            cell.recordMegerNode = oneRecord;
            cell.showCallRecordsBtn.hidden = NO;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                UIView *menuCellBackView = [[UIView alloc] initWithFrame:cell.frame];
                menuCellBackView.backgroundColor = [UIColor lightGrayColor];
                [cell setSelectedBackgroundView:menuCellBackView];
            }
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.callListTableView)
    {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            @synchronized(self.callListTableView)
            {
                NSMutableArray *aList = [NSMutableArray arrayWithCapacity:2];
                RecordMegerNode *oneRecord = (RecordMegerNode *)[_callList objectAtIndex:indexPath.row];
                for (ContactRecordNode *oneContactRecord in oneRecord.lastRecordList)
                {
                    [aList addObject:[NSNumber numberWithInteger:oneContactRecord.recordID]];
                }
                BOOL ret = YES;
                if ([aList count] > 0)
                {
                    ret = [[ContactManager shareInstance].myRecordEngine deleteRecords:aList];
                }
                if (ret)
                {
                    [_callList removeObjectAtIndex:indexPath.row];
                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row
                                                                                                  inSection:indexPath.section]]
                                     withRowAnimation:UITableViewRowAnimationFade];
                    
                    if ([_callList count] == 0)
                    {
                        self.tipsView.hidden = NO;
                        self.callListTableView.hidden = YES;
                        self.callListTableView.editing = NO;
                    }
                }
                else
                {
                    NSLog(@"删除通话记录失败");
                }
            }
        }
    }
}

#pragma mark - UITableViewDelegate

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == _searchListTableView) {
        if ([_T9SearchList count] == 0 && [self.T9KeyStr length] > 0)
        {
            switch (indexPath.row)
            {
                case 0:{ //新建
                    if (_delegate && [_delegate respondsToSelector:@selector(addNewContact:)]) {
                        [_delegate addNewContact:self.T9KeyStr];
                    }
                }
                    break;
                case 1: {//添加到现有联系人
                    if (_delegate && [_delegate respondsToSelector:@selector(addNewContact:)]) {
                        [_delegate addNewNumToContact:self.T9KeyStr];
                    }
                }
                    break;
                default:
                    break;
            }
        }
        else //拨打电话
        {
            T9ContactRecord *oneRecord = [_T9SearchList objectAtIndex:indexPath.row];
            if (oneRecord)
            {
                ContactNode *aContact = [[ContactManager shareInstance] getOneContactByID:oneRecord.abRecordID];
                if (nil != aContact
                    && kInValidContactID != aContact.contactID)
                {
                    //获取联系人电话号码
                    NSMutableArray  *aList = [NSMutableArray arrayWithCapacity:2];
                    NSArray *pList = [aContact contactAllPhone];
                    //电话号码不为空时才能拨打
                    if ([pList count] > 0)
                    {
                        DialSearchContactCell *oneCell = (DialSearchContactCell *)[tableView cellForRowAtIndexPath:indexPath];
                        if (oneCell)
                        {
                            //判断搜索匹配到的是否为电话号码，若是拨打电话，否则拨打联系人的某一个电话
                            BOOL isPhoneNumber = NO;
                            NSString *resultNumberStr = oneRecord.strValue;
                            for (NSString *onePhoneNum in pList)
                            {
                                if ([resultNumberStr isEqualToString:onePhoneNum])
                                {
                                    isPhoneNumber = TRUE;
                                    break;
                                }
                            }
                            if (!isPhoneNumber)
                            {
                                [aList addObjectsFromArray:pList];
                            }
                            else
                            {
                                [aList addObject:resultNumberStr];
                            }
                        }
                    }
                    if ([aList count] > 1) {
                        [[ZdywAppDelegate appDelegate] callWithContactID:aContact.contactID];
                    } else {
                        [[ZdywAppDelegate appDelegate] startCallWithPhoneNumber:[aList objectAtIndex:0]
                                                                    contactName:[aContact getContactFullName]
                                                                      contactID:aContact.contactID];
                    }
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                        message:@"拨打失败"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"我知道了"
                                                              otherButtonTitles:nil, nil];
                    [alertView show];
                }
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:@"拨打失败"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"我知道了"
                                                          otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
    } else {
        RecordMegerNode *oneRecord = (RecordMegerNode *)[_callList objectAtIndex:indexPath.row];
        [[ZdywAppDelegate appDelegate] startCallWithPhoneNumber:oneRecord.phoneNumber
                                                    contactName:oneRecord.contactName
                                                      contactID:oneRecord.contactID];
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
