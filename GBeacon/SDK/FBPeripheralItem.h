//
//  FBPeripheralItem.h
//  FeasyBeacon
//
//  Created by LiDong on 2021/6/15.
//  Copyright © 2021 LIDONG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBBeacon.h"

NS_ASSUME_NONNULL_BEGIN

/// 搜索到的蓝牙外设对象
@interface FBPeripheralItem : NSObject

#pragma mark - 设备基本信息
/// 是否可建立蓝牙连接
@property (nonatomic, assign, readonly, getter = isConnectable) BOOL connectable;
/// 本地名字
@property (nonatomic, strong, readonly, nullable) NSString *name;
/// 唯一标识
@property (nonatomic, strong, readonly, nullable) NSString *UUID;
/// 信号强度
@property (nonatomic, assign, readonly) int RSSI;
/// 广播包里面的名字
@property (nonatomic, strong, readonly, nullable) NSString *advertisingName;
/// 广播包里面的服务UUID
@property (nonatomic, strong, readonly, nullable) NSArray *serviceUUIDs;
/// 最新广播的时间戳
@property (nonatomic, assign, readonly) NSTimeInterval advertisementTimestamp;
/// 广播间隔时间数组
@property (nonatomic, strong, readonly, nullable) NSMutableArray *advertisementSpaceTimestampArray;
/// 广播频率（可根据广播间隔时间数组‘advertisementSpaceTimestampArray’按照App层算法另行估算）
@property (nonatomic, assign, readonly) NSTimeInterval advertisementRate;
/// 用于显示的名字，优先取advertisingName，若advertisingName长度为0则取name
@property (nonatomic, copy, readonly) NSString *displayedName;

#pragma mark - Beacon设备信息
/// 设备是否为Beacon设备
@property (nonatomic, assign, readonly, getter = isBeaconMoudle) BOOL beaconMoudle;
/// 设备模块类型编号
@property (nonatomic, assign, readonly) int modelIndex;
/// 设备MAC地址
@property (nonatomic, strong, readonly, nullable) NSString *macAddress;
/// 取MAC地址后6位
@property (nonatomic, strong, readonly, nullable) NSString *nameSuffix;
/// 设备固件版本号
@property (nonatomic, strong, readonly, nullable) NSString *firmwareVersion;
/// 设备电量
@property (nonatomic, assign, readonly) int quantityOfElectricity;
/// 设备是否包含PIN码（可连接但需要密码）
@property (nonatomic, assign, readonly) BOOL hasPINCode;
/// 设备是否包含NFC
@property (nonatomic, assign, readonly) BOOL hasNFC;
/// 设备是否包含LongRange125kbps广播
@property (nonatomic, assign, readonly) BOOL hasLongRange;
/// 设备是否包含LED
@property (nonatomic, assign, readonly) BOOL hasLED;
/// 设备是否包含蜂鸣器
@property (nonatomic, assign, readonly) BOOL hasBuzzer;
/// 设备是否包含Gsensor
@property (nonatomic, assign, readonly) BOOL hasGsensor;
/// 设备是否包含按键
@property (nonatomic, assign, readonly) BOOL hasKey;

#pragma mark - 标准Beacon广播
/// 标准Beacon广播（iBeacon、UID、URL、TLM、ATLBeacon）数组
@property (nonatomic, strong, readonly, nullable) NSMutableArray<FBBeacon *> *beacons;
/// 最新的标准Beacon广播（iBeacon、UID、URL、TLM、ATLBeacon）
@property (nonatomic, strong, readonly, nullable) FBBeacon *lastestBeacon;

#pragma mark - 自定义广播（e.g 传感器信息）
/// 包含温湿度广播
@property (nonatomic, assign, readonly, getter = isSensor) BOOL sensor;
/// 温度
@property (nonatomic, strong, readonly) NSString *temperature;
/// 湿度
@property (nonatomic, strong, readonly) NSString *humidity;

/// 包含G-Sensor广播
@property (nonatomic, assign, readonly, getter = isGSensor) BOOL gSensor;
/// G-Sensor采样率（0:1HZ、1:10HZ、2:25HZ、3:50HZ、4:100HZ）
@property (nonatomic, assign, readonly) uint8_t samplingRate;
/// G-Sensor量程（0:-2~+2、1:-4~+4、2:-8~+8、3:-16~+16）
@property (nonatomic, assign, readonly) uint8_t fullScale;
/// G-Sensor触发阙值（单位：0.1g）
@property (nonatomic, assign, readonly) uint8_t motionThreshold;
/// G-Sensor X轴原始数据
@property (nonatomic, assign, readonly) int16_t xAxisRaw;
/// G-Sensor Y轴原始数据
@property (nonatomic, assign, readonly) int16_t yAxisRaw;
/// G-Sensor Z轴原始数据
@property (nonatomic, assign, readonly) int16_t zAxisRaw;

#pragma mark - 通讯模块
/// 蓝牙外设通信是否已经就绪（已获取到设备的读、写特征，并已打开读特征）
@property (nonatomic, assign, readonly, getter = isGattReady) BOOL gattReady;
/// 写数据时每包数据的间隔，单位为秒，支持的最小值为0.01
@property (nonatomic, assign) NSTimeInterval writeInterval;
/// 指定发送数据的特征UUID
@property (nonatomic, strong) NSString *writeCharacteristicUUID;
/// 发送数据带不带响应
@property (nonatomic, assign) BOOL writeWithoutResponse;

/// 是否可以写数据
- (BOOL)isWritable;

@end

NS_ASSUME_NONNULL_END
