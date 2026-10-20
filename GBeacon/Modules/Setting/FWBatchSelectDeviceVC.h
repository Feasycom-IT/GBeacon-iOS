//
//  FWBatchSelectDeviceVC.h
//  FeasyBeacon
//
//  Created by chenchanghua on 2022/3/25.
//  Copyright © 2022 Feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 批量设置设备-未配置设备列表VC
@interface FWBatchSelectDeviceVC : UIViewController

- (instancetype)initWithBeaconConfigurated:(NSDictionary *)beaconConfiguratedDic filterModelType:(int)filterModelTypeIndex filterVersionMin:(NSString *)filterVersionMin filterVersionMax:(NSString *)filterVersionMax;

@end

NS_ASSUME_NONNULL_END
