//
//  FBUpgradeManager.h
//  FeasyBeacon
//
//  Created by app on 2021/7/2.
//  Copyright © 2021 LIDONG. All rights reserved.
//

#import "FBSession.h"
#import <CoreGraphics/CoreGraphics.h>

#define kModelNumKey    @"ModelNum"
#define kModelKey       @"Model"
#define kAppVersionKey  @"AppVersion"
#define kBLVersionKey   @"BLVersion"

NS_ASSUME_NONNULL_BEGIN

/// 空中升级管理类
@interface FBUpgradeManager : NSObject

/// 初始化
- (instancetype)initWithPeripheralItem:(FBPeripheralItem *)peripheralItem PINCode:(nullable NSString *)PINCode;
/// 通讯会话层
@property (nonatomic, strong, readonly) FBSession *session;
/// 解析升级文件信息
/// @param data 文件数据
/// @param complete 完成回调
/// @param faile 失败回调
- (void)infoFromData:(NSData *)data complete:(void(^)(NSString *bootloader, NSString *binCrc, NSInteger length, NSString *versionRange, NSString * _Nullable modelType, NSInteger modelTypeNum, NSString *uploadModel, NSString *crc))complete faile:(void (^)(void))faile;
/// （外路操作）升级
/// @param path 固件路径
/// @param restore 是否恢复出厂设置
/// @param infoHandler 当前模块的信息（模块型号、固件版本、BT版本）
/// @param progressHandler 升级进度
/// @param completionHandler 升级操作结果
- (void)upgradeWithFilePath:(NSString *)path restore:(BOOL)restore infoHandler:(void (^)(NSDictionary * _Nullable))infoHandler progressHandler:(void (^)(CGFloat))progressHandler completionHandler:(void (^)(NSError * _Nullable))completionHandler;

@end

NS_ASSUME_NONNULL_END
