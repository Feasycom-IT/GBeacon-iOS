//
//  FBFilter.h
//  FeasyBeacon
//
//  Created by LiDong on 2021/6/21.
//  Copyright © 2021 LIDONG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBFilter : NSObject

/// 是否开启「名称过滤」
@property (nonatomic, assign) BOOL filterByNameEnabled;
/// 筛选的「名称」
@property (nonatomic, strong) NSString *filterName;
/// 筛选的「RSSI最弱值」
@property (nonatomic, assign) CGFloat minimumRSSI;

/// 保存当前各属性值到缓存中，初始化FBBluetoothBrowser对象时默认使用上一次保存的FBFilter各属性值
- (void)saveData;

@end

NS_ASSUME_NONNULL_END
