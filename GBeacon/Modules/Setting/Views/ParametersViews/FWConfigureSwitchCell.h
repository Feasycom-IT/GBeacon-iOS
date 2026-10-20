//
//  FWConfigureSwitchCell.h
//  FeasyBeacon
//
//  Created by ericj on 2017/9/22.
//  Copyright © 2017年 LIDONG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FWConfigureSwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;

@property (copy, nonatomic) void (^indexPathBlock)(NSIndexPath *newIndexPath, BOOL switchBtnState);

@end
