//
//  DialPlateView.h
//  ZdywClient
//
//  Created by ddm on 5/21/14.
//  Copyright (c) 2014 ddm GuoLing. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DialPlateType_DialNumber = 0,
    DialPlateType_DialDeleOne = 1,
    DialPlateType_DialDeleAll = 2,
    DialPlateType_DialFlod = 3,
    DialPlateType_DialCallUser = 4
} DialPlateType;

@protocol DialPlateViewDelegate;

@interface DialPlateView : UIView{
    BOOL _isPutNumber;
}

@property (nonatomic) id<DialPlateViewDelegate> dialPlateViewDelagate;
@property (nonatomic, strong) IBOutlet UIButton *deleBtn;
@property (nonatomic, strong) IBOutlet UILabel  *phoneLable;
@property (nonatomic, strong) IBOutlet UIButton *callContactBtn;
@property (nonatomic, strong) IBOutlet UIImageView *phoneBg;

-(IBAction)buttonAction:(id)sender;
-(IBAction)playDialSound:(id)sender;

@end

@protocol DialPlateViewDelegate <NSObject>

- (void)dialViewAction:(NSInteger)buttonIndex dialPlateType:(DialPlateType)dialPlateType phoneLabel:(NSString*)phoneLableText;

@end
