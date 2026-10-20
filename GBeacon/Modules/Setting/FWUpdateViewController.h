//
//  FWUpdateViewController.h
//  FeasyBeacon
//
//  Created by ericj on 2017/10/9.
//  Copyright © 2017年 LIDONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBSDKPublicHeader.h"

#define FWUpdateFilePathNotification @"FWUpdateFilePathNotification"

/// 空中升级VC
@interface FWUpdateViewController : UIViewController

- (instancetype)initWithPeripheralItem:(FBPeripheralItem *)peripheralItem PINCode:(NSString *)PINCode;

@end
