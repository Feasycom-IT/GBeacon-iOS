//
//  FBPeripheralCell.h
//  FeasyBeacon
//
//  Created by ericj on 2017/9/20.
//  Copyright © 2017年 LIDONG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBPeripheralCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *macAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *rssiProgress;
@property (weak, nonatomic) IBOutlet UIImageView *ElectricityImageView;
@property (weak, nonatomic) IBOutlet UILabel *electricityLabel;

- (void)refreshRSSI:(NSInteger)rssi;

@end
