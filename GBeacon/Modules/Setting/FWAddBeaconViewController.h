//
//  FWAddBeaconViewController.h
//  FeasyBeacon
//
//  Created by ericj on 2017/10/19.
//  Copyright © 2017年 LIDONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBSDKPublicHeader.h"

/// 新增BeaconVC
@interface FWAddBeaconViewController : UIViewController

@property (nonatomic, copy) void(^completionHandler)(FBMutableBeacon *beacon);

- (instancetype)initWithModelIndex:(NSInteger) modelIndex configTxPowers:(NSArray *)txPowers;

@end
