//
//  FWADView.h
//  FeasyWIFI
//
//  Created by ericj on 2020/7/14.
//  Copyright © 2020 Feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 开屏页的广告
@interface FWADView : UIView
+ (void)showWithSeconds:(NSInteger)seconds;
@end

NS_ASSUME_NONNULL_END
