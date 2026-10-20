//
//  UIImage+Color.h
//  Char-Broil Thermometer
//
//  Created by LiDong on 2019/4/22.
//  Copyright © 2019年 Feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color borderColor:(UIColor *)borderColor size:(CGSize)size;
+ (UIImage *)imageWithColor:(UIColor *)color borderColor:(UIColor *)borderColor size:(CGSize)size radius:(CGFloat)radius;

@end

NS_ASSUME_NONNULL_END
