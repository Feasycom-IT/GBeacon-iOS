//
//  FBError.h
//  FeasycomLE
//
//  Created by LIDONG on 7/9/15.
//  Copyright (c) 2015 LIDONG. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const FBErrorDomain;

typedef enum : NSUInteger {
    FBErrorNone = 0,                    // 没有错误
    FBErrorConnectionTimeout,           // 连接超时
    FBErrorOpeningTimeout,              // 发现服务、特征超时
    FBErrorOpeningFailed,               // 发现服务、特征失败
    FBErrorAuthorizationFailed,         // 验证失败
    FBErrorLoadingParametersTimeout,    // 加载参数超时
    FBErrorSavingParametersTimeout,     // 保存参数超时
    FBErrorLoadingParametersFailed,     // 加载参数失败
    FBErrorSavingParametersFailed,      // 保存参数失败
    FBErrorUpgradingFileNotExist,       // 升级文件不存在
    FBErrorUpgradingDataIsEmpty,        // 升级文件数据为空
    FBErrorIsUpgrading,                 // 已经在升级中
    FBErrorUpgradingAbort,              // 升级中断
    FBErrorUpgradingTimeout,            // 升级超时
} FBError;
