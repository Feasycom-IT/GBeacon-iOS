//
//  FBUserDefaultCache.m
//  BLEAssistant
//
//  Created by chenchanghua on 2021/9/20.
//  Copyright © 2021 feasycom. All rights reserved.
//

#import "FBUserDefaultCache.h"

#define PathUserDefaults [NSUserDefaults standardUserDefaults]

@implementation FBUserDefaultCache

+ (BOOL *)getIsUseScanLog {
    return [PathUserDefaults boolForKey:@"isUseScanLog"];
}
+ (void)saveIsUseScanLog:(BOOL)isUseScanLog {
    [PathUserDefaults setBool:isUseScanLog forKey:@"isUseScanLog"];
    [PathUserDefaults synchronize];
}
@end
