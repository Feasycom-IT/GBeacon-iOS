//
//  FWCentralUIDBeaconCell.h
//  FeasyBeacon
//
//  Created by ericj on 2017/9/18.
//  Copyright © 2017年 LIDONG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FWCentralUIDBeaconCell : UITableViewCell

// RSSI at 1m
@property (weak, nonatomic) IBOutlet UILabel *eddystoneUIDPower;
// 命名空间
@property (weak, nonatomic) IBOutlet UILabel *nameSpace;
//
@property (weak, nonatomic) IBOutlet UILabel *instance;
//
@property (weak, nonatomic) IBOutlet UILabel *reserved;

@end
