//
//  UIImage+Scale.h
//  ZdywClient
//
//  Created by ddm on 6/11/14.
//  Copyright (c) 2014 Guoling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Scale)

-(UIImage*)scaleToSize:(CGSize)size;

- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha;//设置图片透明度

+ (UIImage *)createImageWithColor:(UIColor *)color;

@end
