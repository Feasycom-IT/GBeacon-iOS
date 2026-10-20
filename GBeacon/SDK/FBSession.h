//
//  FBSession.h
//  FeasyBeacon
//
//  Created by LiDong on 2021/6/17.
//  Copyright © 2021 LIDONG. All rights reserved.
//

#import "FBPeripheralItem.h"

NS_ASSUME_NONNULL_BEGIN

@class FBSession;

@protocol FBSessionDelegate <NSObject>
@optional
/// 通话已打开
- (void)sessionDidOpen:(FBSession *)session;
/// 通话已结束
- (void)sessionDidClose:(FBSession *)session error:(NSError *)error;
/// 通话数据写入完成
- (void)sessionDidWrite:(FBSession *)session;
/// 通话接收数据
- (void)session:(FBSession *)session didReceiveData:(NSData *)data;
@end

/// 向设备写数据 做了一个中间会话层
@interface FBSession : NSObject

/// 初始化
- (instancetype)initWithPeripheralItem:(FBPeripheralItem *)peripheralItem pinCode:(NSString *)pinCode;
/// 外设
@property (nonatomic, strong, readonly) FBPeripheralItem *peripheralItem;
/// 代理
@property (nonatomic, weak) id<FBSessionDelegate> delegate;
/// 延时验证
@property (nonatomic, assign) NSTimeInterval authorizingDelay;
/// 打开会话
- (void)openSession;
/// 关闭会话
- (void)closeSession;
/// 会话是否打开
@property (nonatomic, assign, readonly, getter=isOpened) BOOL opened;
/// 通过会话写数据
- (BOOL)writeDataInSession:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
