//
//  FBCentrallBP104ELCell.h
//  FeasyBeacon
//
//  Created by wenjie zeng on 2023/9/19.
//  Copyright © 2023 Feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBCentrallBP104ELCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *iBeaconName;
@property (weak, nonatomic) IBOutlet UILabel *iBeaconServiceData;
@property (weak, nonatomic) IBOutlet UIProgressView *iBeaconProgress;
@property (weak, nonatomic) IBOutlet UILabel *iBeaconRSSI;

- (void)refreshRSSI:(NSInteger)rssi;
@end

NS_ASSUME_NONNULL_END
