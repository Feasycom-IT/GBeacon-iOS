//
//  FWPopoverViewController.h
//  FeasyBeacon
//
//  Created by ericj on 2018/3/7.
//  Copyright © 2018年 LIDONG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FWPopoverViewController : UITableViewController

- (instancetype)initWithTitles:(NSArray *)titles sourceView:(UIView *)sourceView;

@property (nonatomic, copy) void(^selectionHandler)(NSString *result);

@end
