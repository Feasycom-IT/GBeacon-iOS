//
//  FWCentralURLBeaconCell.m
//  FeasyBeacon
//
//  Created by ericj on 2017/9/18.
//  Copyright © 2017年 LIDONG. All rights reserved.
//

#import "FWCentralURLBeaconCell.h"

@interface FWCentralURLBeaconCell ()

@end

@implementation FWCentralURLBeaconCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setupUrlPath:(NSString *)string {
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange strRange = {0,[string length]};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [self.addressButton setAttributedTitle:str forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
