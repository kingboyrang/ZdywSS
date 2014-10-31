//
//  ContactViewController.m
//  ZdywClient
//
//  Created by ddm on 5/22/14.
//  Copyright (c) 2014 GuoLing. All rights reserved.
//

#import "ContactViewController.h"
#import "ContactListCell.h"
#import "ContactManager.h"
#import "T9ContactRecord.h"
#import "UIImage+Scale.h"
#import "ContactDetailViewController.h"

@interface ContactViewController (){
    BOOL _isSearch;
}

@property (nonatomic, strong) NSMutableArray            *contactSectionKeyList;
@property (nonatomic, strong) NSMutableArray            *contactSearchList;
@property (nonatomic, strong) NSMutableDictionary       *chooseResultDict;

@end

@implementation ContactViewController

#pragma mark - liftCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"联系人";
    self.navigationController.navigationBarHidden = NO;
    _contactSearchList = [NSMutableArray arrayWithCapacity:0];
    _contactSectionKeyList = [NSMutableArray arrayWithCapacity:0];
    _chooseResultDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    self.contactListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    BOOL ret = [[ContactManager shareInstance] addressBookIsAuthentication:YES];
    if (ret) {
        [_notReadTipsView setHidden:YES];
    } else {
        [self createNotReadAddressBookTips];
        [_notReadTipsView setHidden:NO];
    }
    NSDictionary *dict = nil;
    dict = [[ContactManager shareInstance] sortContactDict];
    [_contactSectionKeyList addObjectsFromArray:[ContactManager shareInstance].sortKeyList];
    if (dict != nil) {
        _contactDataDict = [NSDictionary dictionaryWithDictionary:dict];
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.contactListTable.sectionIndexBackgroundColor = [UIColor clearColor];
        [_searchTextField setTintColor:[UIColor grayColor]];
    }
    _seachBarBgView.image = [[[UIImage imageNamed:@"contact_searchtext_bg.png"] stretchableImageWithLeftCapWidth:35 topCapHeight:30] scaleToSize:CGSizeMake(600, 62)];
    [_searchTextField addTarget:self action:@selector(textFieldChange:) forControlEvents:UIControlEventEditingChanged];
    [self addObservers];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    if (self.contactListType == ContactListTypeCall) {
        UIButton *tempBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tempBackButton.frame = CGRectMake(0, 0, 40, 20);
        [tempBackButton setTitle:@"返回" forState:UIControlStateNormal];
        [tempBackButton addTarget:self
                           action:@selector(backToExit)
                 forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithCustomView:tempBackButton];
        self.navigationItem.leftBarButtonItem = leftBtn;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self removeObservers];
}

- (void)backToExit{
    [self.navigationController dismissModalViewControllerAnimated:YES];
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

#pragma mark - Private Method

- (void)contactData{
    NSDictionary *dict = nil;
    dict = [[ContactManager shareInstance] sortContactDict];
    if (dict) {
        [_contactSectionKeyList removeAllObjects];
        [_contactSectionKeyList addObjectsFromArray:[ContactManager shareInstance].sortKeyList];
        if ([_contactSectionKeyList count] > 0) {
            [_notReadTipsView setHidden:YES];
        }
        if (dict != nil) {
            _contactDataDict = [NSDictionary dictionaryWithDictionary:dict];
        }
        [_contactListTable reloadData];
    }
}

- (void)createNotReadAddressBookTips{
    _notReadTipsView.frame = CGRectMake(_contactListTable.frame.origin.x, _contactListTable.frame.origin.y, _notReadTipsView.frame.size.width, _notReadTipsView.frame.size.height);
    [_notReadTipsView setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:_notReadTipsView];
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

- (void)reloadListInMain{
    @synchronized(self.contactListTable)
    {
        [self.contactListTable reloadData];
    }
}

#pragma mark - AddNewPhoneNumToContact

- (void)addNewPhoneNumToContact:(ContactNode*)contactInfo{
        ABRecordRef onePerson = [[ContactManager shareInstance] getOneABRecordWithID:contactInfo.contactID];
        if (NULL != onePerson)
        {
            NSString *addNum = [NSString stringWithFormat:@"%@",_phoneNumberStr];
            CFErrorRef anError = NULL;
            
            ABMultiValueRef phoneList = ABRecordCopyValue(onePerson, kABPersonPhoneProperty);
            int phoneCount = ABMultiValueGetCount(phoneList);
            ABMutableMultiValueRef phoneLabel = ABMultiValueCreateMutable(kABMultiStringPropertyType);
            
            for (int i = 0; i < phoneCount; i++)
            {
                CFTypeRef cfNumber = ABMultiValueCopyValueAtIndex(phoneList, i);
                CFStringRef cfPhoneNumberLabel = ABMultiValueCopyLabelAtIndex(phoneList, i);
                CFStringRef localPhoneLable = ABAddressBookCopyLocalizedLabel(cfPhoneNumberLabel);
                
                ABMultiValueAddValueAndLabel(phoneLabel,(CFStringRef)cfNumber, localPhoneLable , NULL);
                if (cfNumber)
                {
                    CFRelease(cfNumber);
                }
                if (cfPhoneNumberLabel)
                {
                    CFRelease(cfPhoneNumberLabel);
                }
                if (localPhoneLable)
                {
                    CFRelease(localPhoneLable);
                }
            }
            
            ABMultiValueInsertValueAndLabelAtIndex(phoneLabel,(__bridge CFStringRef)addNum, kABPersonPhoneMobileLabel,phoneCount, NULL);
            
            ABRecordSetValue(onePerson, kABPersonPhoneProperty, phoneLabel, &anError);
            if (phoneList)
            {
                CFRelease(phoneList);
            }
            if (phoneLabel)
            {
                CFRelease(phoneLabel);
            }
            
            [self createEditContactViewWithPerson:onePerson];
        }
}

- (void)createEditContactViewWithPerson:(ABRecordRef)onePerson{
    _personViewController = [[ABPersonViewController alloc] init];
    _personViewController.personViewDelegate = self;
    _personViewController.displayedPerson = onePerson;
    _personViewController.displayedProperties = [NSArray arrayWithObjects:
                                                     [NSNumber numberWithInt:kABPersonPhoneProperty],
                                                     nil];
    _personViewController.allowsEditing = YES;
    [_personViewController setEditing:YES];
    [self.navigationController pushViewController:_personViewController animated:YES];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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
        cell.contactNameLable.text = [aContact getContactFullName];
        cell.isLastCell = NO;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
            UIView *menuCellBackView = [[UIView alloc] initWithFrame:cell.frame];
            menuCellBackView.backgroundColor = [UIColor lightGrayColor];
            [cell setSelectedBackgroundView:menuCellBackView];
        }
        return cell;
    } else{
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
        }
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
            UIView *menuCellBackView = [[UIView alloc] initWithFrame:contactCell.frame];
            menuCellBackView.backgroundColor = [UIColor lightGrayColor];
            [contactCell setSelectedBackgroundView:menuCellBackView];
        }
        return contactCell;
    }
}

- (void)showContactDetailView:(ContactNode *)contactNodeInfo{
    ContactDetailViewController *contactDetailView = [[ContactDetailViewController alloc] initWithNibName:NSStringFromClass([ContactDetailViewController class]) bundle:nil];
    contactDetailView.contactNode = contactNodeInfo;
    contactDetailView.contactDetailType = ContactDetailViewTypeNormal;
    if (self.contactListType == ContactListTypeCall) {
        contactDetailView.conDetailShowType = ContactDetailShowType_call;
    }
    [self.navigationController pushViewController:contactDetailView animated:YES];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_searchTextField resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger index = indexPath.section;
    if (_isSearch) {
        T9ContactRecord *oneRecord = [_contactSearchList objectAtIndex:indexPath.row];
        ContactNode *aContact = [[ContactManager shareInstance] getOneContactByID:oneRecord.abRecordID];
        [self addNewPhoneNumToContact:aContact];
    } else {
        NSString *aKey = [_contactSectionKeyList objectAtIndex:index];
        NSArray *aList = [self.contactDataDict objectForKey:aKey];
        ContactNode *aContact = (ContactNode *)[aList objectAtIndex:indexPath.row];
        if (_contactListType == ContactListTypeSingleChoose) {
            [self addNewPhoneNumToContact:aContact];
        }
        if (_contactListType == ContactListTypeCall) {
            [self showContactDetailView:aContact];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_searchTextField resignFirstResponder];
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}

@end
