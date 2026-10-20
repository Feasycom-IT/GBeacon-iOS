//
//  FBPeripheralManager.h
//  FeasyBeacon
//
//  Created by LiDong on 2021/6/23.
//  Copyright © 2021 LIDONG. All rights reserved.
//

#import "FBMutableBeacon.h"
#import "FBPeripheralItem.h"
#import "FBSession.h"
#import "FBConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

#define kMaxNumberOfBeacons 10

#define kModel      @"Model"
#define kVersion    @"Version"
#define kName       @"Name"
#define kInterval   @"Interval"
#define kPin        @"Pin"
#define kTxPower    @"TxPower"
#define kGsensor    @"Gsensor"
#define kKey        @"Key"
#define kTLM        @"TLM"
#define kLongRange  @"LongRange"
#define kPhy        @"Phy"

/// 使用指令对设备进行配置
@interface FBPeripheralManager : NSObject

/// 初始化
- (instancetype)initWithPeripheralItem:(FBPeripheralItem *)peripheralItem PINCode:(nullable NSString *)PINCode;
/// 外设
@property (nonatomic, strong, readonly) FBPeripheralItem *peripheralItem;
/// 通信会话层
@property (nonatomic, strong, readonly) FBSession *session;
/// 蓝牙断开的回调
@property (nonatomic, copy) void(^closeHandler)(NSError * _Nullable);
/// 外路操作是否占线
@property (nonatomic, assign, readonly, getter=isHandleBusy) BOOL handleBusy;
/// （外路操作）加载型号、参数取值范围等
- (void)loadConfigurationWithCompletionHandler:(void (^)(FBConfiguration * _Nullable))completionHandler;
/// 配置参数取值范围
@property (nonatomic, strong, readonly) FBConfiguration *configuration;
/// 可配置参数的名称
@property (nonatomic, strong, readonly) NSArray *paramKeys;
/// （外路操作）从设备读取所有参数的当前配置值
- (void)loadParametersWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler;
/// 配置参数的值
@property (nonatomic, strong, readonly) NSArray *paramValues;
/// 标准Beacon广播（iBeacon、UID、URL、TLM、ATLBeacon）数组
@property (nonatomic, strong, readonly) NSMutableArray<FBMutableBeacon *> *beacons;
/// （闭路操作）查询参数的配置值
- (id)valueForName:(NSString *)name;
/// （闭路操作）更新参数的配置值
- (void)setValue:(id)value forName:(NSString *)name;
/// （外路操作）向设备写入所有参数（包括标准Beacon广播的配置）
- (void)saveParametersWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler;
/// （外路操作）重置设备
- (void)restoreWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler;
/// 日志（连接成功、连接失败）
- (NSArray *)queryParametersHandledResultLog;

@end

NS_ASSUME_NONNULL_END
