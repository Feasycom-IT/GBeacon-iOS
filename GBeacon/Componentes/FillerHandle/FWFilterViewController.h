//
//  FWFilterViewController.h
//  BLEAssistant
//
//  Created by ericj on 2018/6/5.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBSDKPublicHeader.h"

/// 过滤VC
@interface FWFilterViewController : UIViewController

- (instancetype)initWithFilter:(FBFilter *)filter;

@end
