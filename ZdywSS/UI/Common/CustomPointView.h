//
//  CustomPointView.h
//  WldhClient
//
//  Created by ddm on 3/28/14.
//  Copyright (c) 2014 guoling. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  CustomPointViewDelegate;

@interface CustomPointView : UIView

@property (nonatomic, assign) id <CustomPointViewDelegate> delegate;
@property (nonatomic, strong) UIView *tipView;
@property (nonatomic, strong) UILabel *tipLable;
@property (nonatomic, strong) UILabel *tipTitle;
@property (nonatomic, strong) UIImageView *tipBackgroundImageView;
@property (nonatomic, strong) UIButton  *backButton;
@property (nonatomic, strong) UIButton  *tipButton;
@property (nonatomic, strong) UILabel   *noTipLable;

@end

@protocol CustomPointViewDelegate <NSObject>

- (void)dismissCustomPointView;

@end

