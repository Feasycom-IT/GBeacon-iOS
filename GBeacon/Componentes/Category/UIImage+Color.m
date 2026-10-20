//
//  UIImage+Color.m
//  Char-Broil Thermometer
//
//  Created by LiDong on 2019/4/22.
//  Copyright © 2019年 Feasycom. All rights reserved.
//

#import "UIImage+Color.h"

@implementation UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color borderColor:(UIColor *)borderColor size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    
    const CGRect rect = (CGRect){ 0, 0, size.width, size.height };
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextStrokeRectWithWidth(context, rect, 1.f);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextRestoreGState(context);
    
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color borderColor:(UIColor *)borderColor size:(CGSize)size radius:(CGFloat)radius {
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    const CGFloat maxX = size.width;
    const CGFloat maxY = size.height;
    const CGFloat midX = maxX * 0.5;
    const CGFloat midY = maxY * 0.5;
    
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0.f, midY);
    CGContextAddArcToPoint(context, 0.f, 0.f, midX, 0.f, radius);
    CGContextAddArcToPoint(context, maxX, 0.f, maxX, midY, radius);
    CGContextAddArcToPoint(context, maxX, maxY, midX, maxY, radius);
    CGContextAddArcToPoint(context, 0.f, maxY, 0.f, midY, radius);
    CGContextClosePath(context);
    
    CGContextFillPath(context);
    CGContextStrokePath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextRestoreGState(context);
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
