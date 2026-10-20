//
//  FBBeacon.h
//  FeasyBeacon
//
//  Created by LiDong on 2021/6/26.
//  Copyright © 2021 LIDONG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kBeaconTypeIBeacon      @"iBeacon"
#define kBeaconTypeURL          @"URL"
#define kBeaconTypeUID          @"UID"
#define kBeaconTypeTML          @"TLM"
#define kBeaconTypeAltBeacon    @"AltBeacon"
#define kBeaconDefaultURL       @"https://www.feasycom.com"

typedef enum __FBBeaconType : char {
    FBBeaconTypeUnknown = 0,
    FBBeaconTypeIBeacon = 1,
    FBBeaconTypeURL = 2,
    FBBeaconTypeUID = 3,
    FBBeaconTypeAltBeacon = 4,
    FBBeaconTypeTLM = 5,
} FBBeaconType;

typedef enum __FBProximityType: NSUInteger {
    FBProximityTypeUnknown,
    FBProximityTypeImmediate,
    FBProximityTypeNear,
    FBProximityTypeFar
} FBProximityType;

/// 标准Beacon广播（iBeacon、UID、URL、TLM、ATLBeacon）
@interface FBBeacon : NSObject

/// 类型（iBeacon、URL、UID、TLM、AltBeacon）
@property (nonatomic, assign, readonly) FBBeaconType type;
/// 两个 Beacon 的相等判断
- (BOOL)isEqual:(FBBeacon *)otherBeacon;

#pragma mark - iBeacon

/// iBeacon
@property (nonatomic, strong, readonly, nullable) NSString *proximityUUID;
/// iBeacon
@property (nonatomic, assign, readonly) int major;
/// iBeacon
@property (nonatomic, assign, readonly) int minor;
/// iBeacon
@property (nonatomic, assign, readonly) FBProximityType proximityType;
/// iBeacon
@property (nonatomic, assign, readonly) double accuracy;

- (BOOL)updateIBeaconAccuracy:(double)accuracy proximityType:(FBProximityType)proximityType;

#pragma mark - UID<0x00>

/// UID<0x00>
@property (nonatomic, assign, readonly) NSInteger calibratedTxPowerAt0m_uid;
/// UID<0x00>
@property (nonatomic, strong, readonly, nullable) NSString *namespaceString;
/// UID<0x00>
@property (nonatomic, strong, readonly, nullable) NSString *instanceString;
/// UID<0x00>
@property (nonatomic, strong, readonly, nullable) NSString *reservedString;

#pragma mark - URL<0x10>

/// URL<0x10>
@property (nonatomic, assign, readonly) NSInteger calibratedTxPowerAt0m_url;
/// URL<0x10>
@property (nonatomic, strong, readonly, nullable) NSString *URLString;

#pragma mark - TLM<0x20>

/// TLM<0x20>
@property (nonatomic, assign, readonly) NSInteger tlmVersion;
/// TLM<0x20>
@property (nonatomic, assign, readonly) NSInteger batteryVoltage;
/// TLM<0x20>
@property (nonatomic, assign, readonly) double beaconTemperature;
/// TLM<0x20>
@property (nonatomic, assign, readonly) NSInteger advertisingPDUCount;
/// TLM<0x20>
@property (nonatomic, assign, readonly) NSInteger timeSincePowerOnOrReboot;

#pragma mark - AltBeacon<0xBEAC>

/// AltBeacon<0xBEAC>
@property (nonatomic, strong, readonly, nullable) NSString *manufacturerID;
/// AltBeacon<0xBEAC>
@property (nonatomic, strong, readonly, nullable) NSString *IDString;
/// AltBeacon<0xBEAC>
@property (nonatomic, assign, readonly) NSInteger calibratedTxPowerAt1m_alt;
/// AltBeacon<0xBEAC>
@property (nonatomic, strong, readonly, nullable) NSString *manufacturerReservedString;

@end

NS_ASSUME_NONNULL_END
