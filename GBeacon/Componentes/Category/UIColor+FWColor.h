//
//  UIColor+FWColor.h
//  FeasyBeacon
//
//  Created by ericj on 2018/5/24.
//  Copyright © 2018年 LIDONG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (FWColor)

// 颜色转换：iOS中（以#开头）十六进制的颜色转换为UIColor(RGB)
+ (UIColor *) colorWithHexString: (NSString *)color;

@end
