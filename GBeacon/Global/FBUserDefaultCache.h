//
//  FBUserDefaultCache.h
//  BLEAssistant
//
//  Created by chenchanghua on 2021/9/20.
//  Copyright © 2021 feasycom. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBUserDefaultCache : NSObject

+ (BOOL *)getIsUseScanLog;
+ (void)saveIsUseScanLog:(BOOL)isUseScanLog;

@end

NS_ASSUME_NONNULL_END
