//
//  FEFirmwareInfoModel.h
//  BLEAssistant
//
//  Created by chenchanghua on 2022/1/7.
//  Copyright © 2022 feasycom. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 升级固件信息Model
@interface FEFirmwareInfoModel : NSObject

@property (nonatomic, copy) NSString *bootloader;
@property (nonatomic, copy) NSString *binCrc;
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, copy) NSString *versionRange;
@property (nonatomic, copy) NSString * _Nullable modelType;
@property (nonatomic, assign) NSInteger modelTypeNum;
@property (nonatomic, copy) NSString *uploadModel;
@property (nonatomic, copy) NSString *crc;

@end

NS_ASSUME_NONNULL_END
