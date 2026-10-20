//
//  FWCentralTLMBeaconCell.h
//  FeasyBeacon
//
//  Created by chenchanghua on 2024/3/4.
//  Copyright © 2024 Feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FWCentralTLMBeaconCell : UITableViewCell

// 版本
@property (weak, nonatomic) IBOutlet UILabel *tlmVersionLabel;
// 温度
@property (weak, nonatomic) IBOutlet UILabel *beaconTemperatureLabel;
// 电压
@property (weak, nonatomic) IBOutlet UILabel *batteryVoltageLabel;
// 已发广播数
@property (weak, nonatomic) IBOutlet UILabel *advertisingPDUCountLabel;
// 已启动时间
@property (weak, nonatomic) IBOutlet UILabel *timeSincePowerOnOrRebootLabel;

@end

NS_ASSUME_NONNULL_END
