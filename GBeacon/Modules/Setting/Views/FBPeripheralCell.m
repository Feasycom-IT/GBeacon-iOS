//
//  FBPeripheralCell.m
//  FeasyBeacon
//
//  Created by ericj on 2017/9/20.
//  Copyright © 2017年 LIDONG. All rights reserved.
//

#import "FBPeripheralCell.h"

@interface FBPeripheralCell ()





@end

@implementation FBPeripheralCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)refreshRSSI:(NSInteger)rssi {
    if (rssi < 0) {
        self.rssiLabel.text = [NSString stringWithFormat:@"%ld", (long)rssi];
        [self.rssiProgress setProgress:(100+rssi)/100.0 animated:YES];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
