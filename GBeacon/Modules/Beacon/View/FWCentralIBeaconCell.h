//
//  FWCentralIBeaconCell.h
//  FeasyBeacon
//
//  Created by ericj on 2017/9/18.
//  Copyright © 2017年 LIDONG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FWCentralIBeaconCell : UITableViewCell

// UUID
@property (weak, nonatomic) IBOutlet UILabel *iBeaconUUID;
// Major
@property (weak, nonatomic) IBOutlet UILabel *iBeaconMajor;
// Minor
@property (weak, nonatomic) IBOutlet UILabel *iBeaconMinor;

@end
