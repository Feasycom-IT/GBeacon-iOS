//
//  FBConfiguration.h
//  FeasyBeacon
//
//  Created by LiDong on 2021/4/29.
//  Copyright © 2021 LIDONG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBRange : NSObject
/// 最小值
@property (nonatomic, assign, readonly) int minValue;
/// 最大值
@property (nonatomic, assign, readonly) int maxValue;
@end

/// 蓝牙模块配置参数的取值范围
@interface FBConfiguration : NSObject

/// 模块型号的编号
@property (nonatomic, assign, readonly) int modelIndex;
/// 模块型号的名称
@property (nonatomic, copy, readonly) NSString *modelName;
/// TxPower信号强度的的可用值数组
@property (nonatomic, copy, readonly) NSArray *txPowers;
/// Coded-phy配置
@property (nonatomic, copy) NSArray *phys;
/// 默认广播间隔取值范围
@property (nonatomic, strong, readonly) FBRange *intervalRange;
/// Gsensor后广播间隔取值范围
@property (nonatomic, strong, readonly) FBRange *gsensorIntervalRange;
/// Gsensor后广播持续时间取值范围
@property (nonatomic, strong, readonly) FBRange *gsensorDurationRange;
/// Gsensor的灵敏度取值范围
@property (nonatomic, strong, readonly) FBRange *gsensorSensitivityRange;
/// 按键后广播间隔取值范围
@property (nonatomic, strong, readonly) FBRange *keyIntervalRange;
/// 按键后广播持续时间取值范围
@property (nonatomic, strong, readonly) FBRange *keyDurationRange;

@end

NS_ASSUME_NONNULL_END
