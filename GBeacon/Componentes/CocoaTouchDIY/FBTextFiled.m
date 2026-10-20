//
//  FBTextFiled.m
//  FeasyBeacon
//
//  Created by chenchanghua on 2022/4/2.
//  Copyright © 2022 Feasycom. All rights reserved.
//

#import "FBTextFiled.h"

@interface FBTextFiled ()

@end

@implementation FBTextFiled

- (instancetype)init {
    if (self = [super init]) {
        self.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController) {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    return NO;
}

@end
