//
//  ContactDetailViewController.m
//  ZdywClient
//
//  Created by ddm on 6/11/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "ContactDetailViewController.h"
#import "ContactManager.h"
#import "ContactDetailHeadView.h"
#import "ContactDetailFooterView.h"
#import "ZdywBaseNavigationViewController.h"

@interface ContactDetailViewController (){
    NSInteger _contactID;
    NSInteger _phoneCount;
    NSArray  *_phoneArray;
}

@property (nonatomic, strong) ContactDetailHeadView     *contactDetailView;
@property (nonatomic, strong) ContactDetailFooterView   *contactDetailFooterView;

@end

@implementation ContactDetailViewController

#pragma mark - liftCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    // Do any additional setup after loading the view.
    _contactDetailView = [[ContactDetailHeadView alloc] initWithFrame:CGRectMake(0, 0, 320, 137)];
    //[_contactDetailView setBackgroundColor:[UIColor colorWithRed:25.0/255 green:151.0/255 blue:216.0/255 alpha:1.0]];
    [_contactDetailView setBackgroundColor:[ZdywCommonFun getAppConfigureColorWithKey:kZdywDataKeyZdywFontColor]];
    _contactDetailView.nameLable.text = [self nameForContact];
    _contactDetailView.officeLable.text = [self officeNameForContact];
    _contactDetailView.positionNameLable.text = _contactNode.positionName;
    [_contactDetailView updateUI];
    _contactDetailTableView.tableHeaderView = _contactDetailView;
    
    _contactDetailFooterView = [[ContactDetailFooterView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    _contactDetailFooterView.callDetailList = _recordMegerNode.lastRecordList;
    _contactDetailTableView.tableFooterView = _contactDetailFooterView;
    
    [_contactDetailTableView setDataSource:self];
    [_contactDetailTableView setDelegate:self];
    [_contactDetailTableView setSeparatorColor:[UIColor clearColor]];
    [self initData];
    [self addObservers];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    if (_contactDetailType == ContactDetailViewTypeNormal) {
        self.title = @"联系人详情";
    } else {
        self.title = @"通话详情";
    }
    if (_contactDetailType == ContactDetailViewTypeUnKnowCall) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addNewContact)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editContact)];
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

#pragma mark - Observers

- (void)addObservers{
    //监听新的通话记录
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newCallRecordCreate:)
                                                 name:@"CallRecordRefresh"
                                               object:nil];
    //添加联系人变化通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contactDataChanged)
                                                 name:kNotifyContactDataChanged
                                               object:nil];
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CallRecordRefresh" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifyContactDataChanged object:nil];
}

#pragma mark - PrivateMethod

- (void)contactDataChanged
{
    [self performSelectorOnMainThread:@selector(contactDataChangedInMain) withObject:nil waitUntilDone:YES];
}

- (void)contactDataChangedInMain{
    if (self.contactDetailType != ContactDetailViewTypeUnKnowCall)  //若是已知联系人，重新根据联系人ID获取联系人数据
    {
        self.contactNode = [[ContactManager shareInstance] getOneContactByID:_contactNode.contactID];
    }
    else  //未知联系人，根据电话号码获取联系人数据
    {
        self.contactNode = [[ContactManager shareInstance] contactInfoWithPhone:self.recordMegerNode.phoneNumber];
    }
    if (nil != self.contactNode && self.contactNode.contactID != kInValidContactID)
    {
        self.contactDetailType = ContactDetailViewTypeCall;
        ABRecordRef personRecord = [[ContactManager shareInstance] getOneABRecordWithID:self.contactNode.contactID ];
        if (NULL != personRecord)
        {
            _phoneArray = (__bridge NSArray *)(ABRecordCopyValue(personRecord,kABPersonPhoneProperty));
            _phoneCount = ABMultiValueGetCount((__bridge ABMultiValueRef)(_phoneArray));
        }
    }
    _contactDetailView.nameLable.text = [self nameForContact];
    _contactDetailView.officeLable.text = [self officeNameForContact];
    _contactDetailView.positionNameLable.text = _contactNode.positionName;
    [_contactDetailView updateUI];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editContact)];
    [self.contactDetailTableView reloadData];
}

- (void)addNewContact{
    ABRecordRef aContact = ABPersonCreate();
    CFErrorRef anError = NULL;
    ABMutableMultiValueRef phoneLabe = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(phoneLabe,(__bridge CFStringRef)self.recordMegerNode.phoneNumber, kABPersonPhoneMobileLabel, NULL);
    ABRecordSetValue(aContact, kABPersonPhoneProperty, phoneLabe, &anError);
    _myNewPersonViewController = [[ABNewPersonViewController alloc] init];
    _myNewPersonViewController.newPersonViewDelegate = self;
    _myNewPersonViewController.displayedPerson = aContact;
    [_myNewPersonViewController.navigationController setNavigationBarHidden:NO];
    ZdywBaseNavigationViewController *aNav = [[ZdywBaseNavigationViewController alloc] initWithRootViewController:_myNewPersonViewController];
    [self.navigationController presentModalViewController:aNav animated:YES];
}

- (void)newCallRecordCreate:(NSNotification *)notic{
    ContactRecordNode *oneRecord = [notic.userInfo objectForKey:@"Record"];
    if (nil != oneRecord)
    {
        [self performSelectorOnMainThread:@selector(newCallRecordCreateInMain:)
                               withObject:oneRecord
                            waitUntilDone:YES];
    }
}

- (void)newCallRecordCreateInMain:(ContactRecordNode *)oneRecord{
    @synchronized(self.recordMegerNode)
    {
        if (self.recordMegerNode)
        {
            BOOL ret = NO;
            if (_recordMegerNode.contactID == self.recordMegerNode.contactID)
            {
                ret = YES;
            }
            else if([oneRecord.phoneNum isEqualToString:oneRecord.phoneNum])
            {
                ret = YES;
            }
            if (ret)
            {
                [self.recordMegerNode.lastRecordList insertObject:oneRecord atIndex:0];
                self.recordMegerNode.phoneNumber = oneRecord.phoneNum;
                _contactDetailFooterView.callDetailList = self.recordMegerNode.lastRecordList;
            }
        }
    }
}

- (void)initData{
    if (self.contactNode != nil&& self.contactNode.contactID != kInValidContactID)
    {
        _contactID = self.contactNode.contactID;
        ABRecordRef personRecord = [[ContactManager shareInstance] getOneABRecordWithID:self.contactNode.contactID];
        if (NULL != personRecord)
        {
            _phoneArray = (__bridge NSArray *)(ABRecordCopyValue(personRecord,kABPersonPhoneProperty));
            _phoneCount = ABMultiValueGetCount((__bridge ABMultiValueRef)(_phoneArray));
        }
    }
}

//获取联系人名称
- (NSString *)nameForContact
{
    NSString *nameStr = @"";
    if (self.contactDetailType == ContactDetailViewTypeUnKnowCall) //未知联系人的通话记录，取电话
    {
        nameStr = @"陌生联系人";
    }
    else //已知联系人取联系人名称
    {
        nameStr = [NSString stringWithFormat:@"%@",[self.contactNode getContactFullName]];
    }
    return nameStr;
}

//获取公司部门职位
- (NSString *)officeNameForContact{
    if (self.contactDetailType == ContactDetailViewTypeUnKnowCall) {
        return nil;
    } else {
        NSString *officeNameStr = [NSString stringWithFormat:@"%@%@",_contactNode.companyName?_contactNode.companyName:@"",_contactNode.departmentName?_contactNode.departmentName:@""];
        return officeNameStr;
    }
}

- (void)editContact{
    if (nil != self.contactNode && kInValidContactID != self.contactNode.contactID)
    {
        
        ABRecordRef onePerson = [[ContactManager shareInstance] getOneABRecordWithID:self.contactNode.contactID];
        if (NULL != onePerson)
        {
            [self createEditContactViewWithPerson:onePerson];
        }
    }
}

- (void)createEditContactViewWithPerson:(ABRecordRef)onePerson{
    _personViewController = [[ABPersonViewController alloc] init];
    self.personViewController.personViewDelegate = self;
    self.personViewController.displayedPerson = onePerson;
    self.personViewController.displayedProperties = [NSArray arrayWithObjects:
                                                     [NSNumber numberWithInt:kABPersonPhoneProperty],
                                                     nil];
    self.personViewController.allowsEditing = YES;
    [self.personViewController setEditing:YES];
    [self.navigationController pushViewController:self.personViewController animated:YES];
}

#pragma mark - dealPhoneNum

//处理电话号码
- (NSString *)phoneNumberAfterDeal:(NSString *)aStr
{
    NSMutableString *rStr = [NSMutableString stringWithString:@""];
    for (int i = 0; i < [aStr length]; ++i)
    {
        [rStr appendString:[aStr substringWithRange:NSMakeRange(i, 1)]];
        //最开始3个字符插入一个'-'
        if ([rStr length] == 3)
        {
            [rStr appendString:@"-"];
        }
        //后面每4个字符插入一个'-'
        if (i > 2 && ((i -2) % 4) == 0)
        {
            [rStr appendString:@"-"];
        }
    }
    //去掉末尾的"-"
    if ([rStr hasSuffix:@"-"])
    {
        [rStr deleteCharactersInRange:NSMakeRange([rStr length] - 1, 1)];
    }
    return rStr;
}

//获取联系人号码归属地
- (NSString *)phoneAttributionForPhone:(NSString *)phoneNumber
{
    NSString *attStr = [[ContactManager shareInstance] phoneAttributionWithPhoneNumber:phoneNumber
                                                                           countryCode:[ZdywUtils getLocalStringDataValue:kCurrentCountryCode]];
    if (0 == [attStr length])
    {
        attStr = @"未知地区";
    }
    return attStr;
}

#pragma mark - personViewDelegate
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_contactDetailType == ContactDetailViewTypeUnKnowCall) {
        return 1;
    }
    return _phoneCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ContactDetailCell *contactDetailCell = (ContactDetailCell*)[tableView dequeueReusableCellWithIdentifier:@"contactDetailCell"];
    if (contactDetailCell == nil) {
        contactDetailCell = [[ContactDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"contactDetailCell"];
    }
    if (_conDetailShowType == ContactDetailShowType_call) {
        [contactDetailCell.callPhoneBtn setHidden:YES];
    }
    [contactDetailCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (_contactDetailType == ContactDetailViewTypeUnKnowCall) {
        contactDetailCell.phoneLable.text = self.recordMegerNode.phoneNumber;
        contactDetailCell.phoneAreaLable.text = [self phoneAttributionForPhone:self.recordMegerNode.phoneNumber];
        contactDetailCell.callNumber = self.recordMegerNode.phoneNumber;
        contactDetailCell.phoneOperatorsLable.text = [[ContactManager shareInstance]PhoneOperatorsWithPhoneNumber:self.recordMegerNode.phoneNumber];
    } else{
        if (0 < _phoneCount && indexPath.row < _phoneCount)
        {
            CFTypeRef cfNumber = ABMultiValueCopyValueAtIndex((__bridge ABMultiValueRef)(_phoneArray), indexPath.row);
            CFStringRef cfPhoneNumberLabel = ABMultiValueCopyLabelAtIndex((__bridge ABMultiValueRef)(_phoneArray), indexPath.row);
            CFStringRef localPhoneLable = ABAddressBookCopyLocalizedLabel(cfPhoneNumberLabel);
            
            NSString *phoneNumberStr = (__bridge NSString*)cfNumber;
            contactDetailCell.phoneLable.text = [[ContactManager shareInstance] deleteCountryCodeFromPhoneNumber:(__bridge NSString*)cfNumber
                                                                                                     countryCode:[ ZdywUtils getLocalStringDataValue:kCurrentCountryCode]];;
            contactDetailCell.phoneAreaLable.text = [self phoneAttributionForPhone:phoneNumberStr];
            contactDetailCell.phoneTypeLable.text = (__bridge NSString *)localPhoneLable;
            contactDetailCell.callName = [self nameForContact];
            contactDetailCell.callContactID = _contactID;
            contactDetailCell.callNumber = phoneNumberStr;
            if ([contactDetailCell.phoneTypeLable.text isEqualToString:@"移动"]) {
                contactDetailCell.phoneTypeLable.text = @"移动电话";
            }
            contactDetailCell.phoneOperatorsLable.text = [[ContactManager shareInstance]PhoneOperatorsWithPhoneNumber:phoneNumberStr];
            
            if(cfNumber)
            {
                CFRelease(cfNumber);
            }
            if(cfPhoneNumberLabel)
            {
                CFRelease(cfPhoneNumberLabel);
            }
            if(localPhoneLable)
            {
                CFRelease(localPhoneLable);
            }
        }
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        UIView *menuCellBackView = [[UIView alloc] initWithFrame:contactDetailCell.frame];
        menuCellBackView.backgroundColor = [UIColor lightGrayColor];
        [contactDetailCell setSelectedBackgroundView:menuCellBackView];
    }
    return contactDetailCell;
}

#pragma mark - ABNewPersonViewControllerDelegate

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
    [ContactManager shareInstance].canLoadData = YES;
    self.myNewPersonViewController.newPersonViewDelegate = nil;
    [newPersonView.navigationController dismissModalViewControllerAnimated:YES];
}

@end
