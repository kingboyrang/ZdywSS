//
//  ContactListView.m
//  ZdywClient
//
//  Created by ddm on 6/10/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "ContactListView.h"
#import "T9ContactRecord.h"
#import "ContactDetailViewController.h"
#import "UIImage+Scale.h"

@interface ContactListView (){
    BOOL _isSearch;
}

@property (nonatomic, strong) NSDictionary          *contactDataDict;        //所有的联系人
@property (nonatomic, strong) NSMutableArray        *contactSectionKeyList;
@property (nonatomic, strong) NSMutableArray        *contactSearchList;
@property (nonatomic, strong) NSMutableDictionary   *chooseResultDict;

@end

@implementation ContactListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor blueColor]];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self addObservers];
    [self initData];
    BOOL ret = [[ContactManager shareInstance] addressBookIsAuthentication:YES];
    if (ret) {
        [_contactListTableView setHidden:NO];
    } else {
        [self createNotReadAddressBookTips];
        [_contactListTableView setHidden:YES];
    }
    _contactListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_addNewContactBtn addTarget:self action:@selector(addOneNewContact) forControlEvents:UIControlEventTouchUpInside];
}
//第一次安装时无法取得通讯录问题
- (void)loadFirstContact{
    NSUserDefaults *usDeaults = [NSUserDefaults standardUserDefaults];
    if (![usDeaults boolForKey:@"isFirstLoadContact"]) {
        [usDeaults setBool:YES forKey:@"isFirstLoadContact"];
        [usDeaults synchronize];
        BOOL ret = [[ContactManager shareInstance] addressBookIsAuthentication:YES];
        if (ret) {
            [_contactListTableView setHidden:NO];
            if (_contactListTableView&&[self.subviews containsObject:_notReadTipsView]) {
                [_notReadTipsView removeFromSuperview];
            }
            [self contactData];
        }
        //_notReadTipsView
    }
}
- (void)dealloc{
    [self removeObservers];
}

#pragma mark - ObserversMethod

- (void)addObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contactData)
                                                 name:kNotifyContactDataChanged
                                               object:nil];
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifyContactDataChanged object:nil];
}

#pragma mark - PrivateMethod

- (void)addOneNewContact{
    if (_delegate && [_delegate respondsToSelector:@selector(addNewContact)]) {
        [_delegate addNewContact];
    }
}

- (void)hasChoosedOneContact:(ContactNode *)aContact{
    if (_delegate && [_delegate respondsToSelector:@selector(showContactDetailView:)]) {
        [_delegate showContactDetailView:aContact];
    }
}

- (void)reloadListInMain{
    @synchronized(self.contactListTableView)
    {
        [self.contactListTableView reloadData];
    }
}

- (void)initData{
    _isSearch = NO;
    _contactSearchList = [NSMutableArray arrayWithCapacity:0];
    _contactSectionKeyList = [NSMutableArray arrayWithCapacity:0];
    _chooseResultDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    _seachBarBgView.image = [UIImage createImageWithColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    _seachBarBgView.layer.cornerRadius = 5.0;
    _seachBarBgView.layer.borderColor = [UIColor colorWithRed:207.0/255 green:207.0/255 blue:207.0/255 alpha:1.0].CGColor;
    _seachBarBgView.layer.borderWidth = 0.5;
    _seachBarBgView.layer.masksToBounds= YES;
    
    [_searchTextField addTarget:self action:@selector(textFieldChange:) forControlEvents:UIControlEventEditingChanged];
    _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [_searchTextField setTintColor:[UIColor grayColor]];
    }
}

- (void)contactData{
    NSDictionary *dict = nil;
    dict = [[ContactManager shareInstance] sortContactDict];
    if (dict) {
        [_contactSectionKeyList removeAllObjects];
        [_contactSectionKeyList addObjectsFromArray:[ContactManager shareInstance].sortKeyList];
        if (dict != nil) {
            _contactDataDict = [NSDictionary dictionaryWithDictionary:dict];
        }
        [_contactListTableView reloadData];
    }
}

- (void)createNotReadAddressBookTips{
    _notReadTipsView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 568)];
    [_notReadTipsView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:_notReadTipsView];
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(30, 80, 260, 25)];
    titleLable.text = @"联系人权限未开启";
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.textColor = [UIColor grayColor];
    [_notReadTipsView addSubview:titleLable];
    
    UILabel *tipLable = [[UILabel alloc] initWithFrame:CGRectMake(30, 105, 260, 50)];
    tipLable.numberOfLines = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        tipLable.text = [NSString stringWithFormat:@"打开手机系统“设置 -> 隐私 -> 通讯录 -> %@网络电话“，授权获取联系人",[ZdywCommonFun getAppConfigureInfoWithKey:kZdywDataKeyDisplayName]];
    } else {
        tipLable.text = [NSString stringWithFormat:@"打开手机系统“设置 -> 通用 -> 通讯录 -> %@网络电话“，授权获取联系人",[ZdywCommonFun getAppConfigureInfoWithKey:kZdywDataKeyDisplayName]];
    }
    tipLable.font = [UIFont systemFontOfSize:14.0];
    tipLable.textColor = [UIColor lightGrayColor];
    tipLable.textAlignment = NSTextAlignmentCenter;
    [_notReadTipsView addSubview:tipLable];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_isSearch) {
        return 1;
    }
    return [_contactSectionKeyList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_isSearch) {
        return [_contactSearchList count];
    }
    NSInteger index = section;
    NSString *akey = [_contactSectionKeyList objectAtIndex:index];
    if (akey != nil) {
        NSArray *aList = [_contactDataDict objectForKey:akey];
        return [aList count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_isSearch) {
        return 0;
    }
    return 23.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (_isSearch) {
        return nil;
    }
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 23)];
    imageview.image = [UIImage createImageWithColor:[UIColor colorWithRed:224.0/255 green:224.0/255 blue:224.0/255 alpha:0.9]];
    UILabel *sectionLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 1.5, 300, 20)];
    sectionLable.text = [_contactSectionKeyList objectAtIndex:section];
    sectionLable.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18.0];
    sectionLable.backgroundColor = [UIColor clearColor];
    [imageview addSubview:sectionLable];
    return imageview;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (_isSearch) {
        return nil;
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 6.0) {
        tableView.sectionIndexColor = [UIColor grayColor];
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0) {
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    NSMutableArray *aList = [NSMutableArray arrayWithObjects:
                             UITableViewIndexSearch,
                             nil];
    [aList addObjectsFromArray:_contactSectionKeyList];
    return aList;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    if (_isSearch) {
        return index;
    }
    if (index == 0)
    {
        return 0;
    }
    return index - 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isSearch) {
        ContactListCell *cell = (ContactListCell *)[tableView dequeueReusableCellWithIdentifier:@"ContactListSearchCell"];
        if (cell == nil)
        {
            cell = [[ContactListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"ContactListSearchCell"] ;
        }
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        T9ContactRecord *oneRecord = [_contactSearchList objectAtIndex:indexPath.row];
        ContactNode *aContact = [[ContactManager shareInstance] getOneContactByID:oneRecord.abRecordID];
        cell.contactListCellDelegate = self;
        cell.contactNameLable.text = [aContact getContactFullName];
        cell.isLastCell = NO;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
            UIView *menuCellBackView = [[UIView alloc] initWithFrame:cell.frame];
            menuCellBackView.backgroundColor = [UIColor lightGrayColor];
            [cell setSelectedBackgroundView:menuCellBackView];
        }
        return cell;
    } else {
        ContactListCell *contactCell = (ContactListCell*)[tableView dequeueReusableCellWithIdentifier:@"contactListCell"];
        if (contactCell == nil) {
            contactCell = [[ContactListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"contactListCell"];
        }
        NSInteger index = indexPath.section;
        NSString *aKey = [_contactSectionKeyList objectAtIndex:index];
        NSArray *aList = [self.contactDataDict objectForKey:aKey];
        if ([aList count] > 0)
        {
            ContactNode *aContact = (ContactNode *)[aList objectAtIndex:indexPath.row];
            if(nil != aContact)
            {
                contactCell.contactNameLable.text = [aContact getContactFullName];
            }
            else
            {
                contactCell.contactNameLable.text = @"";
            }
            contactCell.contactInfo = aContact;
        }
        if (indexPath.row == aList.count -1) {
            contactCell.isLastCell = YES;
        } else {
            contactCell.isLastCell = NO;
        }
        contactCell.contactListCellDelegate = self;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
            UIView *menuCellBackView = [[UIView alloc] initWithFrame:contactCell.frame];
            menuCellBackView.backgroundColor = [UIColor lightGrayColor];
            [contactCell setSelectedBackgroundView:menuCellBackView];
        }
        return contactCell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_isSearch) {
        T9ContactRecord *oneRecord = [_contactSearchList objectAtIndex:indexPath.row];
        ContactNode *aContact = [[ContactManager shareInstance] getOneContactByID:oneRecord.abRecordID];
        [self hasChoosedOneContact:aContact];
    } else {
        NSInteger section = indexPath.section;
        NSString *aKey = [_contactSectionKeyList objectAtIndex:section];
        NSArray *aList = [self.contactDataDict objectForKey:aKey];
        if ([aList count] > 0)
        {
            ContactNode *aContact = (ContactNode *)[aList objectAtIndex:indexPath.row];
            [self hasChoosedOneContact:aContact];
        }
    }
}

#pragma mark - searchTextField

- (void)textFieldChange:(UITextField*)textField{
    @synchronized(_contactSearchList)
    {
        [_contactSearchList removeAllObjects];
        if ([textField.text length] == 0)
        {
            _isSearch = NO;
        }
        else
        {
            _isSearch = YES;
            NSArray *aList = nil;
            aList = [[ContactManager shareInstance] searchResultWithText:textField.text];
            [_contactSearchList addObjectsFromArray:aList];
        }
        [self performSelectorOnMainThread:@selector(reloadListInMain)
                               withObject:nil
                            waitUntilDone:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (_searchTextField.isFirstResponder) {
        [_searchTextField resignFirstResponder];
    }
}

#pragma mark - ContactListCellDelegate

- (void)makeCallToContact:(ContactNode *)contactInfo{
    [[ZdywAppDelegate appDelegate] callWithContactID:contactInfo.contactID];
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
