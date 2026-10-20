//
//  UIViewController+Extension.m
//  FeasyBeacon
//
//  Created by LiDong on 2021/3/16.
//  Copyright © 2021 LIDONG. All rights reserved.
//

#import "UIViewController+Extension.h"

@implementation UIViewController (Extension)

- (void)showAlertControllerWithTitle:(NSString *)title message:(nullable NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:OKAction];
    [self.navigationController presentViewController:alertController animated:YES completion:NULL];
}

- (void)showAlertControllerWithTitle:(NSString *)title {
    [self showAlertControllerWithTitle:title message:nil];
}

- (void)showAlertControllerAndPopWithTitle:(NSString *)title message:(nullable NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    __weak __typeof(self) weakSelf = self;
    
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    [alertController addAction:OKAction];
    [self.navigationController presentViewController:alertController animated:YES completion:NULL];
}

- (void)showAlertControllerAndPopWithTitle:(NSString *)title {
    [self showAlertControllerAndPopWithTitle:title message:nil];
}

- (void)dismissPresentedViewControllerRecursively {
    UIViewController *presentedViewController = [self presentedViewController];
    
    if (presentedViewController) {
        [presentedViewController dismissPresentedViewControllerRecursively];
        [presentedViewController dismissViewControllerAnimated:NO completion:NULL];
    }
}

@end
