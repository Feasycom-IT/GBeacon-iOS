//
//  FWCentralAltBeaconCell.h
//  FeasyBeacon
//
//  Created by ericj on 2017/10/26.
//  Copyright © 2017年 LIDONG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FWCentralAltBeaconCell : UITableViewCell

// companyID
@property (weak, nonatomic) IBOutlet UILabel *mfgID;
// beaconID值
@property (weak, nonatomic) IBOutlet UILabel *altID;
// RSSI at 1m
@property (weak, nonatomic) IBOutlet UILabel *altPower;
// reserved值
@property (weak, nonatomic) IBOutlet UILabel *altReserved;

@end
