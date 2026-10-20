//
//  FBMutableBeacon.h
//  FeasyBeacon
//
//  Created by LiDong on 2021/6/26.
//  Copyright © 2021 LIDONG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBBeacon.h"

NS_ASSUME_NONNULL_BEGIN

/// 抽象出来的Beacon对象（配置用）
@interface FBMutableBeacon : NSObject

/// 类型（iBeacon、URL、UID、TLM、AltBeacon）
@property (nonatomic, assign) FBBeaconType type;
/// 是否开启广播
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) NSUInteger numberOfParameters;

/// 用于支持phy功能的模块（URL、UID、AltBeacon）
@property (nonatomic, assign) int iPhy;
@property (nonatomic, assign) int iInterval;
@property (nonatomic, strong, nullable) NSString *txPower;

/// iBeacon
@property (nonatomic, strong, nullable) NSString *proximityUUID;
/// iBeacon
@property (nonatomic, assign) int major;
/// iBeacon
@property (nonatomic, assign) int minor;
/// iBeacon
@property (nonatomic, assign) int calibratedTxPowerAt1m_iBeacon;

/// URL
@property (nonatomic, strong, nullable) NSString *URLString;
/// URL
@property (nonatomic, assign) int calibratedTxPowerAt0m_url;

/// UID
@property (nonatomic, strong, nullable) NSString *namespaceString;
/// UID
@property (nonatomic, strong, nullable) NSString *instanceString;
/// UID
@property (nonatomic, strong, nullable) NSString *reservedString;
/// UID
@property (nonatomic, assign) int calibratedTxPowerAt0m_uid;

/// AltBeacon
@property (nonatomic, strong, nullable) NSString *IDString1;
/// AltBeacon
@property (nonatomic, strong, nullable) NSString *IDString2;
/// AltBeacon
@property (nonatomic, strong, nullable) NSString *IDString3;
/// AltBeacon
@property (nonatomic, assign) int manufacturerID;
/// AltBeacon
@property (nonatomic, strong, nullable) NSString *manufacturerReservedString;
/// AltBeacon
@property (nonatomic, assign) int calibratedTxPowerAt1m_alt;

@end

NS_ASSUME_NONNULL_END
