//
//  ContactDetailHeadView.h
//  ZdywClient
//
//  Created by ddm on 6/16/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactDetailHeadView : UIView

@property (nonatomic, strong) UILabel *nameLable;
@property (nonatomic, strong) UILabel *officeLable;
@property (nonatomic, strong) UILabel *positionNameLable;

- (void)updateUI;

@end
