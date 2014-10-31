//
//  MonthBagDetailViewController.m
//  ZdywClient
//
//  Created by ddm on 6/24/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import "MonthBagDetailViewController.h"
#import "MonthBagModel.h"
#import "MonthBagCell.h"

@interface MonthBagDetailViewController ()

@end

@implementation MonthBagDetailViewController

#pragma mark - LiftCycle

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
    // Do any additional setup after loading the view from its nib.
    self.title = @"套餐详情";
    [_monthBagTable setDataSource:self];
    [_monthBagTable setDelegate:self];
    [_monthBagTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PrivateMethod

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 96.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_monthBagArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MonthBagCell  *monthBagCell = (MonthBagCell*)[tableView dequeueReusableCellWithIdentifier:@"monthBagCell"];
    if (monthBagCell == nil) {
        monthBagCell = [[MonthBagCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"monthBagCell"];
    }
    monthBagCell.selectionStyle = UITableViewCellSelectionStyleNone;
    monthBagCell.monthBagModel = [[MonthBagModel alloc] initWithDict:[_monthBagArray objectAtIndex:(_monthBagArray.count - indexPath.row - 1)]];
    return monthBagCell;
}

@end
