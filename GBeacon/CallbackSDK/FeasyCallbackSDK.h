//
//  FeasyCallbackSDK.h
//  FeasyCallbackSDK
//
//  Created by ericj on 2020/6/3.
//  Copyright © 2020 feasycom. All rights reserved.
//

#pragma mark 版本 1.2（从 domain 到 qq 域名，改为 domain 到 飞易通域名）

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FEEDBACKTYPE) {
    FEEDBACKTYPE_ADVICE,        // 建议
    FEEDBACKTYPE_BUG,           // 功能异常
    FEEDBACKTYPE_UI,            // 界面异常
    FEEDBACKTYPE_COOPERATION,   // 合作
};

NS_ASSUME_NONNULL_BEGIN

typedef void(^FeasyCallbackCompletion)(NSInteger code,
                                       NSDictionary * _Nullable data,
                                       NSString * _Nullable msg,
                                       NSError * _Nullable error);

@interface FeasyCallbackSDK : NSObject

/// 提交用户反馈（会自动填充平台/包名/版本/系统版本/机型）
+ (void)submitFeedbackWithType:(FEEDBACKTYPE)type
                       content:(NSString *)content
                           tel:(nullable NSString *)tel
                         phone:(nullable NSString *)phone
                         email:(nullable NSString *)email
                        wechat:(nullable NSString *)wechat
                            QQ:(nullable NSString *)QQ
                    completion:(FeasyCallbackCompletion)completion;

@end

NS_ASSUME_NONNULL_END
