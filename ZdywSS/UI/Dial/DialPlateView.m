//
//  DialPlateView.m
//  ZdywClient
//
//  Created by ddm on 5/21/14.
//  Copyright (c) 2014 ddm GuoLing. All rights reserved.
//

#import "DialPlateView.h"
#import "UIImage+Scale.h"

@implementation UILabel(PasterLab)

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

@end

@implementation DialPlateView

#pragma mark - LiftCycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib{
    [self commonInit];
    _isPutNumber = NO;
}

- (void)commonInit{
    _phoneBg.layer.shadowColor = [UIColor colorWithRed:215.0/255 green:215.0/255 blue:215.0/255 alpha:1.0].CGColor;
    _phoneBg.layer.shadowOffset = CGSizeMake(0, -1);
    _phoneBg.layer.shadowOpacity = 1.0;
    _phoneBg.layer.shadowRadius = 1.0;
    
    UIImage *normalImage = [[[UIImage imageNamed:@"dialplate_key_default"]
                             stretchableImageWithLeftCapWidth:32 topCapHeight:32] scaleToSize:CGSizeMake(330, 85)];
    UIImage *lightImage = [[[UIImage imageNamed:@"dialplate_key_light"]
                            stretchableImageWithLeftCapWidth:32 topCapHeight:32] scaleToSize:CGSizeMake(330, 85)];
    [_callContactBtn setTitle:@"呼叫" forState:UIControlStateHighlighted];
    [_callContactBtn setBackgroundImage:normalImage forState:UIControlStateNormal];
    [_callContactBtn setBackgroundImage:lightImage forState:UIControlStateHighlighted];
    [_callContactBtn addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    
    [_deleBtn setImage:[UIImage imageNamed:@"dialplate_key_dele"] forState:UIControlStateNormal];
    [_deleBtn setImage:[[UIImage imageNamed:@"dialplate_key_dele"] imageByApplyingAlpha:0.5] forState:UIControlStateHighlighted];
    UILongPressGestureRecognizer *longPressGr = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressDeleAction:)];
    [_deleBtn addGestureRecognizer:longPressGr];
    
    UILongPressGestureRecognizer *longPressLabGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressPhoneLableAction)];
    [_phoneLable setUserInteractionEnabled:YES];
    [_phoneLable addGestureRecognizer:longPressLabGr];
}

#pragma mark - PrivateMethod

- (void)copyNum{
    UIMenuController *pasteCopyMenuCtr = [UIMenuController sharedMenuController];
    [pasteCopyMenuCtr setMenuVisible:NO];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = _phoneLable.text;
}

- (void)pasteNumber{
    UIMenuController *pasteCopyMenuCtr = [UIMenuController sharedMenuController];
    [pasteCopyMenuCtr setMenuVisible:NO];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    //若粘贴板上的内容不为空，可以粘贴
    if (0 != [pasteboard.string length])
    {
        //获取粘贴板的内容
        NSString *numStr = [pasteboard.string stringByReplacingOccurrencesOfString:@" " withString:@""];
        _phoneLable.text = numStr;
    }
}

#pragma mark - DialAction

- (void)longPressDeleAction:(id)sender{
    if ([_phoneLable.text length]) {
        _phoneLable.text = @"";
        _phoneLable.text = @"请输入电话号码";
        _isPutNumber = NO;
        _phoneLable.textColor = [UIColor colorWithRed:225.0/255 green:225.0/255 blue:225.0/255 alpha:1.0];
        if (_dialPlateViewDelagate && [_dialPlateViewDelagate respondsToSelector:@selector(dialViewAction:dialPlateType:phoneLabel:)]) {
            [_dialPlateViewDelagate dialViewAction:12 dialPlateType:DialPlateType_DialDeleAll phoneLabel:_phoneLable.text];
        }
    }
}

- (void)longPressPhoneLableAction{
    UIMenuController *pasteCopyMenuController = [UIMenuController sharedMenuController];
    if (!pasteCopyMenuController.menuVisible) {
        [_phoneLable becomeFirstResponder];
        [_phoneLable canBecomeFirstResponder];
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"复制"
                                                          action:@selector(copyNum)];
        UIMenuItem *pasteItem = [[UIMenuItem alloc] initWithTitle:@"粘贴"
                                                           action:@selector(pasteNumber)];
        [pasteCopyMenuController setMenuItems:[NSArray arrayWithObjects:copyItem,pasteItem,nil]];
        pasteCopyMenuController.arrowDirection = UIMenuControllerArrowDown;
        [pasteCopyMenuController setTargetRect:_phoneLable.frame inView:[_phoneLable superview]];
        [pasteCopyMenuController setMenuVisible:YES];
    }
}

//拨号音
- (IBAction)playDialSound:(id)sender
{
    int dialSound = [[ZdywUtils getLocalIdDataValue:kDialSoundFlag] intValue];
    if (dialSound != 0)
    {
        [ZdywUtils playSystemSound];
    }
}

- (IBAction)buttonAction:(id)sender{
    UIButton *button = (UIButton *)sender;
    NSInteger bunttonIndex = button.tag - 100;
    switch (bunttonIndex) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
            if (_isPutNumber) {
                _phoneLable.text = [_phoneLable.text stringByAppendingString:[NSString stringWithFormat:@"%d",bunttonIndex]];
                NSLog(@"%@",_phoneLable.text);
            }else{
                _phoneLable.text = @"";
                _isPutNumber = YES;
                _phoneLable.textColor = [UIColor blackColor];
                _phoneLable.text = [_phoneLable.text stringByAppendingString:[NSString stringWithFormat:@"%d",bunttonIndex]];
            }
            if (_dialPlateViewDelagate && [_dialPlateViewDelagate respondsToSelector:@selector(dialViewAction:dialPlateType:phoneLabel:)]) {
                [_dialPlateViewDelagate dialViewAction:bunttonIndex dialPlateType:DialPlateType_DialNumber phoneLabel:_phoneLable.text];
            }
            break;
        case 10:{
            if (_isPutNumber) {
                _phoneLable.text = [_phoneLable.text stringByAppendingString:@"*"];
                NSLog(@"%@",_phoneLable.text);
            }else{
                _phoneLable.text = @"";
                _isPutNumber = YES;
                _phoneLable.textColor = [UIColor blackColor];
                _phoneLable.text = _phoneLable.text = [_phoneLable.text stringByAppendingString:@"*"];
            }
            if (_dialPlateViewDelagate && [_dialPlateViewDelagate respondsToSelector:@selector(dialViewAction:dialPlateType:phoneLabel:)]) {
                [_dialPlateViewDelagate dialViewAction:bunttonIndex dialPlateType:DialPlateType_DialNumber phoneLabel:nil];
            }
            break;
        }
        case 11:{
            if (_isPutNumber) {
                _phoneLable.text = [_phoneLable.text stringByAppendingString:@"#"];
                NSLog(@"%@",_phoneLable.text);
            }else{
                _phoneLable.text = @"";
                _isPutNumber = YES;
                _phoneLable.textColor = [UIColor blackColor];
                _phoneLable.text = _phoneLable.text = [_phoneLable.text stringByAppendingString:@"#"];
            }
            if (_dialPlateViewDelagate && [_dialPlateViewDelagate respondsToSelector:@selector(dialViewAction:dialPlateType:phoneLabel:)]) {
                [_dialPlateViewDelagate dialViewAction:bunttonIndex dialPlateType:DialPlateType_DialNumber phoneLabel:nil];
            }
            break;
        }
        case 12:{
            if (_isPutNumber) {
                if ([_phoneLable.text length]) {
                    _phoneLable.text = [_phoneLable.text substringToIndex:_phoneLable.text.length - 1];
                    if ([_phoneLable.text length] == 0) {
                        _isPutNumber = NO;
                        _phoneLable.textColor = [UIColor colorWithRed:225.0/255 green:225.0/255 blue:225.0/255 alpha:1.0];
                        _phoneLable.text = @"请输入电话号码";
                    }
                }else{
                    _isPutNumber = NO;
                    _phoneLable.textColor = [UIColor colorWithRed:225.0/255 green:225.0/255 blue:225.0/255 alpha:1.0];
                    _phoneLable.text = @"请输入电话号码";
                }
                if (_dialPlateViewDelagate && [_dialPlateViewDelagate respondsToSelector:@selector(dialViewAction:dialPlateType:phoneLabel:)]) {
                    [_dialPlateViewDelagate dialViewAction:bunttonIndex dialPlateType:DialPlateType_DialDeleOne phoneLabel:_phoneLable.text];
                }
            }
            break;
        }
        case 13:{
            if (_dialPlateViewDelagate && [_dialPlateViewDelagate respondsToSelector:@selector(dialViewAction:dialPlateType:phoneLabel:)]) {
                [_dialPlateViewDelagate dialViewAction:bunttonIndex dialPlateType:DialPlateType_DialCallUser phoneLabel:_phoneLable.text];
            }
            break;
        }
        case 14:{
            if (_dialPlateViewDelagate && [_dialPlateViewDelagate respondsToSelector:@selector(dialViewAction:dialPlateType:phoneLabel:)]) {
                [_dialPlateViewDelagate dialViewAction:bunttonIndex dialPlateType:DialPlateType_DialFlod phoneLabel:_phoneLable.text];
            }
            break;
        }
        default:
            break;
    }
}

@end
