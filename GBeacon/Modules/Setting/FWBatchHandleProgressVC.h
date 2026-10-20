//
//  FWBatchHandleProgressVC.h
//  FeasyBeacon
//
//  Created by chenchanghua on 2022/3/26.
//  Copyright © 2022 Feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FBPeripheralItem, FBPeripheralManager;

typedef void(^ContinueBatchHandleBlock)(NSArray<NSString *> * _Nullable macAddressHandled);

NS_ASSUME_NONNULL_BEGIN

/// 批量配置设备中VC
@interface FWBatchHandleProgressVC : UIViewController

@property (nonatomic, copy) ContinueBatchHandleBlock continueBatchHandleBlock;

- (instancetype)initWithSelectedPeripheralItems:(NSMutableArray <FBPeripheralItem *> *)selectedPeripheralItems beaconConfigurated:beaconConfiguratedDic;

@end

NS_ASSUME_NONNULL_END
