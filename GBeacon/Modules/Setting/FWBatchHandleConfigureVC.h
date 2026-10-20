//
//  FWBatchHandleConfigureVC.h
//  FeasyBeacon
//
//  Created by chenchanghua on 2022/3/23.
//  Copyright © 2022 LIDONG. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FBPeripheralManager, FBConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface FWBatchHandleConfigureVC : UIViewController

- (instancetype)initWithBeaconManager:(FBPeripheralManager *)beaconManager configurationRange:(FBConfiguration *)configuration;

@end

NS_ASSUME_NONNULL_END
