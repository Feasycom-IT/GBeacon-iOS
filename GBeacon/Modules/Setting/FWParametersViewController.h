//
//  FWParametersViewController.h
//  FeasyBeacon
//
//  Created by ericj on 2017/7/26.
//  Copyright © 2017年 LIDONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBSDKPublicHeader.h"

/// 设置-设备配置主界面VC
@interface FWParametersViewController : UITableViewController

- (id)initWithPeripheralItem:(FBPeripheralItem *)peripheralItem PINCode:(NSString *)PINCode;

@end
