//
//  FWCentralURLBeaconCell.h
//  FeasyBeacon
//
//  Created by ericj on 2017/9/18.
//  Copyright © 2017年 LIDONG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FWCentralURLBeaconCell : UITableViewCell

// RSSI at 1m
@property (weak, nonatomic) IBOutlet UILabel *eddystonePower;
// url按钮
@property (weak, nonatomic) IBOutlet UIButton *addressButton;

// url路径
- (void)setupUrlPath:(NSString *)string;

@end
