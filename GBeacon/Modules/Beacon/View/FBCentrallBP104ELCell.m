//
//  FBCentrallBP104ELCell.m
//  FeasyBeacon
//
//  Created by wenjie zeng on 2023/9/19.
//  Copyright © 2023 Feasycom. All rights reserved.
//

#import "FBCentrallBP104ELCell.h"

@implementation FBCentrallBP104ELCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshRSSI:(NSInteger)rssi{
    self.iBeaconRSSI.text = [NSString stringWithFormat:@"%ld", (long)rssi];
    [self.iBeaconProgress setProgress:(100+rssi)/100.0 animated:YES];
}

@end
