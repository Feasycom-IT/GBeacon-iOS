//
//  UIView+FWGetCurrentVC.m
//  FeasyWIFI
//
//  Created by chenchanghua on 2021/12/7.
//  Copyright © 2021 Feasycom. All rights reserved.
//

#import "UIView+FWGetCurrentVC.h"

@implementation UIView (FWGetCurrentVC)

- (UIViewController *)viewController {
    UIResponder *responder = self.nextResponder;
    while (![responder isKindOfClass:[UIViewController class]] && responder != nil) {
        responder = responder.nextResponder;
    }
    return (UIViewController *)responder;
}

@end
