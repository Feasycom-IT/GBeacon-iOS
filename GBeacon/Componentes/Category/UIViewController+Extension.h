//
//  UIViewController+Extension.h
//  FeasyBeacon
//
//  Created by LiDong on 2021/3/16.
//  Copyright © 2021 LIDONG. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Extension)

- (void)showAlertControllerWithTitle:(NSString *)title message:(nullable NSString *)message;
- (void)showAlertControllerWithTitle:(NSString *)title;
- (void)showAlertControllerAndPopWithTitle:(NSString *)title message:(nullable NSString *)message;
- (void)showAlertControllerAndPopWithTitle:(NSString *)title;
- (void)dismissPresentedViewControllerRecursively;

@end

NS_ASSUME_NONNULL_END
