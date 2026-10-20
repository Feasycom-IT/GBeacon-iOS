//
//  FWSensorViewCell.h
//  FeasyBeacon
//
//  Created by wenyewei on 2019/8/23.
//  Copyright © 2019 LIDONG. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FWSensorViewCell : UITableViewCell
//湿度
@property (weak, nonatomic) IBOutlet UILabel *humidity;
//温度
@property (weak, nonatomic) IBOutlet UILabel *temperature;
//电量
@property (weak, nonatomic) IBOutlet UILabel *electricity;
//电池百分比
@property (weak, nonatomic) IBOutlet UIImageView *batteryImageView;

- (void)refreshRSSI:(NSInteger)rssi;
@end

NS_ASSUME_NONNULL_END
