//
//  FBBluetoothBrowser.h
//  FeasyBeacon
//
//  Created by LiDong on 2021/6/15.
//  Copyright © 2021 LIDONG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "FBPeripheralItem.h"
#import "FBFilter.h"

@class FBBluetoothBrowser;

NS_ASSUME_NONNULL_BEGIN

@protocol FBBluetoothBrowserDelegate <NSObject>

@required
/// 已经完成新外设的添加（外设数组'peripheralItems'中已经添加此外设）
- (void)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser didAddPeripheralItem:(FBPeripheralItem *)peripheralItem;
/// 外设数组'peripheralItems'整体发生改变（比如调用sortByRSSI、startScanning、startScanningWithServices:方法）
- (void)bluetoothBrowserDidUpdatePeripheralItems:(FBBluetoothBrowser *)bluetoothBrowser;

@optional
/// 中心蓝牙状态发生改变
- (void)bluetoothBrowserDidChangeState:(FBBluetoothBrowser *)bluetoothBrowser;
/// 是否添加新外设'peripheralItem'
- (BOOL)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser shouldAddPeripheralItem:(FBPeripheralItem *)peripheralItem;
/// 外设数组'peripheralItems'中的某个外设'peripheralItem'的本地名字发生改变
- (void)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser didUpdatePeripheralItemName:(FBPeripheralItem *)peripheralItem;
/// 外设数组'peripheralItems'中的某个外设'peripheralItem'广播包里的名字发生改变
- (void)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser didUpdatePeripheralItemAdvertisingName:(FBPeripheralItem *)peripheralItem;
/// 外设数组'peripheralItems'中的某个外设'peripheralItem'信号强度发生改变
- (void)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser didUpdatePeripheralItemRSSI:(FBPeripheralItem *)peripheralItem;
@end

typedef enum __FBBluetoothBrowserType : char {
    FBBluetoothBrowserTypeBeacon, // 标准Beacon广播（iBeacon、UID、URL、TLM、ATLBeacon）
    FBBluetoothBrowserTypeSensor, // 自定义广播（e.g 传感器数据）
    FBBluetoothBrowserTypeSetting // Beacon模块
} FBBluetoothBrowserType;

/// 用来搜索蓝牙外设（包括普通蓝牙和传感器）、Beacon广播
@interface FBBluetoothBrowser : NSObject

/// 外设数组'peripheralItems'中只放置一种类型的设备
@property (nonatomic, readonly) FBBluetoothBrowserType type;
/// 当前的过滤器
@property (nonatomic, readonly, strong, nonnull) FBFilter *filter;
/// 中心蓝牙的状态
@property (nonatomic, readonly, assign) CBManagerState state;
/// 外设数组（调用startScanning、startScanningWithServices:方法后，此属性值会清空）
@property (nonatomic, readonly, strong, nonnull) NSArray<FBPeripheralItem *> *peripheralItems;
/// 已建立蓝牙连接的外设（调用startScanning、startScanningWithServices:方法后，此属性值会清空）
@property (nonatomic, readonly, strong, nonnull) NSArray<FBPeripheralItem *> *connectedPeripheralItems;
/// 委托对象
@property (nonatomic, weak, nullable) id<FBBluetoothBrowserDelegate> delegate;
/// 是否开启详细的扫描外设日志
@property (nonatomic, assign) BOOL isPrintLog;

/// 获取版本号
+ (NSString *)sdkVersion;

/// 初始化
/// - Parameter type: 设备数组'peripheralItems'中只放置一种类型的设备
- (instancetype)initWithType:(const FBBluetoothBrowserType)type;

/// 配置解密密钥
/// - Parameter decryptKey: 解密密钥（128位）
- (BOOL)setupDecryptKey:(NSData *)decryptKey;

/// 开始扫描外设
- (BOOL)startScanning;

/// 开始对广播包中包含特定UUID的外设进行扫描
- (BOOL)startScanningWithServices:(nullable NSArray<NSString *> *)serviceUUIDs;

/// 停止扫描外设
- (void)stopScanning;

/// 将外设数组'peripheralItems'按RSSI从强到弱排序
- (void)sortByRSSI;

@end

NS_ASSUME_NONNULL_END
