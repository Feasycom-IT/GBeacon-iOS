//
//  FBAtEngineVC.h
//  FeasyBeacon
//
//  Created by chenchanghua on 2024/3/13.
//  Copyright © 2024 Feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBSDKPublicHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBAtEngineVC : UIViewController

- (instancetype)initWithSession:(FBSession *)session;

@end

NS_ASSUME_NONNULL_END
